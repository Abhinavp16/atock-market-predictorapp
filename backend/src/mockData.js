const nowIso = new Date().toISOString();

const user = {
  id: "usr_pradeep_kumar",
  name: "Pradeep Kumar",
  firstName: "Pradeep",
  email: "pradeep.kumar@lstminsight.in",
  role: "India Markets Pro",
  avatarInitials: "PK",
  location: "Bengaluru, India",
  memberSince: "2022",
  riskProfile: "Long-term growth with balanced risk",
  portfolioValue: 1845620.75,
  watchlistCount: 5,
  notificationCount: 3,
};

const onboarding = [
  {
    id: 1,
    title: "Predict Indian Markets with LSTM Intelligence.",
    kicker: "India-First Forecasting",
    description:
      "Harness Long Short-Term Memory neural networks to identify hidden patterns across NSE and BSE market data.",
    cta: "Get Started",
    stats: [
      { label: "Data Integrity", value: "98.2%" },
      { label: "Live Monitoring", value: "24/7" },
    ],
  },
  {
    id: 2,
    title: "Master NSE and BSE Predictive Analytics",
    kicker: "Live LSTM Stream",
    description:
      "Track confidence scores, sector signals, and model health from a mobile-first command center built for Indian equities.",
    highlights: [
      "NSE and BSE market coverage",
      "Transparent confidence metrics",
      "Signal-first trading workflows",
    ],
  },
  {
    id: 3,
    title: "Tailor your predictive engine.",
    kicker: "Personalized Setup",
    description:
      "Start with the Indian stocks you follow, then let the engine shape your workspace around momentum, valuation, and volatility.",
    assets: ["RELIANCE", "TCS", "INFY", "HDFCBANK"],
  },
];

const dashboard = {
  greeting: "Good morning, Pradeep",
  subtitle: "NSE and BSE intelligence with LSTM forecasts is updated.",
  searchPlaceholder: "Search NSE/BSE stock or AI signal...",
  liveCards: [
    {
      symbol: "RELIANCE",
      name: "Reliance Industries",
      price: 2948.35,
      changePct: 1.42,
      trend: "up",
      sparkline: [14, 12, 15, 13, 17, 19, 21],
      accent: "secondary",
    },
    {
      symbol: "TCS",
      name: "Tata Consultancy Services",
      price: 4021.6,
      changePct: -0.34,
      trend: "down",
      sparkline: [12, 15, 11, 13, 10, 8, 9],
      accent: "error",
    },
  ],
  aiPrediction: {
    symbol: "INFY",
    badge: "AI PREDICTION",
    title: "Strong Buy Signal",
    description:
      "LSTM models suggest a 6.8% upside over the next 14 trading days as IT spending sentiment improves.",
    confidence: 92.6,
  },
  trendingInsights: [
    {
      title: "Banking Breadth Remains Strong",
      description:
        "Private banks continue to show strong participation as domestic flows stay supportive.",
      age: "2h ago",
      icon: "rocket_launch",
      color: "secondary",
    },
    {
      title: "IT Export Sentiment Stabilises",
      description:
        "The model expects a near-term recovery in top IT names as order commentary improves.",
      age: "5h ago",
      icon: "energy_savings_leaf",
      color: "tertiary",
    },
    {
      title: "RBI Policy Impact Watch",
      description:
        "Deep learning analysis suggests rate-sensitive sectors may stay range-bound before the next policy cue.",
      age: "Yesterday",
      icon: "data_thresholding",
      color: "primary",
    },
  ],
  watchlistPreview: [
    { symbol: "HDFCBANK", name: "HDFC Bank", price: 1682.4, changePct: 0.84 },
    { symbol: "ICICIBANK", name: "ICICI Bank", price: 1218.75, changePct: 1.11 },
    { symbol: "SBIN", name: "State Bank of India", price: 842.3, changePct: -0.58 },
    { symbol: "LT", name: "Larsen & Toubro", price: 3671.5, changePct: 0.39 },
  ],
  featuredAnalysis: {
    label: "DEEP DIVE",
    title: "How LSTM Models Interpret Nifty 50 Sector Rotation",
    description:
      "A closer look at how recurrent neural networks can help decode leadership changes across Indian market sectors.",
  },
};

