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
  notificationCount: 4,
};

const onboarding = [
  {
    id: 1,
    title: "Track Indian equities with AI-native market intelligence.",
    kicker: "India-First Coverage",
    description:
      "Browse a broad NSE equity universe, monitor sector rotation, and surface opportunities using a market app designed for Indian investors.",
    cta: "Get Started",
    stats: [
      { label: "Coverage", value: "200+ equities" },
      { label: "Refresh Cycle", value: "Daily EOD" },
    ],
  },
  {
    id: 2,
    title: "Prediction workflows built for NSE and BSE market behaviour.",
    kicker: "Shared Market Model",
    description:
      "Combine broad market data, benchmark context, and machine-learning forecasts inside a mobile-first workflow for Indian stocks.",
    highlights: [
      "Searchable Indian equity catalog",
      "Dynamic quotes and chart history",
      "Prediction confidence with factor overlays",
    ],
  },
  {
    id: 3,
    title: "Shape your workspace around the shares you follow.",
    kicker: "Personalized Setup",
    description:
      "Start with large-cap Indian leaders, then build a watchlist around sectors, momentum, and daily model refreshes.",
    assets: ["RELIANCE", "TCS", "INFY", "HDFCBANK"],
  },
];

const splash = {
  title: "Oracle AI",
  subtitle: "Smart Stock Prediction Powered by LSTM Intelligence",
  ctas: ["Get Started", "View Live Market"],
  stats: [
    { label: "Universe", value: "200+ stocks" },
    { label: "Predictions", value: "7-Day Outlook" },
    { label: "Market Focus", value: "India EOD" },
  ],
};

const notifications = {
  title: "Notifications",
  items: [
    {
      id: "notif_1",
      type: "prediction",
      title: "Prediction Refresh Ready",
      message:
        "The daily market model has refreshed forecasts for the supported Indian equity universe.",
      time: "8m ago",
      unread: true,
    },
    {
      id: "notif_2",
      type: "alert",
      title: "Watchlist Breadth Alert",
      message:
        "Banking and IT names in your watchlist are showing improving breadth on the latest close.",
      time: "25m ago",
      unread: true,
    },
    {
      id: "notif_3",
      type: "system",
      title: "Data Sync Complete",
      message:
        "NSE daily quote, chart, and company snapshots finished syncing for the current market cycle.",
      time: "1h ago",
      unread: false,
    },
    {
      id: "notif_4",
      type: "security",
      title: "Trusted Device Access",
      message: "Your account was accessed from a trusted Bengaluru Android device.",
      time: "Yesterday",
      unread: false,
    },
  ],
  upgradeCard: {
    title: "Unlock Deeper India Market Analysis",
    description:
      "Upgrade to access broader screening, premium factor breakdowns, and advanced workflow automations for Indian equities.",
  },
};

const profile = {
  ...user,
  bio: "Independent market participant focused on Indian large-cap leadership, sector rotation, and AI-assisted decision support.",
  tierDescription:
    "Priority access to broader Indian equity coverage, advanced factor summaries, and richer market notifications.",
  stats: [
    { label: "Prediction Accuracy", value: "89.8%" },
    { label: "Tracked Symbols", value: "200+" },
    { label: "Watchlist Wins", value: "67%" },
  ],
  insights: [
    "Prefers Indian large-cap and liquid sector leaders",
    "Highest conviction around banking, IT, energy, and capital goods",
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
    description:
      "Unlock deeper model diagnostics, more catalog filters, and richer automations for Indian market watchlists.",
    cta: "Upgrade Now",
  },
};

const admin = {
  title: "System Administrator Dashboard",
  subtitle: "Monitor platform health, active Indian market data feeds, and model infrastructure.",
  topMetrics: [
    { label: "Active Users", value: "12.4K", trend: "+4.8%" },
    { label: "Inference Jobs", value: "84.1K", trend: "+8.2%" },
    { label: "Model Health", value: "Optimal", trend: "Stable" },
    { label: "Alert Volume", value: "132", trend: "-2.1%" },
  ],
  serverLoad: [48, 52, 44, 63, 58, 61, 56],
  modelMetrics: [
    { label: "Precision", value: "0.91" },
    { label: "Recall", value: "0.87" },
    { label: "Drift Score", value: "0.05" },
  ],
  datasetStatus: [
    { name: "NSE Equities", status: "Healthy" },
    { name: "BSE Midcaps", status: "Healthy" },
    { name: "RBI Macro Feed", status: "Syncing" },
  ],
  systemEvents: [
    { time: "18:40", message: "Prediction cache refreshed for the Indian equity universe." },
    { time: "18:22", message: "Shared market model retraining completed successfully." },
    { time: "18:05", message: "Latency alert resolved on the benchmark data adapter." },
  ],
};

const appState = {
  settings,
  watchlistSymbols: ["RELIANCE", "TCS", "INFY", "HDFCBANK", "SBIN"],
};

module.exports = {
  nowIso,
  user,
  onboarding,
  splash,
  notifications,
  profile,
  settings,
  admin,
  appState,
};
