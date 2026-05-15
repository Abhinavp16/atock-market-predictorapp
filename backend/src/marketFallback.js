const { findSymbolMeta, loadSymbolMaster } = require("./symbolMaster");

const DEFAULT_LOOKBACK_DAYS = 320;
const CHART_RANGE_TO_DAYS = {
  "1W": 5,
  "1M": 22,
  "3M": 66,
  "6M": 132,
  "1Y": 252,
  ALL: DEFAULT_LOOKBACK_DAYS,
};

const HEADQUARTERS = [
  "Mumbai, India",
  "Bengaluru, India",
  "Hyderabad, India",
  "Chennai, India",
  "Pune, India",
  "Ahmedabad, India",
  "Gurugram, India",
  "Noida, India",
];

const sectorProfiles = {
  "Banking & Financials": { drift: 0.0007, volatility: 0.016, basePrice: 1240, baseVolume: 5400000 },
  IT: { drift: 0.0006, volatility: 0.015, basePrice: 1840, baseVolume: 2800000 },
  Energy: { drift: 0.0008, volatility: 0.018, basePrice: 2280, baseVolume: 4200000 },
  Healthcare: { drift: 0.0005, volatility: 0.014, basePrice: 1620, baseVolume: 1800000 },
  Power: { drift: 0.00075, volatility: 0.017, basePrice: 980, baseVolume: 3000000 },
  Telecom: { drift: 0.00055, volatility: 0.013, basePrice: 1320, baseVolume: 3500000 },
  "Capital Goods": { drift: 0.00072, volatility: 0.016, basePrice: 1980, baseVolume: 2300000 },
  Metals: { drift: 0.00045, volatility: 0.021, basePrice: 860, baseVolume: 4400000 },
  Services: { drift: 0.00058, volatility: 0.014, basePrice: 1460, baseVolume: 2500000 },
  Diversified: { drift: 0.0006, volatility: 0.015, basePrice: 1540, baseVolume: 2400000 },
};