const watchlist = {
  title: "Active Watchlist",
  trackedCount: 5,
  searchPlaceholder: "Search NSE stocks and market themes...",
  assets: [
    {
      symbol: "RELIANCE",
      name: "Reliance Industries",
      price: 2948.35,
      changePct: 2.18,
      signal: "Strong Buy",
      signalTone: "positive",
      sparkline: [20, 18, 24, 12, 15, 8, 12, 5, 10, 2, 6],
    },
    {
      symbol: "TCS",
      name: "Tata Consultancy Services",
      price: 4021.6,
      changePct: 0.42,
      signal: "Neutral",
      signalTone: "neutral",
      sparkline: [15, 16, 14, 17, 15, 16],
    },
    {
      symbol: "INFY",
      name: "Infosys",
      price: 1468.55,
      changePct: 1.87,
      signal: "Buy",
      signalTone: "positive",
      sparkline: [8, 10, 9, 12, 13, 15, 16, 18, 17, 19, 21],
    },
    {
      symbol: "HDFCBANK",
      name: "HDFC Bank",
      price: 1682.4,
      changePct: -0.61,
      signal: "Neutral",
      signalTone: "neutral",
      sparkline: [28, 20, 10, 15, 5, 2],
    },
    {
      symbol: "SBIN",
      name: "State Bank of India",
      price: 842.3,
      changePct: 2.54,
      signal: "Strong Buy",
      signalTone: "positive",
      sparkline: [10, 12, 8, 14, 12, 10],
    },
  ],
  insight: {
    title: "LSTM Sentiment Analysis",
    description:
      "The neural models are observing constructive breadth across Indian banking and energy names. RELIANCE and INFY currently show strong predictive confidence.",
    cta: "View Detailed Report",
  },
};

const analytics = {
  title: "Market Analytics",
  sentiment: {
    score: 74,
    label: "Constructive Breadth",
    description:
      "Sentiment remains supportive across Indian banking, IT, and energy leaders as domestic participation stays healthy.",
  },
  sectors: [
    { name: "Banking", performance: 3.9 },
    { name: "IT", performance: 2.6 },
    { name: "Energy", performance: 1.8 },
    { name: "Pharma", performance: 1.1 },
  ],
  tradeVolume: [28, 34, 30, 42, 45, 41, 48],
  movers: [
    { symbol: "RELIANCE", movePct: 2.9, direction: "up" },
    { symbol: "INFY", movePct: 2.1, direction: "up" },
    { symbol: "HDFCBANK", movePct: -0.8, direction: "down" },
    { symbol: "LT", movePct: 1.6, direction: "up" },
  ],
  signal: {
    title: "LSTM Signal Detected",
    description:
      "The recurrent model is clustering strength around Indian banking and large-cap energy with stable volatility conditions.",
  },
};

const stockDetails = {
  symbol: "RELIANCE",
  companyName: "Reliance Industries",
  price: 2948.35,
  priceChange: 38.75,
  changePct: 1.33,
  predictionAccuracy: 88.4,
  predictionLabel: "Strong Buy Signal",
  predictionNote: "Based on 180-day sequential patterns in Indian market data",
  timeframeOptions: ["1D", "1W", "1M", "1Y", "ALL"],
  selectedTimeframe: "1D",
  candles: [
    { x: 50, open: 200, close: 160, high: 150, low: 210, tone: "up" },
    { x: 100, open: 180, close: 210, high: 170, low: 220, tone: "down" },
    { x: 150, open: 200, close: 140, high: 130, low: 210, tone: "up" },
    { x: 200, open: 180, close: 100, high: 90, low: 190, tone: "up" },
    { x: 250, open: 130, close: 150, high: 120, low: 160, tone: "down" },
    { x: 300, open: 150, close: 110, high: 100, low: 160, tone: "up" },
    { x: 350, open: 150, close: 80, high: 70, low: 160, tone: "up" },
  ],
  forecastPath: [
    { x: 400, y: 80 },
    { x: 450, y: 50 },
    { x: 500, y: 40 },
    { x: 600, y: 20 },
  ],
  availableCash: 425000,
  defaultInvestmentAmount: 25000,
  marketStats: [
    { label: "Market Cap", value: "₹19.95T" },
    { label: "P/E Ratio", value: "28.40" },
    { label: "Avg. Volume", value: "84.6L" },
    { label: "52W High", value: "₹3,024.90" },
  ],
  insights: [
    {
      title: "Trend Memory",
      icon: "hub",
      description:
        "The LSTM layer has identified a recurring accumulation zone similar to previous Nifty upswings, suggesting sustained strength over the next 14 trading days.",
    },
    {
      title: "Volatility Gating",
      icon: "data_exploration",
      description:
        "Forgetting gates are prioritizing fresh domestic flow data while filtering short-lived headline noise.",
    },
    {
      title: "Bias Estimation",
      icon: "psychology_alt",
      description:
        "Model confidence is at 88.4% based on a multi-year study of Indian large-cap sector rotations.",
    },
  ],
};

