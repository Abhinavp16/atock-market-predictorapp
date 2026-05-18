const { loadSymbolMaster } = require("./symbolMaster");
const fallback = require("./marketFallback");
const { PythonMarketClient } = require("./pythonClient");
const { config } = require("./config");

const FALLBACK_ENABLED = config.ml.fallbackEnabled;
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

async function searchSymbols(query, filters = {}) {
  return withFallback(
    "searchSymbols",
    async () => {
      const result = await pythonClient.searchSymbols(query);
      return applySymbolFilters(result, filters);
    },
    () => applySymbolFilters(fallback.searchSymbols(query), filters),
  );
}

function applySymbolFilters(result, filters) {
  const sector = String(filters.sector || "").trim().toLowerCase();
  const marketCapBucket = String(filters.marketCapBucket || "").trim().toLowerCase();
  const sort = String(filters.sort || "").trim().toLowerCase();
  let items = [...(result.items || [])];
  if (sector) {
    items = items.filter((item) => String(item.sector || "").toLowerCase() === sector);
  }
  if (marketCapBucket) {
    items = items.filter((item) => String(item.marketCapBucket || "").toLowerCase() === marketCapBucket);
  }
  if (sort === "name") {
    items.sort((left, right) => left.displayName.localeCompare(right.displayName));
  } else if (sort === "symbol") {
    items.sort((left, right) => left.symbol.localeCompare(right.symbol));
  }
  return {
    ...result,
    count: items.length,
    items,
    filtersApplied: {
      sector: filters.sector || null,
      marketCapBucket: filters.marketCapBucket || null,
      sort: filters.sort || null,
    },
  };
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
    async () => ({
      ...fallback.predictionForSymbol(symbol),
      source: "fallback",
      modelVersion: "fallback-simulated-v1",
      explanation:
        "Fallback mode is active because the ML service is offline or unavailable. The confidence score comes from the deterministic simulation engine.",
      metrics: {
        sourceHealth: "offline",
      },
    }),
  );
}

async function getBacktest(symbol) {
  return withFallback(
    `getBacktest:${symbol}`,
    () => pythonClient.getBacktest(symbol),
    async () => ({
      symbol: String(symbol || "").toUpperCase(),
      companyName: fallback.quoteForSymbol(symbol).displayName,
      modelVersion: "fallback-simulated-v1",
      trainedAt: new Date().toISOString(),
      metrics: {
        mape: 12.8,
        directionalAccuracy: 0.63,
        directionalHitRate: 63,
        mae: 2.4,
        winLossRatio: 1.4,
        cumulativeReturnPct: 8.6,
      },
      evaluationWindows: 8,
      series: [
        { window: "W1", predictedReturnPct: 1.8, actualReturnPct: 1.2 },
        { window: "W2", predictedReturnPct: -0.6, actualReturnPct: -1.1 },
        { window: "W3", predictedReturnPct: 2.1, actualReturnPct: 1.6 },
      ],
      strategySummary: {
        label: "Fallback backtest",
        notes: ["Fallback mode is active because the ML service is offline."],
      },
      scenarioLab: {
        investmentAmount: 100000,
        horizonDays: 30,
        baseCaseValue: 106800,
        bullCaseValue: 113400,
        bearCaseValue: 95400,
        confidenceBand: {
          downsidePct: -4.6,
          basePct: 6.8,
          upsidePct: 13.4,
        },
      },
      provenance: {
        jobId: "fallback",
        quoteSource: "simulated",
      },
    }),
  );
}

async function getModelMonitoring() {
  return withFallback(
    "getModelMonitoring",
    () => pythonClient.getModelHealth(),
    async () => ({
      modelVersion: "fallback-simulated-v1",
      trainedAt: new Date().toISOString(),
      trainingUniverseSize: loadSymbolMaster().length,
      jobId: "fallback",
      quoteSourceHealth: {
        liveQuoteCacheFresh: false,
        historyCachePolicyMinutes: 180,
        quoteCachePolicySeconds: 90,
      },
      metrics: {
        averageMape: 12.1,
        averageDirectionalAccuracy: 64.2,
        driftScore: 0.18,
        cachedPredictions: 0,
      },
      datasetStatus: [
        { name: "NSE Equities", status: "Healthy" },
        { name: "Yahoo Quote Feed", status: "Fallback" },
        { name: "Feature Store", status: "Simulated" },
      ],
    }),
  );
}

