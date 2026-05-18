const { AppError } = require("./errors");
const { buildDefaultPortfolio } = require("./defaults");

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

class UserDataService {
  constructor(database, marketService) {
    this.database = database;
    this.marketService = marketService;
  }

  async getWatchlistSymbols(userId) {
    const doc = await this.database.getWatchlist(userId);
    return doc?.symbols || [];
  }

  async addWatchlistSymbol(userId, symbol) {
    const symbols = await this.getWatchlistSymbols(userId);
    if (!symbols.includes(symbol)) {
      symbols.unshift(symbol);
      await this.database.saveWatchlist(userId, symbols);
    }
    return symbols;
  }

  async removeWatchlistSymbol(userId, symbol) {
    const symbols = (await this.getWatchlistSymbols(userId)).filter((item) => item !== symbol);
    await this.database.saveWatchlist(userId, symbols);
    return symbols;
  }

  async getSettingsDocument(userId) {
    const doc = await this.database.getSettings(userId);
    return clone(doc.document);
  }

  async updateSetting(userId, sectionTitle, itemLabel, value) {
    const document = await this.getSettingsDocument(userId);
    const section = document.sections.find((item) => item.title === sectionTitle);
    const setting = section?.items.find((item) => item.label === itemLabel);
    if (!section || !setting) {
      throw new AppError(404, "Setting not found.");
    }
    setting.value = value;
    await this.database.saveSettings(userId, document);
    return document;
  }

  async getNotifications(userId) {
    const doc = await this.database.getNotifications(userId);
    return clone(doc.items);
  }

  async getPortfolio(userId) {
    const portfolio = await this.database.getPortfolio(userId);
    return portfolio || buildDefaultPortfolio();
  }

  async listOrders(userId) {
    return this.database.listOrders(userId);
  }

  async placePaperOrder(userId, { symbol, side, amount }) {
    const portfolio = await this.getPortfolio(userId);
    const quote = await this.marketService.getQuote(symbol);
    const quantity = Math.max(1, Math.floor(amount / Math.max(quote.currentPrice, 1)));
    const orderValue = Number((quantity * quote.currentPrice).toFixed(2));

    if (side === "buy" && portfolio.cashBalance < orderValue) {
      throw new AppError(400, "Insufficient cash balance for this paper trade.");
    }

    const existingPosition = portfolio.positions.find((item) => item.symbol === quote.symbol);
    if (side === "sell" && (!existingPosition || existingPosition.quantity < quantity)) {
      throw new AppError(400, "Not enough position quantity to sell.");
    }

    if (side === "buy") {
      if (existingPosition) {
        const nextQuantity = existingPosition.quantity + quantity;
        existingPosition.averagePrice = Number(
          ((existingPosition.averagePrice * existingPosition.quantity + orderValue) / nextQuantity).toFixed(2),
        );
        existingPosition.quantity = nextQuantity;
        existingPosition.lastPrice = quote.currentPrice;
      } else {
        portfolio.positions.push({
          symbol: quote.symbol,
          name: quote.displayName,
          sector: quote.sector,
          quantity,
          averagePrice: quote.currentPrice,
          lastPrice: quote.currentPrice,
        });
      }
      portfolio.cashBalance = Number((portfolio.cashBalance - orderValue).toFixed(2));
    }

    if (side === "sell") {
      const proceeds = Number((quantity * quote.currentPrice).toFixed(2));
      const costBasis = Number((quantity * existingPosition.averagePrice).toFixed(2));
      existingPosition.quantity -= quantity;
      existingPosition.lastPrice = quote.currentPrice;
      portfolio.cashBalance = Number((portfolio.cashBalance + proceeds).toFixed(2));
      portfolio.realizedPnl = Number((portfolio.realizedPnl + (proceeds - costBasis)).toFixed(2));
      if (existingPosition.quantity <= 0) {
        portfolio.positions = portfolio.positions.filter((item) => item.symbol !== quote.symbol);
      }
    }

    const positionsWithMarket = await Promise.all(
      portfolio.positions.map(async (position) => {
        const latestQuote = position.symbol === quote.symbol ? quote : await this.marketService.getQuote(position.symbol);
        const marketValue = Number((position.quantity * latestQuote.currentPrice).toFixed(2));
        const investedValue = Number((position.quantity * position.averagePrice).toFixed(2));
        return {
          ...position,
          lastPrice: latestQuote.currentPrice,
          marketValue,
          unrealizedPnl: Number((marketValue - investedValue).toFixed(2)),
        };
      }),
    );

    const totalInvested = positionsWithMarket.reduce((sum, item) => sum + item.quantity * item.averagePrice, 0);
    const totalMarketValue = positionsWithMarket.reduce((sum, item) => sum + item.marketValue, 0);
    const sectorMap = new Map();
    positionsWithMarket.forEach((item) => {
      sectorMap.set(item.sector, (sectorMap.get(item.sector) || 0) + item.marketValue);
    });
    portfolio.positions = positionsWithMarket;
    portfolio.analytics = {
      totalValue: Number((portfolio.cashBalance + totalMarketValue).toFixed(2)),
      investedValue: Number(totalInvested.toFixed(2)),
      unrealizedPnl: Number((totalMarketValue - totalInvested).toFixed(2)),
      exposureBySector: Array.from(sectorMap.entries()).map(([sector, value]) => ({
        sector,
        value: Number(value.toFixed(2)),
      })),
    };

    await this.database.savePortfolio(userId, portfolio);

    const order = {
      id: `ord_${Date.now()}`,
      userId,
      symbol: quote.symbol,
      side,
      amount,
      quantity,
      executedPrice: quote.currentPrice,
      orderValue,
      status: "filled",
      createdAt: new Date().toISOString(),
      executedAt: new Date().toISOString(),
    };
    await this.database.createOrder(order);
    return {
      order,
      portfolio,
    };
  }
}

module.exports = {
  UserDataService,
};