const predictions = {
  INFY: {
    symbol: "INFY",
    companyName: "Infosys",
    currentPrice: 1468.55,
    sevenDayForecast: [
      { day: "Mon", value: 1472.2 },
      { day: "Tue", value: 1478.8 },
      { day: "Wed", value: 1484.6 },
      { day: "Thu", value: 1491.4 },
      { day: "Fri", value: 1498.2 },
      { day: "Sat", value: 1501.1 },
      { day: "Sun", value: 1504.7 },
    ],
    confidence: 92.6,
    direction: "Strong Buy",
    synthesis:
      "Oracle synthesis suggests improving deal momentum and stable rupee trends could support near-term upside in Indian IT.",
    factors: [
      { label: "Order Book Strength", score: 0.76 },
      { label: "Margin Stability", score: 0.68 },
      { label: "Sector Momentum", score: 0.72 },
    ],
  },
  RELIANCE: {
    symbol: "RELIANCE",
    companyName: "Reliance Industries",
    currentPrice: 2948.35,
    sevenDayForecast: [
      { day: "Mon", value: 2954.1 },
      { day: "Tue", value: 2961.6 },
      { day: "Wed", value: 2970.2 },
      { day: "Thu", value: 2978.8 },
      { day: "Fri", value: 2986.4 },
      { day: "Sat", value: 2991.3 },
      { day: "Sun", value: 2996.8 },
    ],
    confidence: 89.3,
    direction: "Buy",
    synthesis:
      "Oracle synthesis suggests continued strength in energy and retail narratives with supportive domestic fund participation.",
    factors: [
      { label: "Domestic Flow Support", score: 0.81 },
      { label: "Earnings Bias", score: 0.63 },
      { label: "Sector Leadership", score: 0.74 },
    ],
  },
  TCS: {
    symbol: "TCS",
    companyName: "Tata Consultancy Services",
    currentPrice: 4021.6,
    sevenDayForecast: [
      { day: "Mon", value: 4016.8 },
      { day: "Tue", value: 4009.2 },
      { day: "Wed", value: 4014.7 },
      { day: "Thu", value: 4028.4 },
      { day: "Fri", value: 4042.1 },
      { day: "Sat", value: 4048.6 },
      { day: "Sun", value: 4056.3 },
    ],
    confidence: 78.4,
    direction: "Neutral",
    synthesis:
      "Oracle synthesis suggests a range-bound setup until fresh commentary from major client geographies provides directional conviction.",
    factors: [
      { label: "Revenue Visibility", score: 0.52 },
      { label: "Sentiment Flux", score: 0.18 },
      { label: "Valuation Support", score: 0.44 },
    ],
  },
};

const notifications = {
  title: "Notifications",
  items: [
    {
      id: "notif_1",
      type: "prediction",
      title: "AI Prediction Update",
      message: "INFY confidence increased to 92.6% after stronger-than-expected deal commentary.",
      time: "5m ago",
      unread: true,
    },
    {
      id: "notif_2",
      type: "alert",
      title: "Stock Alert: RELIANCE",
      message: "Reliance is holding above key support with bullish momentum on rising volume.",
      time: "22m ago",
      unread: true,
    },
    {
      id: "notif_3",
      type: "system",
      title: "Model Retraining Complete",
      message: "The core sequence model finished retraining on the latest NSE banking and IT data.",
      time: "1h ago",
      unread: false,
    },
    {
      id: "notif_4",
      type: "security",
      title: "Login Detected",
      message: "Your account was accessed from a trusted Bengaluru device.",
      time: "Yesterday",
      unread: false,
    },
  ],
  upgradeCard: {
    title: "Unlock Deep Correlation Analysis",
    description:
      "Upgrade to access multi-factor LSTM overlays, scenario clustering, and institution-style market reports for Indian equities.",
  },
};