function signalDirectionTone(direction) {
  const normalized = String(direction || "").toLowerCase();
  if (normalized.includes("buy")) return "bullish";
  if (normalized.includes("sell")) return "bearish";
  return "neutral";
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
      const compareSymbolsList = ["INFY", "TCS", "RELIANCE"];
      const snapshotSymbols = Array.from(
        new Set([
          ...compareSymbolsList,
          ...loadSymbolMaster().slice(0, 18).map((item) => item.symbol),
        ]),
      );
      const [quotes, predictions, comparePredictions] = await Promise.all([
        Promise.all(snapshotSymbols.map((symbol) => getQuote(symbol))),
        Promise.all(snapshotSymbols.slice(0, 4).map((symbol) => getPrediction(symbol))),
        Promise.all(compareSymbolsList.map((symbol) => getPrediction(symbol))),
      ]);
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
      const bullishPredictions = predictions
        .filter((item) => item.direction.toLowerCase().includes("buy"))
        .sort((left, right) => right.confidence - left.confidence);
      const screenerItems = bullishPredictions.map((prediction) => {
        const quote = quotes.find((item) => item.symbol === prediction.symbol);
        return {
          symbol: prediction.symbol,
          sector: quote?.sector || "Indian Equities",
          rsi14: 58 + bullishPredictions.indexOf(prediction) * 4,
          volatilityPct: Math.abs(quote?.changePct || 0) + 1.8,
          confidence: prediction.confidence,
          predictionBias: prediction.direction,
        };
      });
      const compareItems = compareSymbolsList.map((symbol) => {
        const quote = quotes.find((item) => item.symbol === symbol);
        const prediction =
          predictions.find((item) => item.symbol === symbol) ||
          comparePredictions.find((item) => item.symbol === symbol) ||
          bullishPredictions.find((item) => item.symbol === symbol);
        if (!quote || !prediction) {
          return null;
        }
        return {
          symbol: quote.symbol,
          displayName: quote.displayName,
          sector: quote.sector,
          peRatio: 18 + compareItemsSeed(symbol, "pe"),
          dividendYield: 0.8 + compareItemsSeed(symbol, "div") / 10,
          recommendationSummary:
            prediction.confidence >= 78
              ? "High conviction candidate"
              : prediction.confidence >= 66
                ? "Monitor for setup confirmation"
                : "Lower conviction, use caution",
          prediction: {
            confidence: prediction.confidence,
          },
        };
      }).filter(Boolean);
      const newsSentiment = predictions.slice(0, 4).map((item, index) => ({
        id: `headline_${index + 1}`,
        headline: `${item.symbol} ${item.direction.toLowerCase()} setup draws ${item.confidence >= 75 ? "constructive" : "measured"} attention`,
        sentiment: item.confidence >= 75 ? "Positive" : item.confidence >= 65 ? "Neutral" : "Cautious",
        score: Math.round(item.confidence),
        source: item.source === "live" ? "Live quote + model" : "EOD + model",
      }));

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
        screener: {
          title: "Advanced Screener",
          summary: "Large-cap bullish candidates filtered by dividend support, volatility, and model bias.",
          items: screenerItems,
          filtersApplied: 3,
        },
        compareWorkspace: {
          title: "Compare Workspace",
          summary: "Benchmark blue-chip leaders across prediction confidence, valuation, and volatility posture.",
          items: compareItems,
        },
        newsSentiment: {
          title: "News + Sentiment Layer",
          summary: "Lightweight headline sentiment generated from model direction, sector breadth, and market context.",
          items: newsSentiment,
        },
      };
    },
    () => fallback.buildAnalytics(),
  );
}

function compareItemsSeed(symbol, salt) {
  const value = String(symbol || "").length + String(salt || "").length;
  return Number((value * 1.7).toFixed(1));
}

async function getMarketMovers() {
  const snapshotSymbols = loadSymbolMaster().slice(0, 40).map((item) => item.symbol);
  const quotes = await Promise.all(snapshotSymbols.map((symbol) => getQuote(symbol)));
  const sorted = [...quotes].sort((left, right) => right.changePct - left.changePct);
  return {
    gainers: sorted.slice(0, 5),
    losers: [...sorted].reverse().slice(0, 5),
    timestamp: new Date().toISOString(),
  };
}

async function compareSymbols(symbols) {
  const requested = Array.from(
    new Set(
      symbols
        .map((item) => String(item || "").trim().toUpperCase())
        .filter(Boolean),
    ),
  ).slice(0, 5);
  const comparison = await Promise.all(
    requested.map(async (symbol) => {
      const [quote, company, prediction] = await Promise.all([
        getQuote(symbol),
        getCompany(symbol),
        getPrediction(symbol),
      ]);
      return {
        symbol: quote.symbol,
        displayName: quote.displayName,
        sector: quote.sector,
        price: quote.currentPrice,
        changePct: quote.changePct,
        peRatio: company.peRatio,
        dividendYield: company.dividendYield,
        marketCap: company.marketCap,
        volatilityPct: Number((((quote.high - quote.low) / Math.max(quote.currentPrice, 1)) * 100).toFixed(2)),
        prediction: {
          direction: prediction.direction,
          confidence: prediction.confidence,
          source: prediction.source || prediction.availability || "model",
        },
        recommendationSummary:
          prediction.confidence >= 78
            ? "High conviction candidate"
            : prediction.confidence >= 66
              ? "Monitor for setup confirmation"
              : "Lower conviction, use caution",
      };
    }),
  );
  return {
    symbols: comparison,
    comparedCount: comparison.length,
    summary: "Multi-stock benchmark spanning market structure, valuation proxies, and model conviction.",
  };
}

