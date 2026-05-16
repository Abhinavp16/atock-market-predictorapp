const { loadSymbolMaster } = require("./symbolMaster");
const fallback = require("./marketFallback");
const { PythonMarketClient } = require("./pythonClient");

const FALLBACK_ENABLED = process.env.ML_FALLBACK_ENABLED !== "false";
const pythonClient = new PythonMarketClient();

function formatCompactRupee(value) {
  if (value >= 10000000) {
    return `\u20B9${Number((value / 10000000).toFixed(2))}Cr`;
  }
  if (value >= 100000) {
    return `\u20B9${Number((value / 100000).toFixed(2))}L`;
  }
  return `\u20B9${Number(value.toFixed(2))}`;
}

function logFallback(label, error) {
  console.warn(`[market-service] ${label} fallback engaged: ${error.message}`);
}

async function withFallback(label, primary, secondary) {
  try {
    return await primary();
  } catch (error) {
    if (!FALLBACK_ENABLED) {
      throw error;
    }
    logFallback(label, error);
    return secondary();
  }
}

async function searchSymbols(query) {
  return withFallback(
    "searchSymbols",
    () => pythonClient.searchSymbols(query),
    () => fallback.searchSymbols(query),
  );
}

async function getQuote(symbol) {
  return withFallback(
    `getQuote:${symbol}`,
    () => pythonClient.getQuote(symbol),
    () => fallback.quoteForSymbol(symbol),
  );
}

async function getChart(symbol, range) {
  return withFallback(
    `getChart:${symbol}`,
    () => pythonClient.getChart(symbol, range),
    () => fallback.chartForSymbol(symbol, range),
  );
}

async function getCompany(symbol) {
  return withFallback(
    `getCompany:${symbol}`,
    () => pythonClient.getCompany(symbol),
    () => fallback.companyForSymbol(symbol),
  );
}

async function getPrediction(symbol) {
  return withFallback(
    `getPrediction:${symbol}`,
    () => pythonClient.getPrediction(symbol),
    () => fallback.predictionForSymbol(symbol),
  );
}

async function buildWatchlist(symbols) {
  const assets = await Promise.all(
    symbols.map(async (symbol) => {
      const [quote, prediction] = await Promise.all([getQuote(symbol), getPrediction(symbol)]);
      return {
        symbol: quote.symbol,
        name: quote.displayName,
        price: quote.currentPrice,
        changePct: quote.changePct,
        signal: prediction.direction,
        signalTone:
          prediction.direction.toLowerCase().includes("buy")
            ? "positive"
            : prediction.direction.toLowerCase().includes("sell")
              ? "negative"
              : "neutral",
        sparkline: quote.sparkline || [],
      };
    }),
  );

  return {
    title: "Active Watchlist",
    trackedCount: assets.length,
    searchPlaceholder: "Search NSE stocks, sectors, or company names...",
    assets,
    insight: {
      title: "Broad Market Monitoring",
      description:
        "This watchlist now derives its signals from a wider Indian equity catalog, not a small fixed demo basket.",
      cta: "View Detailed Report",
    },
  };
}