const profile = {
  ...user,
  bio: "Independent market participant focused on high-conviction Indian large-cap and sector rotation trades.",
  tierDescription: "Priority model access, deeper reports, and enhanced notification controls for India-first market workflows.",
  stats: [
    { label: "Prediction Accuracy", value: "91.7%" },
    { label: "Signals Followed", value: "128" },
    { label: "Watchlist Wins", value: "67%" },
  ],
  insights: [
    "Strong preference for Indian large-cap leaders",
    "Highest conviction in banking, IT, and energy sectors",
    "Model usage peaks during earnings season and RBI policy windows",
  ],
  security: [
    "Two-factor authentication enabled",
    "Biometric unlock active on this device",
    "API access scoped to read-only analytics",
  ],
};

const settings = {
  sections: [
    {
      title: "Account Security",
      items: [
        { label: "Two-factor authentication", value: true, kind: "toggle" },
        { label: "Biometric unlock", value: true, kind: "toggle" },
        { label: "Trusted devices", value: "3 active", kind: "detail" },
      ],
    },
    {
      title: "Notifications",
      items: [
        { label: "Prediction alerts", value: true, kind: "toggle" },
        { label: "Market movers", value: true, kind: "toggle" },
        { label: "Security alerts", value: true, kind: "toggle" },
      ],
    },
    {
      title: "Display & Theme",
      items: [
        { label: "Appearance", value: "Light", kind: "detail" },
        { label: "Compact charts", value: false, kind: "toggle" },
      ],
    },
    {
      title: "API & Data",
      items: [
        { label: "Environment", value: "Sandbox", kind: "detail" },
        { label: "Auto-refresh", value: true, kind: "toggle" },
      ],
    },
  ],
  upgradeCard: {
    title: "Upgrade to Pro Predictive",
    description: "Unlock deeper model diagnostics and custom automations for your Indian market watchlists.",
    cta: "Upgrade Now",
  },
};

const admin = {
  title: "System Administrator Dashboard",
  subtitle: "Monitor platform health, active Indian market data feeds, and LSTM model infrastructure.",
  topMetrics: [
    { label: "Active Users", value: "12.4K", trend: "+4.8%" },
    { label: "Inference Jobs", value: "84.1K", trend: "+8.2%" },
    { label: "Model Health", value: "Optimal", trend: "Stable" },
    { label: "Alert Volume", value: "132", trend: "-2.1%" },
  ],
  serverLoad: [48, 52, 44, 63, 58, 61, 56],
  modelMetrics: [
    { label: "Precision", value: "0.92" },
    { label: "Recall", value: "0.88" },
    { label: "Drift Score", value: "0.04" },
  ],
  datasetStatus: [
    { name: "NSE Equities", status: "Healthy" },
    { name: "BSE Midcaps", status: "Healthy" },
    { name: "RBI Macro Feed", status: "Syncing" },
  ],
  systemEvents: [
    { time: "18:40", message: "Mumbai inference worker pool scaled to 24 nodes." },
    { time: "18:22", message: "Indian banking model retraining completed." },
    { time: "18:05", message: "Latency alert resolved on the NSE derivatives feed." },
  ],
};

const splash = {
  title: "Oracle AI",
  subtitle: "Smart Stock Prediction Powered by LSTM Intelligence",
  ctas: ["Get Started", "View Live Market"],
  stats: [
    { label: "Model Accuracy", value: "98.4%" },
    { label: "Assets Tracked", value: "500+" },
    { label: "LSTM Processing", value: "Real-time" },
  ],
};

const appState = {
  settings,
  watchlist,
};

module.exports = {
  nowIso,
  user,
  onboarding,
  splash,
  dashboard,
  watchlist,
  analytics,
  stockDetails,
  predictions,
  notifications,
  profile,
  settings,
  admin,
  appState,
};
