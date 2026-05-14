const express = require("express");
const cors = require("cors");
const {
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
} = require("./mockData");

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

app.get("/api/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "lstm-insight-backend",
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/bootstrap", (_req, res) => {
  res.json({
    splash,
    onboarding,
    user,
    nav: [
      { key: "home", label: "Home", icon: "home" },
      { key: "market", label: "Market", icon: "query_stats" },
      { key: "predict", label: "Predict", icon: "online_prediction" },
      { key: "watch", label: "Watch", icon: "visibility" },
      { key: "profile", label: "Profile", icon: "person" },
    ],
  });
});

app.post("/api/auth/login", (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required." });
  }

  return res.json({
    token: "mock-jwt-token",
    user,
    message: "Login successful.",
  });
});

app.post("/api/auth/register", (req, res) => {
  const { fullName, email, password } = req.body ?? {};
  if (!fullName || !email || !password) {
    return res.status(400).json({ message: "Full name, email, and password are required." });
  }

  return res.status(201).json({
    token: "mock-jwt-token",
    user: { ...user, name: fullName, email },
    message: "Registration successful.",
  });
});

app.get("/api/dashboard", (_req, res) => {
  res.json(dashboard);
});

app.get("/api/watchlist", (_req, res) => {
  res.json(appState.watchlist);
});

app.post("/api/watchlist", (req, res) => {
  const { symbol, name, price } = req.body ?? {};
  if (!symbol || !name || typeof price !== "number") {
    return res.status(400).json({ message: "symbol, name, and numeric price are required." });
  }

  const asset = {
    symbol: symbol.toUpperCase(),
    name,
    price,
    changePct: 0.0,
    signal: "Watch",
    signalTone: "neutral",
    sparkline: [12, 12, 12, 12, 12],
  };
  appState.watchlist.assets.unshift(asset);
  appState.watchlist.trackedCount = appState.watchlist.assets.length;
  return res.status(201).json(asset);
});

app.get("/api/market/analytics", (_req, res) => {
  res.json(analytics);
});

app.get("/api/stocks/:symbol", (req, res) => {
  const symbol = String(req.params.symbol || "").toUpperCase();
  if (symbol === stockDetails.symbol) {
    return res.json(stockDetails);
  }

  const watchAsset = appState.watchlist.assets.find((asset) => asset.symbol === symbol);
  if (!watchAsset) {
    return res.status(404).json({ message: `No stock details found for ${symbol}.` });
  }

  return res.json({
    ...stockDetails,
    symbol: watchAsset.symbol,
    companyName: watchAsset.name,
    price: watchAsset.price,
    changePct: watchAsset.changePct,
    priceChange: Number(((watchAsset.price * watchAsset.changePct) / 100).toFixed(2)),
  });
});

app.get("/api/predictions/:symbol", (req, res) => {
  const symbol = String(req.params.symbol || "").toUpperCase();
  const result = predictions[symbol];
  if (!result) {
    return res.status(404).json({ message: `No prediction data found for ${symbol}.` });
  }
  return res.json(result);
});

app.post("/api/trade", (req, res) => {
  const { symbol, side, amount } = req.body ?? {};
  if (!symbol || !side || typeof amount !== "number") {
    return res.status(400).json({ message: "symbol, side, and numeric amount are required." });
  }

  return res.status(201).json({
    id: `trade_${Date.now()}`,
    symbol: String(symbol).toUpperCase(),
    side,
    amount,
    status: "filled",
    executedAt: new Date().toISOString(),
  });
});

app.get("/api/notifications", (_req, res) => {
  res.json(notifications);
});

app.get("/api/profile", (_req, res) => {
  res.json(profile);
});

app.get("/api/settings", (_req, res) => {
  res.json(appState.settings);
});

app.patch("/api/settings", (req, res) => {
  const { sectionTitle, itemLabel, value } = req.body ?? {};
  const section = appState.settings.sections.find((item) => item.title === sectionTitle);
  const setting = section?.items.find((item) => item.label === itemLabel);

  if (!section || !setting) {
    return res.status(404).json({ message: "Setting not found." });
  }

  setting.value = value;
  return res.json({
    message: "Setting updated.",
    settings: appState.settings,
  });
});

app.get("/api/admin", (_req, res) => {
  res.json(admin);
});

app.get("/api/session", (_req, res) => {
  res.json({
    environment: "sandbox",
    timestamp: nowIso,
    authenticatedUser: user.email,
  });
});

app.use((_req, res) => {
  res.status(404).json({ message: "Endpoint not found." });
});

app.listen(port, () => {
  console.log(`LSTM Insight backend listening on http://localhost:${port}`);
});
