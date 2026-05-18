const express = require("express");
const cors = require("cors");
const { config } = require("./config");
const { logger } = require("./logger");
const { AppError } = require("./errors");
const { createDatabaseProvider } = require("./database");
const { AuthService, publicUserFromRecord } = require("./authService");
const { UserDataService } = require("./userDataService");
const { user: seedUser, onboarding, splash, profile, admin } = require("./mockData");
const marketService = require("./marketService");
const { findSymbolMeta, loadSymbolMaster } = require("./symbolMaster");
const { parseOrThrow, schemas } = require("./validation");

function asyncHandler(handler) {
  return async (req, res, next) => {
    try {
      await handler(req, res, next);
    } catch (error) {
      next(error);
    }
  };
}

function activeUserPayload(authUser, derived = {}) {
  const safeAuthUser = authUser ? publicUserFromRecord(authUser) : null;
  return {
    ...seedUser,
    ...(safeAuthUser || {}),
    firstName: safeAuthUser?.firstName || safeAuthUser?.name?.split(/\s+/)[0] || seedUser.firstName,
    watchlistCount: derived.watchlistCount ?? 0,
    notificationCount: derived.notificationCount ?? safeAuthUser?.notificationCount ?? seedUser.notificationCount,
    portfolioValue: derived.portfolioValue ?? safeAuthUser?.portfolioValue ?? seedUser.portfolioValue,
  };
}

function requireAuth(req, _res, next) {
  if (!req.authUser) {
    return next(new AppError(401, "Authentication required."));
  }
  return next();
}

async function buildUserContext(userDataService, userId) {
  const [watchlistSymbols, notifications, portfolio] = await Promise.all([
    userDataService.getWatchlistSymbols(userId),
    userDataService.getNotifications(userId),
    userDataService.getPortfolio(userId),
  ]);
  return {
    watchlistSymbols,
    notifications,
    portfolio,
  };
}

