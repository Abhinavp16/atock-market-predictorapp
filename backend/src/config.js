function numberFromEnv(name, fallback) {
  const raw = process.env[name];
  if (!raw) return fallback;
  const parsed = Number(raw);
  return Number.isFinite(parsed) ? parsed : fallback;
}

const config = {
  env: process.env.NODE_ENV || "development",
  port: numberFromEnv("PORT", 3000),
  auth: {
    jwtSecret: process.env.AUTH_SECRET || "niveshiq-local-dev-secret",
    accessTokenTtlSeconds: numberFromEnv("ACCESS_TOKEN_TTL_SECONDS", 60 * 60),
    refreshTokenTtlSeconds: numberFromEnv("REFRESH_TOKEN_TTL_SECONDS", 60 * 60 * 24 * 30),
  },
  database: {
    provider: process.env.DATABASE_PROVIDER || "local",
    mongoUri: process.env.MONGODB_URI || "mongodb://127.0.0.1:27017",
    mongoDbName: process.env.MONGODB_DB_NAME || "niveshiq",
    localFilePath: process.env.LOCAL_DB_FILE_PATH || "",
  },
  ml: {
    serviceBaseUrl: process.env.ML_SERVICE_BASE_URL || "http://127.0.0.1:8000",
    timeoutMs: numberFromEnv("ML_SERVICE_TIMEOUT_MS", 6000),
    fallbackEnabled: process.env.ML_FALLBACK_ENABLED !== "false",
  },
  app: {
    publicBaseUrl: process.env.PUBLIC_APP_BASE_URL || "http://127.0.0.1:3000",
  },
};

module.exports = {
  config,
};
