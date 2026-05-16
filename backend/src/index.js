const express = require("express");
const cors = require("cors");
const {
  nowIso,
  user,
  onboarding,
  splash,
  notifications,
  profile,
  settings,
  admin,
  appState,
} = require("./mockData");
const marketService = require("./marketService");
const { findSymbolMeta, loadSymbolMaster } = require("./symbolMaster");

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

app.get("/api/health", async (_req, res) => {
  let modelService = "offline";
  try {
    await marketService.pythonClient.health();
    modelService = "online";
  } catch (_error) {
    modelService = "offline";
  }

  res.json({
    status: "ok",
    service: "niveshiq-backend",
    modelService,
    universeSize: loadSymbolMaster().length,
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/bootstrap", (_req, res) => {
  res.json({
    splash: {
      ...splash,
      stats: [
        { label: "Universe", value: `${loadSymbolMaster().length}+ stocks` },
        { label: "Predictions", value: "7-Day Outlook" },
        { label: "Market Focus", value: "India EOD" },
      ],
    },
    onboarding,
    user: {
      ...user,
      watchlistCount: appState.watchlistSymbols.length,
    },
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
    user: { ...user, watchlistCount: appState.watchlistSymbols.length },
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
    user: { ...user, name: fullName, email, watchlistCount: appState.watchlistSymbols.length },
    message: "Registration successful.",
  });
});

app.get("/api/symbols", async (req, res) => {
  try {
    const query = String(req.query.query || "");
    const result = await marketService.searchSymbols(query);
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
});

app.get("/api/quotes/:symbol", async (req, res) => {
  try {
    return res.json(await marketService.getQuote(req.params.symbol));
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
});

app.get("/api/charts/:symbol", async (req, res) => {
  try {
    return res.json(await marketService.getChart(req.params.symbol, req.query.range || "1M"));
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
});

app.get("/api/company/:symbol", async (req, res) => {
  try {
    return res.json(await marketService.getCompany(req.params.symbol));
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
});

app.get("/api/dashboard", async (_req, res) => {
  try {
    return res.json(await marketService.buildDashboard(user, appState.watchlistSymbols));
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
});

app.get("/api/watchlist", async (_req, res) => {
  try {
    return res.json(await marketService.buildWatchlist(appState.watchlistSymbols));
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
});

app.post("/api/watchlist", async (req, res) => {
  const { symbol, name, price } = req.body ?? {};
  const normalizedSymbol = String(symbol || "").toUpperCase().trim();
  if (!normalizedSymbol) {
    return res.status(400).json({ message: "symbol is required." });
  }

  const meta = findSymbolMeta(normalizedSymbol);
  if (!meta) {
    return res.status(404).json({ message: `Unsupported symbol ${normalizedSymbol}.` });
  }

  if (!appState.watchlistSymbols.includes(normalizedSymbol)) {
    appState.watchlistSymbols.unshift(normalizedSymbol);
  }

  try {
    const quote = await marketService.getQuote(normalizedSymbol);
    return res.status(201).json({
      symbol: normalizedSymbol,
      name: name || quote.displayName,
      price: typeof price === "number" && price > 0 ? price : quote.currentPrice,
      changePct: quote.changePct,
      signal: "Watch",
      signalTone: "neutral",
      sparkline: quote.sparkline || [],
    });
  } catch (error) {
    return res.status(201).json({
      symbol: normalizedSymbol,
      name: name || meta.displayName,
      price: typeof price === "number" ? price : 0,
      changePct: 0,
      signal: "Watch",
      signalTone: "neutral",
      sparkline: [],
      warning: error.message,
    });
  }
});

app.get("/api/market/analytics", async (_req, res) => {
  try {
    return res.json(await marketService.buildAnalytics());
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
});

app.get("/api/stocks/:symbol", async (req, res) => {
  try {
    return res.json(await marketService.buildStockDetails(req.params.symbol));
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
});

app.get("/api/predictions/:symbol", async (req, res) => {
  try {
    return res.json(await marketService.getPrediction(req.params.symbol));
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
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
  res.json({
    ...profile,
    watchlistCount: appState.watchlistSymbols.length,
  });
});

app.get("/api/settings", (_req, res) => {
  res.json(settings);
});

app.patch("/api/settings", (req, res) => {
  const { sectionTitle, itemLabel, value } = req.body ?? {};
  const section = settings.sections.find((item) => item.title === sectionTitle);
  const setting = section?.items.find((item) => item.label === itemLabel);

  if (!section || !setting) {
    return res.status(404).json({ message: "Setting not found." });
  }

  setting.value = value;
  return res.json({
    message: "Setting updated.",
    settings,
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
  console.log(`NiveshIQ backend listening on http://localhost:${port}`);
});