const seriesCache = new Map();

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function average(values) {
  if (!values.length) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function hashString(value) {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function mulberry32(seed) {
  return () => {
    let t = (seed += 0x6d2b79f5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function lastBusinessDays(count) {
  const days = [];
  const cursor = new Date();
  cursor.setHours(0, 0, 0, 0);

  while (days.length < count) {
    const dayOfWeek = cursor.getDay();
    if (dayOfWeek !== 0 && dayOfWeek !== 6) {
      days.unshift(new Date(cursor));
    }
    cursor.setDate(cursor.getDate() - 1);
  }

  return days;
}

function number(value, digits = 2) {
  return Number(value.toFixed(digits));
}

function compactIndianNumber(value) {
  const abs = Math.abs(value);
  if (abs >= 10000000) return `₹${number(value / 10000000)}Cr`;
  if (abs >= 100000) return `₹${number(value / 100000)}L`;
  return `₹${number(value)}`;
}

function seriesForSymbol(symbol) {
  const normalized = String(symbol || "").toUpperCase();
  if (seriesCache.has(normalized)) {
    return seriesCache.get(normalized);
  }

  const meta = findSymbolMeta(normalized);
  if (!meta) {
    throw new Error(`Unsupported symbol ${normalized}`);
  }

  const seed = hashString(`${meta.symbol}:${meta.sector}`);
  const random = mulberry32(seed);
  const profile = sectorProfiles[meta.sector] || sectorProfiles.Diversified;
  const days = lastBusinessDays(DEFAULT_LOOKBACK_DAYS);
  const sectorTilt = ((seed % 19) - 9) / 10000;
  const basePrice =
    profile.basePrice + (seed % 1400) + (meta.marketCapBucket === "Large Cap" ? 800 : 0);
  const baseVolume = profile.baseVolume + ((seed % 900000) * 10);

  let close = basePrice;
  const series = days.map((date, index) => {
    const marketWave = Math.sin(index / 11 + (seed % 13)) * 0.0045;
    const longCycle = Math.cos(index / 39 + (seed % 7)) * 0.0032;
    const randomShock = (random() - 0.5) * profile.volatility * 1.4;
    const dailyReturn = profile.drift + sectorTilt + marketWave + longCycle + randomShock;
    const open = close * (1 + (random() - 0.5) * profile.volatility * 0.4);
    const nextClose = Math.max(40, close * (1 + dailyReturn));
    const high = Math.max(open, nextClose) * (1 + random() * profile.volatility * 0.45);
    const low = Math.min(open, nextClose) * (1 - random() * profile.volatility * 0.45);
    const volumeBoost = 1 + Math.abs(dailyReturn) * 18 + (random() - 0.5) * 0.12;
    const volume = Math.round(baseVolume * volumeBoost);
    close = nextClose;

    return {
      date: date.toISOString().slice(0, 10),
      open: number(open),
      high: number(high),
      low: number(low),
      close: number(nextClose),
      volume,
    };
  });

  seriesCache.set(normalized, series);
  return series;
}

function quoteForSymbol(symbol) {
  const meta = findSymbolMeta(symbol);
  if (!meta) {
    throw new Error(`Unsupported symbol ${symbol}`);
  }

  const series = seriesForSymbol(symbol);
  const latest = series[series.length - 1];
  const previous = series[series.length - 2] || latest;
  const change = latest.close - previous.close;
  const changePct = previous.close === 0 ? 0 : (change / previous.close) * 100;

  return {
    symbol: meta.symbol,
    exchange: meta.exchange,
    displayName: meta.displayName,
    sector: meta.sector,
    marketCapBucket: meta.marketCapBucket,
    currency: "INR",
    currentPrice: number(latest.close),
    previousClose: number(previous.close),
    change: number(change),
    changePct: number(changePct),
    open: latest.open,
    high: latest.high,
    low: latest.low,
    volume: latest.volume,
    timestamp: latest.date,
    sparkline: series.slice(-7).map((point) => point.close),
  };
}

function chartForSymbol(symbol, range = "1M") {
  const meta = findSymbolMeta(symbol);
  if (!meta) {
    throw new Error(`Unsupported symbol ${symbol}`);
  }

  const normalizedRange = String(range || "1M").toUpperCase();
  const days = CHART_RANGE_TO_DAYS[normalizedRange] || CHART_RANGE_TO_DAYS["1M"];
  const series = seriesForSymbol(symbol).slice(-days);

  return {
    symbol: meta.symbol,
    exchange: meta.exchange,
    range: normalizedRange,
    series,
  };
}

function companyForSymbol(symbol) {
  const meta = findSymbolMeta(symbol);
  if (!meta) {
    throw new Error(`Unsupported symbol ${symbol}`);
  }

  const series = seriesForSymbol(symbol);
  const closes = series.map((point) => point.close);
  const volumes = series.slice(-20).map((point) => point.volume);
  const latest = closes[closes.length - 1];
  const week52High = Math.max(...closes.slice(-252));
  const week52Low = Math.min(...closes.slice(-252));
  const sharesOutstanding = 400000000 + (hashString(symbol) % 5000000000);
  const peRatio = 16 + (hashString(`${symbol}:pe`) % 1900) / 100;
  const pbRatio = 1.8 + (hashString(`${symbol}:pb`) % 450) / 100;
  const dividendYield = ((hashString(`${symbol}:div`) % 350) / 100).toFixed(2);

  return {
    symbol: meta.symbol,
    exchange: meta.exchange,
    displayName: meta.displayName,
    sector: meta.sector,
    industry: meta.industry,
    marketCapBucket: meta.marketCapBucket,
    currency: "INR",
    headquarters: HEADQUARTERS[hashString(symbol) % HEADQUARTERS.length],
    description: `${meta.displayName} is part of the supported Indian equity universe, with ${meta.sector.toLowerCase()} exposure and daily end-of-day market monitoring inside the app.`,
    marketCap: Math.round(latest * sharesOutstanding),
    peRatio: number(peRatio),
    pbRatio: number(pbRatio),
    dividendYield: Number(dividendYield),
    week52High: number(week52High),
    week52Low: number(week52Low),
    avgVolume20: Math.round(average(volumes)),
  };
}

function latestSignals(symbol) {
  const series = seriesForSymbol(symbol);
  const closes = series.map((point) => point.close);
  const latest = closes[closes.length - 1];
  const return5 = latest / closes[closes.length - 6] - 1;
  const return20 = latest / closes[closes.length - 21] - 1;
  const volatility = Math.sqrt(
    average(
      closes.slice(-20).map((close, index, arr) => {
        if (index === 0) return 0;
        const previous = arr[index - 1];
        return Math.pow(close / previous - 1, 2);
      }),
    ),
  );
  const sma10 = average(closes.slice(-10));
  const sma20 = average(closes.slice(-20));
  const sma50 = average(closes.slice(-50));
  const momentum = clamp(return5 * 6 + return20 * 4, -1, 1);
  const trendStrength = clamp((sma20 / sma50 - 1) * 10, -1, 1);
  const volatilityRisk = clamp(-(volatility * 50 - 0.4), -1, 1);

  return {
    latest,
    return5,
    return20,
    volatility,
    sma10,
    sma20,
    sma50,
    momentum,
    trendStrength,
    volatilityRisk,
  };
}

function directionForProjectedMove(projectedMovePct) {
  if (projectedMovePct >= 4.5) return "Strong Buy";
  if (projectedMovePct >= 1.5) return "Buy";
  if (projectedMovePct <= -4.5) return "Strong Sell";
  if (projectedMovePct <= -1.5) return "Sell";
  return "Neutral";
}

function predictionForSymbol(symbol) {
  const quote = quoteForSymbol(symbol);
  const meta = findSymbolMeta(symbol);
  const signals = latestSignals(symbol);
  const bias =
    signals.return20 * 0.55 + signals.return5 * 0.3 + signals.trendStrength * 0.015 + signals.volatilityRisk * 0.01;
  const forecast = [];
  let value = quote.currentPrice;

  for (let index = 0; index < 7; index += 1) {
    const dayBias = bias / 7 + Math.sin(index / 2 + hashString(symbol) % 5) * 0.0018;
    value = value * (1 + dayBias);
    forecast.push(value);
  }

  const projectedMovePct = ((forecast[forecast.length - 1] - quote.currentPrice) / quote.currentPrice) * 100;
  const confidence = clamp(72 + Math.abs(projectedMovePct) * 2.2 + signals.volatilityRisk * 8, 61, 95);
  const direction = directionForProjectedMove(projectedMovePct);

  return {
    symbol: quote.symbol,
    companyName: meta.displayName,
    currentPrice: quote.currentPrice,
    sevenDayForecast: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day, index) => ({
      day,
      value: number(forecast[index]),
    })),
    confidence: number(confidence),
    direction,
    synthesis:
      `${meta.displayName} is being scored with a ${direction.toLowerCase()} bias based on recent ${meta.sector.toLowerCase()} momentum, 20-day trend structure, and volatility conditions in the supported Indian market universe.`,
    factors: [
      { label: "Momentum", score: number(signals.momentum) },
      { label: "Trend Strength", score: number(signals.trendStrength) },
      { label: "Volatility Risk", score: number(signals.volatilityRisk) },
    ],
    availability: "fallback",
  };
}

function searchSymbols(query = "", limit = 20) {
  const normalized = String(query || "").trim().toLowerCase();
  const matches = loadSymbolMaster()
    .filter((item) => {
      if (!normalized) return true;
      return (
        item.symbol.toLowerCase().includes(normalized) ||
        item.displayName.toLowerCase().includes(normalized) ||
        item.sector.toLowerCase().includes(normalized)
      );
    })
    .slice(0, limit)
    .map((item) => ({
      exchange: item.exchange,
      symbol: item.symbol,
      displayName: item.displayName,
      sector: item.sector,
      marketCapBucket: item.marketCapBucket,
      active: item.active,
    }));

  return {
    query,
    count: matches.length,
    items: matches,
  };
}

function watchlistAsset(symbol) {
  const quote = quoteForSymbol(symbol);
  const prediction = predictionForSymbol(symbol);
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
    sparkline: quote.sparkline,
  };
}

function buildWatchlist(symbols) {
  const assets = symbols.map(watchlistAsset);
  return {
    title: "Active Watchlist",
    trackedCount: assets.length,
    searchPlaceholder: "Search NSE stocks, sectors, or company names...",
    assets,
    insight: {
      title: "Market Breadth Snapshot",
      description:
        "Watchlist signals are now derived from the broader Indian equity universe, combining daily quotes, sector context, and model-backed directional scores.",
      cta: "View Detailed Report",
    },
  };
}

function buildDashboard(user, watchlistSymbols) {
  const highlighted = ["RELIANCE", "TCS", "INFY", "HDFCBANK", "SBIN", "ICICIBANK", "LT"];
  const liveCards = highlighted.slice(0, 2).map((symbol, index) => {
    const quote = quoteForSymbol(symbol);
    return {
      symbol: quote.symbol,
      name: quote.displayName,
      price: quote.currentPrice,
      changePct: quote.changePct,
      trend: quote.changePct >= 0 ? "up" : "down",
      sparkline: quote.sparkline,
      accent: index === 0 ? "secondary" : quote.changePct >= 0 ? "primary" : "error",
    };
  });

  const heroPrediction = predictionForSymbol("INFY");
  const watchlistPreview = watchlistSymbols.slice(0, 4).map((symbol) => {
    const quote = quoteForSymbol(symbol);
    return {
      symbol: quote.symbol,
      name: quote.displayName,
      price: quote.currentPrice,
      changePct: quote.changePct,
    };
  });

  const trendingSymbols = highlighted
    .map((symbol) => ({ symbol, quote: quoteForSymbol(symbol), prediction: predictionForSymbol(symbol) }))
    .sort((left, right) => Math.abs(right.quote.changePct) - Math.abs(left.quote.changePct))
    .slice(0, 3);

  return {
    greeting: `Good morning, ${user.firstName}`,
    subtitle: "Broad Indian equity coverage and daily model refreshes are ready.",
    searchPlaceholder: "Search NSE stock, sector, or company...",
    liveCards,
    aiPrediction: {
      symbol: heroPrediction.symbol,
      badge: "AI PREDICTION",
      title: `${heroPrediction.direction} Signal`,
      description: heroPrediction.synthesis,
      confidence: heroPrediction.confidence,
    },
    trendingInsights: trendingSymbols.map((item, index) => ({
      title: `${item.symbol} ${item.quote.changePct >= 0 ? "Outperforming" : "Cooling Off"}`,
      description:
        `${item.quote.displayName} is showing ${item.prediction.direction.toLowerCase()} conditions with ${item.quote.sector.toLowerCase()} leadership inside the latest Indian market cycle.`,
      age: index === 0 ? "20m ago" : index === 1 ? "2h ago" : "Today",
      icon: index === 0 ? "rocket_launch" : index === 1 ? "energy_savings_leaf" : "data_thresholding",
      color: index === 0 ? "secondary" : index === 1 ? "primary" : "tertiary",
    })),
    watchlistPreview,
    featuredAnalysis: {
      label: "DEEP DIVE",
      title: "How the shared market model ranks Indian sector leadership",
      description:
        "A wider Indian equity catalog now feeds daily quote, history, and benchmark-aware prediction workflows directly into the app.",
    },
  };
}

function buildAnalytics() {
  const sectorMap = new Map();
  const movers = loadSymbolMaster()
    .slice(0, 40)
    .map((item) => quoteForSymbol(item.symbol));

  movers.forEach((quote) => {
    const entry = sectorMap.get(quote.sector) || [];
    entry.push(quote.changePct);
    sectorMap.set(quote.sector, entry);
  });

  const sectors = Array.from(sectorMap.entries())
    .map(([name, values]) => ({
      name,
      performance: number(average(values)),
    }))
    .sort((left, right) => right.performance - left.performance)
    .slice(0, 4);

  const topMovers = [...movers]
    .sort((left, right) => Math.abs(right.changePct) - Math.abs(left.changePct))
    .slice(0, 4)
    .map((quote) => ({
      symbol: quote.symbol,
      movePct: number(Math.abs(quote.changePct)),
      direction: quote.changePct >= 0 ? "up" : "down",
    }));

  const sentimentScore = clamp(
    55 + average(sectors.map((item) => item.performance)) * 4 + topMovers.filter((item) => item.direction === "up").length * 3,
    35,
    92,
  );

  return {
    title: "Market Analytics",
    sentiment: {
      score: Math.round(sentimentScore),
      label: sentimentScore >= 70 ? "Constructive Breadth" : sentimentScore >= 55 ? "Balanced Breadth" : "Cautious Breadth",
      description:
        "The analytics layer is derived from the broader Indian equity catalog, tracking sector rotation, movers, and benchmark-aware model context.",
    },
    sectors,
    tradeVolume: movers.slice(0, 7).map((quote) => number(quote.volume / 100000)),
    movers: topMovers,
    signal: {
      title: "Shared Market Model Signal",
      description:
        "Current signals are clustering around broad Indian sector leadership, with direction and confidence shaped by trend persistence and volatility compression.",
    },
  };
}

function buildStockDetails(symbol) {
  const quote = quoteForSymbol(symbol);
  const company = companyForSymbol(symbol);
  const prediction = predictionForSymbol(symbol);
  const chart = chartForSymbol(symbol, "1M").series.slice(-7);
  const combined = [...chart.map((point) => point.low), ...chart.map((point) => point.high), ...prediction.sevenDayForecast.map((point) => point.value)];
  const minValue = Math.min(...combined);
  const maxValue = Math.max(...combined);
  const scaleY = (value) => {
    if (maxValue === minValue) return 140;
    const normalized = (value - minValue) / (maxValue - minValue);
    return number(250 - normalized * 170);
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
    candles: chart.map((point, index) => ({
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
      { label: "Market Cap", value: compactIndianNumber(company.marketCap) },
      { label: "P/E Ratio", value: company.peRatio.toFixed(2) },
      { label: "Avg. Volume", value: `${number(company.avgVolume20 / 100000, 1)}L` },
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
    company,
    quote,
  };
}

module.exports = {
  searchSymbols,
  quoteForSymbol,
  chartForSymbol,
  companyForSymbol,
  predictionForSymbol,
  buildWatchlist,
  buildDashboard,
  buildAnalytics,
  buildStockDetails,
};