async function buildDashboard(user, watchlistSymbols) {
  const highlighted = ["RELIANCE", "TCS", "INFY", "HDFCBANK", "SBIN", "ICICIBANK", "LT"];
  const dashboardUniverse = Array.from(
    new Set([...highlighted, ...loadSymbolMaster().slice(0, 24).map((item) => item.symbol)]),
  );
  const [allQuotes, heroPrediction] = await Promise.all([
    Promise.all(dashboardUniverse.map((symbol) => getQuote(symbol))),
    getPrediction("INFY"),
  ]);
  const quoteMap = new Map(allQuotes.map((quote) => [quote.symbol, quote]));
  const quotes = highlighted.map((symbol) => quoteMap.get(symbol)).filter(Boolean);
  const liveCards = quotes.slice(0, 2).map((quote, index) => ({
    symbol: quote.symbol,
    name: quote.displayName,
    price: quote.currentPrice,
    changePct: quote.changePct,
    trend: quote.changePct >= 0 ? "up" : "down",
    sparkline: quote.sparkline || [],
    accent: index === 0 ? "secondary" : quote.changePct >= 0 ? "primary" : "error",
  }));
  const watchlistPreview = watchlistSymbols.slice(0, 4).map((symbol) => {
    const quote = quotes.find((item) => item.symbol === symbol) || fallback.quoteForSymbol(symbol);
    return {
      symbol: quote.symbol,
      name: quote.displayName,
      price: quote.currentPrice,
      changePct: quote.changePct,
    };
  });
  const positiveHighReturn = allQuotes
    .filter((quote) => Number.isFinite(quote.changePct) && quote.changePct > 0)
    .sort((left, right) => right.changePct - left.changePct);
  const highReturnSource = positiveHighReturn.length
    ? positiveHighReturn
    : [...allQuotes].sort((left, right) => right.changePct - left.changePct);
  const topHighReturn = highReturnSource.slice(0, 8);
  const liveCount = topHighReturn.filter((quote) => (quote.dataSource || "simulated") === "live").length;
  const eodCount = topHighReturn.filter((quote) => (quote.dataSource || "simulated") === "yahoo_eod").length;
  const highReturn = {
    title: "High Return",
    subtitle: "Top-return ideas ranked from the latest tracked Indian market snapshot",
    sourceLabel:
      liveCount >= 6
        ? "Live"
        : liveCount > 0
          ? "Mostly Live"
          : eodCount > 0
            ? "Market Closed"
            : "Simulated",
    items: topHighReturn.map((quote) => ({
      symbol: quote.symbol,
      name: quote.displayName,
      price: quote.currentPrice,
      priceChange: quote.change,
      changePct: quote.changePct,
      sparkline: quote.sparkline || [],
      dataSource: quote.dataSource || "simulated",
      marketState: quote.marketState || "SIMULATED",
      timestamp: quote.timestamp,
    })),
  };
  const ranked = [...quotes].sort((left, right) => Math.abs(right.changePct) - Math.abs(left.changePct)).slice(0, 3);

  return {
    greeting: `Good morning, ${user.firstName}`,
    subtitle: "Broad Indian equity coverage and daily model refreshes are ready.",
    searchPlaceholder: "Search NSE stock, sector, or company...",
    liveCards,
    highReturn,
    aiPrediction: {
      symbol: heroPrediction.symbol,
      badge: "AI PREDICTION",
      title: `${heroPrediction.direction} Signal`,
      description: heroPrediction.synthesis,
      confidence: heroPrediction.confidence,
    },
    trendingInsights: ranked.map((quote, index) => ({
      title: `${quote.symbol} ${quote.changePct >= 0 ? "Outperforming" : "Cooling Off"}`,
      description:
        `${quote.displayName} is showing broad-market relevance through ${quote.sector.toLowerCase()} participation and model-backed monitoring.`,
      age: index === 0 ? "20m ago" : index === 1 ? "2h ago" : "Today",
      icon: index === 0 ? "rocket_launch" : index === 1 ? "energy_savings_leaf" : "data_thresholding",
      color: index === 0 ? "secondary" : index === 1 ? "primary" : "tertiary",
    })),
    watchlistPreview,
    featuredAnalysis: {
      label: "DEEP DIVE",
      title: "How the shared market model ranks Indian sector leadership",
      description:
        "A wider Indian equity catalog now powers the quotes, chart history, and predictive workflows shown in the app.",
    },
  };
}