async function createApp() {
  const database = createDatabaseProvider();
  await database.init();

  const authService = new AuthService(database, seedUser);
  await authService.ensureSeedUser();
  const userDataService = new UserDataService(database, marketService);

  const app = express();
  app.use(cors());
  app.use(express.json());

  app.use(asyncHandler(async (req, _res, next) => {
    const authorization = String(req.headers.authorization || "");
    const token = authorization.startsWith("Bearer ") ? authorization.slice(7) : "";
    req.authUser = await authService.authenticateAccessToken(token);
    next();
  }));

  app.get("/api/health", asyncHandler(async (_req, res) => {
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
      databaseProvider: config.database.provider,
      universeSize: loadSymbolMaster().length,
      timestamp: new Date().toISOString(),
    });
  }));

  app.get("/api/bootstrap", asyncHandler(async (req, res) => {
    const context = req.authUser ? await buildUserContext(userDataService, req.authUser.id) : {
      watchlistSymbols: [],
      notifications: [],
      portfolio: null,
    };
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
      user: activeUserPayload(req.authUser, {
        watchlistCount: context.watchlistSymbols.length,
        notificationCount: context.notifications.filter((item) => item.unread).length,
        portfolioValue: context.portfolio?.analytics?.totalValue,
      }),
      nav: [
        { key: "home", label: "Home", icon: "home" },
        { key: "market", label: "Market", icon: "query_stats" },
        { key: "predict", label: "Predict", icon: "online_prediction" },
        { key: "watch", label: "Watch", icon: "visibility" },
        { key: "profile", label: "Profile", icon: "person" },
      ],
    });
  }));

  app.post("/api/auth/login", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.login, req.body ?? {});
    res.json(await authService.login(payload.email, payload.password));
  }));

  app.post("/api/auth/register", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.register, req.body ?? {});
    res.status(201).json(await authService.register(payload.fullName, payload.email, payload.password));
  }));

  app.post("/api/auth/refresh", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.refresh, req.body ?? {});
    res.json(await authService.refresh(payload.refreshToken));
  }));

  app.post("/api/auth/logout", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.refresh, req.body ?? {});
    res.json(await authService.logout(payload.refreshToken));
  }));

  app.post("/api/auth/forgot-password", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.forgotPassword, req.body ?? {});
    res.json(await authService.forgotPassword(payload.email));
  }));

  app.post("/api/auth/reset-password", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.resetPassword, req.body ?? {});
    res.json(await authService.resetPassword(payload.token, payload.password));
  }));

  app.post("/api/auth/verify-email", asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.verifyEmail, req.body ?? {});
    res.json(await authService.verifyEmail(payload.token));
  }));

  app.post("/api/auth/google", (_req, res) => {
    res.status(501).json({
      message: "Google sign-in is deferred until the email/password foundation is fully stabilized.",
    });
  });

  app.get("/api/symbols", asyncHandler(async (req, res) => {
    const query = parseOrThrow(schemas.symbolQuery, req.query ?? {});
    res.json(await marketService.searchSymbols(query.query, query));
  }));

  app.get("/api/market/movers", asyncHandler(async (_req, res) => {
    res.json(await marketService.getMarketMovers());
  }));

  app.get("/api/compare", asyncHandler(async (req, res) => {
    const query = parseOrThrow(schemas.compareQuery, req.query ?? {});
    res.json(await marketService.compareSymbols(query.symbols.split(",").map((item) => item.trim())));
  }));

  app.get("/api/screener", asyncHandler(async (req, res) => {
    const query = parseOrThrow(schemas.screenerQuery, req.query ?? {});
    res.json(await marketService.screenSymbols(query));
  }));

  app.get("/api/quotes/:symbol", asyncHandler(async (req, res) => {
    res.json(await marketService.getQuote(req.params.symbol));
  }));

  app.get("/api/charts/:symbol", asyncHandler(async (req, res) => {
    res.json(await marketService.getChart(req.params.symbol, req.query.range || "1M"));
  }));

  app.get("/api/company/:symbol", asyncHandler(async (req, res) => {
    res.json(await marketService.getCompany(req.params.symbol));
  }));

  app.get("/api/dashboard", requireAuth, asyncHandler(async (req, res) => {
    const context = await buildUserContext(userDataService, req.authUser.id);
    res.json(
      await marketService.buildDashboard(
        activeUserPayload(req.authUser, {
          watchlistCount: context.watchlistSymbols.length,
          notificationCount: context.notifications.filter((item) => item.unread).length,
          portfolioValue: context.portfolio.analytics.totalValue,
        }),
        context.watchlistSymbols,
      ),
    );
  }));

  app.get("/api/watchlist", requireAuth, asyncHandler(async (req, res) => {
    const watchlistSymbols = await userDataService.getWatchlistSymbols(req.authUser.id);
    res.json(await marketService.buildWatchlist(watchlistSymbols));
  }));

  app.post("/api/watchlist", requireAuth, asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.watchlistCreate, req.body ?? {});
    const normalizedSymbol = payload.symbol.toUpperCase().trim();
    const meta = findSymbolMeta(normalizedSymbol);
    if (!meta) {
      throw new AppError(404, `Unsupported symbol ${normalizedSymbol}.`);
    }

    await userDataService.addWatchlistSymbol(req.authUser.id, normalizedSymbol);
    try {
      const quote = await marketService.getQuote(normalizedSymbol);
      res.status(201).json({
        symbol: normalizedSymbol,
        name: payload.name || quote.displayName,
        price: typeof payload.price === "number" && payload.price > 0 ? payload.price : quote.currentPrice,
        changePct: quote.changePct,
        signal: "Watch",
        signalTone: "neutral",
        sparkline: quote.sparkline || [],
      });
    } catch (error) {
      res.status(201).json({
        symbol: normalizedSymbol,
        name: payload.name || meta.displayName,
        price: typeof payload.price === "number" ? payload.price : 0,
        changePct: 0,
        signal: "Watch",
        signalTone: "neutral",
        sparkline: [],
        warning: error.message,
      });
    }
  }));

  app.delete("/api/watchlist/:symbol", requireAuth, asyncHandler(async (req, res) => {
    await userDataService.removeWatchlistSymbol(req.authUser.id, String(req.params.symbol || "").toUpperCase());
    res.json({ message: "Watchlist item removed." });
  }));

  app.get("/api/market/analytics", asyncHandler(async (_req, res) => {
    res.json(await marketService.buildAnalytics());
  }));

  app.get("/api/stocks/:symbol", asyncHandler(async (req, res) => {
    res.json(await marketService.buildStockDetails(req.params.symbol));
  }));

  app.get("/api/predictions/:symbol", asyncHandler(async (req, res) => {
    res.json(await marketService.getPrediction(req.params.symbol));
  }));

  app.get("/api/portfolio", requireAuth, asyncHandler(async (req, res) => {
    res.json(await userDataService.getPortfolio(req.authUser.id));
  }));

  app.get("/api/orders", requireAuth, asyncHandler(async (req, res) => {
    res.json({
      items: await userDataService.listOrders(req.authUser.id),
    });
  }));

  app.get("/api/trades", requireAuth, asyncHandler(async (req, res) => {
    res.json({
      items: await userDataService.listOrders(req.authUser.id),
    });
  }));

  app.post("/api/orders", requireAuth, asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.orderCreate, req.body ?? {});
    res.status(201).json(await userDataService.placePaperOrder(req.authUser.id, payload));
  }));

  app.post("/api/trade", requireAuth, asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.orderCreate, req.body ?? {});
    const result = await userDataService.placePaperOrder(req.authUser.id, payload);
    res.status(201).json({
      ...result.order,
      portfolio: result.portfolio,
    });
  }));

  app.get("/api/notifications", requireAuth, asyncHandler(async (req, res) => {
    res.json({
      title: "Notifications",
      items: await userDataService.getNotifications(req.authUser.id),
    });
  }));

  app.get("/api/profile", requireAuth, asyncHandler(async (req, res) => {
    const context = await buildUserContext(userDataService, req.authUser.id);
    res.json({
      ...profile,
      ...activeUserPayload(req.authUser, {
        watchlistCount: context.watchlistSymbols.length,
        notificationCount: context.notifications.filter((item) => item.unread).length,
        portfolioValue: context.portfolio.analytics.totalValue,
      }),
      verificationState: req.authUser.emailVerifiedAt ? "verified" : "pending",
      preferences: (await userDataService.getSettingsDocument(req.authUser.id)).sections,
      portfolioSummary: context.portfolio.analytics,
    });
  }));

  app.get("/api/settings", requireAuth, asyncHandler(async (req, res) => {
    res.json(await userDataService.getSettingsDocument(req.authUser.id));
  }));

  app.patch("/api/settings", requireAuth, asyncHandler(async (req, res) => {
    const payload = parseOrThrow(schemas.settingsPatch, req.body ?? {});
    const settings = await userDataService.updateSetting(req.authUser.id, payload.sectionTitle, payload.itemLabel, payload.value);
    res.json({
      message: "Setting updated.",
      settings,
    });
  }));

  app.get("/api/admin", requireAuth, asyncHandler(async (req, res) => {
    const orders = await userDataService.listOrders(req.authUser.id);
    res.json({
      ...admin,
      topMetrics: [
        ...admin.topMetrics,
        { label: "Paper Orders", value: String(orders.length), trend: "Active" },
      ],
    });
  }));

  app.get("/api/session", requireAuth, asyncHandler(async (req, res) => {
    const context = await buildUserContext(userDataService, req.authUser.id);
    res.json({
      environment: config.env,
      timestamp: new Date().toISOString(),
      authenticatedUser: req.authUser.email,
      user: activeUserPayload(req.authUser, {
        watchlistCount: context.watchlistSymbols.length,
        notificationCount: context.notifications.filter((item) => item.unread).length,
        portfolioValue: context.portfolio.analytics.totalValue,
      }),
      verificationState: req.authUser.emailVerifiedAt ? "verified" : "pending",
    });
  }));

  app.use((_req, _res, next) => {
    next(new AppError(404, "Endpoint not found."));
  });

  app.use((error, req, res, _next) => {
    const statusCode = error.statusCode || 500;
    logger.error({
      err: error,
      statusCode,
      path: req.path,
      method: req.method,
    }, error.message || "Unhandled request failure");
    res.status(statusCode).json({
      message: error.message || "Internal server error.",
      details: error.details,
    });
  });

  app.locals.services = {
    database,
    authService,
    userDataService,
  };

  return app;
}

async function start() {
  const app = await createApp();
  app.listen(config.port, () => {
    logger.info(`NiveshIQ backend listening on http://localhost:${config.port}`);
  });
}

if (require.main === module) {
  start().catch((error) => {
    logger.error({ err: error }, "Failed to start backend");
    process.exit(1);
  });
}

module.exports = {
  createApp,
  start,
};