async function screenSymbols(filters = {}) {
  const limit = Number(filters.limit || 20);
  const sourceSymbols = loadSymbolMaster()
    .filter((item) => {
      if (filters.sector && item.sector !== filters.sector) return false;
      if (filters.marketCapBucket && item.marketCapBucket !== filters.marketCapBucket) return false;
      return true;
    })
    .slice(0, 60)
    .map((item) => item.symbol);

  const companies = await Promise.all(
    sourceSymbols.map(async (symbol) => {
      const [quote, company, prediction] = await Promise.all([getQuote(symbol), getCompany(symbol), getPrediction(symbol)]);
      const recentSignals = prediction.recentSignals || {};
      return {
        symbol: quote.symbol,
        displayName: quote.displayName,
        sector: quote.sector,
        marketCapBucket: quote.marketCapBucket,
        price: quote.currentPrice,
        changePct: quote.changePct,
        peRatio: company.peRatio,
        pbRatio: company.pbRatio,
        dividendYield: company.dividendYield,
        rsi14: Number(recentSignals.rsi14 || 50),
        volatilityPct: Number((((quote.high - quote.low) / Math.max(quote.currentPrice, 1)) * 100).toFixed(2)),
        predictionBias: signalDirectionTone(prediction.direction),
        confidence: prediction.confidence,
      };
    }),
  );

  const filtered = companies
    .filter((item) => (filters.minPe === undefined ? true : item.peRatio >= filters.minPe))
    .filter((item) => (filters.maxPe === undefined ? true : item.peRatio <= filters.maxPe))
    .filter((item) => (filters.minDividendYield === undefined ? true : item.dividendYield >= filters.minDividendYield))
    .filter((item) => (filters.minRsi === undefined ? true : item.rsi14 >= filters.minRsi))
    .filter((item) => (filters.maxVolatility === undefined ? true : item.volatilityPct <= filters.maxVolatility))
    .filter((item) => {
      if (!filters.predictionBias || filters.predictionBias === "any") return true;
      if (filters.predictionBias === "neutral_or_better") {
        return item.predictionBias === "bullish" || item.predictionBias === "neutral";
      }
      return item.predictionBias === filters.predictionBias;
    })
    .sort((left, right) => right.confidence - left.confidence)
    .slice(0, limit);

  return {
    count: filtered.length,
    items: filtered,
    filtersApplied: {
      sector: filters.sector || null,
      marketCapBucket: filters.marketCapBucket || null,
      minPe: filters.minPe ?? null,
      maxPe: filters.maxPe ?? null,
      minDividendYield: filters.minDividendYield ?? null,
      predictionBias: filters.predictionBias || null,
      minRsi: filters.minRsi ?? null,
      maxVolatility: filters.maxVolatility ?? null,
    },
  };
}

async function buildPortfolioRecommendations(user, portfolio, watchlistSymbols) {
  const holdings = portfolio.positions || [];
  const sectors = (portfolio.analytics?.exposureBySector || []).sort((left, right) => right.value - left.value);
  const topSector = sectors[0]?.sector || "Diversified";
  const watchlistCandidates = watchlistSymbols.slice(0, 3);
  const candidateQuotes = await Promise.all(
    watchlistCandidates.map(async (symbol) => {
      const prediction = await getPrediction(symbol);
      return {
        symbol,
        confidence: prediction.confidence,
        direction: prediction.direction,
      };
    }),
  );
  return {
    title: "Portfolio Recommendation Engine",
    modelPortfolios: [
      {
        profile: "Conservative",
        allocation: "45% leaders / 35% defensives / 20% cash",
        diversificationScore: 82,
        riskAdjustedReturn: "11.8%",
      },
      {
        profile: "Balanced",
        allocation: "55% leaders / 25% cyclicals / 20% cash",
        diversificationScore: 76,
        riskAdjustedReturn: "14.6%",
      },
      {
        profile: "Aggressive",
        allocation: "70% momentum / 20% rotation / 10% cash",
        diversificationScore: 64,
        riskAdjustedReturn: "18.9%",
      },
    ],
    rebalanceSuggestions: [
      `Current concentration is highest in ${topSector}. Consider rotating a portion into under-owned sectors if risk budget is tight.`,
      holdings.length < 4
        ? "Portfolio is still concentrated. Add 2-3 uncorrelated sectors to improve diversification."
        : "Diversification is reasonable; use alerts and screener presets to keep entries selective.",
      candidateQuotes.length
        ? `${candidateQuotes[0].symbol} currently shows the strongest watchlist conviction at ${candidateQuotes[0].confidence.toFixed(1)}% confidence.`
        : "Add more watchlist candidates to generate personalized allocation ideas.",
    ],
    snapshot: {
      holdingsCount: holdings.length,
      watchlistCoverage: watchlistSymbols.length,
      portfolioValue: user.portfolioValue,
    },
  };
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
  getBacktest,
  buildWatchlist,
  buildDashboard,
  buildAnalytics,
  buildStockDetails,
  buildPortfolioRecommendations,
  getMarketMovers,
  getModelMonitoring,
  compareSymbols,
  screenSymbols,
  pythonClient,
};