async function buildAnalytics() {
  return withFallback(
    "buildAnalytics",
    async () => {
      const snapshotSymbols = loadSymbolMaster().slice(0, 40).map((item) => item.symbol);
      const quotes = await Promise.all(snapshotSymbols.map((symbol) => getQuote(symbol)));
      const sectorMap = new Map();

      quotes.forEach((quote) => {
        const values = sectorMap.get(quote.sector) || [];
        values.push(quote.changePct);
        sectorMap.set(quote.sector, values);
      });

      const sectors = Array.from(sectorMap.entries())
        .map(([name, values]) => ({
          name,
          performance: Number((values.reduce((sum, value) => sum + value, 0) / values.length).toFixed(2)),
        }))
        .sort((left, right) => right.performance - left.performance)
        .slice(0, 4);

      const movers = [...quotes]
        .sort((left, right) => Math.abs(right.changePct) - Math.abs(left.changePct))
        .slice(0, 4)
        .map((quote) => ({
          symbol: quote.symbol,
          movePct: Number(Math.abs(quote.changePct).toFixed(2)),
          direction: quote.changePct >= 0 ? "up" : "down",
        }));

      const averagePerformance = sectors.length
        ? sectors.reduce((sum, item) => sum + item.performance, 0) / sectors.length
        : 0;
      const sentimentScore = Math.max(35, Math.min(92, Math.round(55 + averagePerformance * 4)));

      return {
        title: "Market Analytics",
        sentiment: {
          score: sentimentScore,
          label: sentimentScore >= 70 ? "Constructive Breadth" : sentimentScore >= 55 ? "Balanced Breadth" : "Cautious Breadth",
          description:
            "This view is generated from a broader Indian equity snapshot, not a static demo list.",
        },
        sectors,
        tradeVolume: quotes.slice(0, 7).map((quote) => Number((quote.volume / 100000).toFixed(1))),
        movers,
        signal: {
          title: "Shared Market Model Signal",
          description:
            "Current signals combine sector rotation, benchmark context, and daily end-of-day market structure.",
        },
      };
    },
    () => fallback.buildAnalytics(),
  );
}

async function buildStockDetails(symbol) {
  return withFallback(
    `buildStockDetails:${symbol}`,
    async () => {
      const [quote, company, prediction, chart] = await Promise.all([
        getQuote(symbol),
        getCompany(symbol),
        getPrediction(symbol),
        getChart(symbol, "1M"),
      ]);
      const candles = chart.series.slice(-7);
      const combinedValues = [
        ...candles.map((point) => point.low),
        ...candles.map((point) => point.high),
        ...prediction.sevenDayForecast.map((point) => point.value),
      ];
      const minValue = Math.min(...combinedValues);
      const maxValue = Math.max(...combinedValues);
      const scaleY = (value) => {
        if (maxValue === minValue) return 140;
        const normalized = (value - minValue) / (maxValue - minValue);
        return Number((250 - normalized * 170).toFixed(2));
      };

      return {
        symbol: quote.symbol,
        companyName: quote.displayName,
        price: quote.currentPrice,
        priceChange: quote.change,
        changePct: quote.changePct,
        predictionAccuracy: prediction.confidence,
        predictionLabel: `${prediction.direction} Signal`,
        predictionNote: "Shared market model using Indian daily OHLCV, trend, and sector context",
        timeframeOptions: ["1W", "1M", "3M", "6M", "1Y", "ALL"],
        selectedTimeframe: "1M",
        candles: candles.map((point, index) => ({
          x: 50 + index * 48,
          open: scaleY(point.open),
          close: scaleY(point.close),
          high: scaleY(point.high),
          low: scaleY(point.low),
          tone: point.close >= point.open ? "up" : "down",
        })),
        forecastPath: prediction.sevenDayForecast.map((point, index) => ({
          x: 400 + index * 24,
          y: scaleY(point.value),
        })),
        availableCash: 425000,
        defaultInvestmentAmount: 25000,
        marketStats: [
          { label: "Market Cap", value: formatCompactRupee(company.marketCap) },
          { label: "P/E Ratio", value: company.peRatio.toFixed(2) },
          { label: "Avg. Volume", value: `${Number((company.avgVolume20 / 100000).toFixed(1))}L` },
          { label: "52W High", value: `₹${company.week52High.toFixed(2)}` },
        ],
        insights: [
          {
            title: "Trend Memory",
            icon: "hub",
            description:
              `Recent price structure in ${quote.symbol} is being compared against the broader Indian market history to identify persistent trend behaviour.`,
          },
          {
            title: "Volatility Gating",
            icon: "data_exploration",
            description:
              "The prediction engine reduces short-lived noise by balancing sector momentum with recent volatility and benchmark context.",
          },
          {
            title: "Bias Estimation",
            icon: "psychology_alt",
            description:
              `${quote.symbol} is currently scored with ${prediction.confidence.toFixed(1)}% confidence based on the latest daily market refresh.`,
          },
        ],
      };
    },
    () => fallback.buildStockDetails(symbol),
  );
}

module.exports = {
  searchSymbols,
  getQuote,
  getChart,
  getCompany,
  getPrediction,
  buildWatchlist,
  buildDashboard,
  buildAnalytics,
  buildStockDetails,
  pythonClient,
};
