const { z } = require("zod");
const { AppError } = require("./errors");

const emailSchema = z.string().trim().email();

const schemas = {
  login: z.object({
    email: emailSchema,
    password: z.string().min(8),
  }),
  register: z.object({
    fullName: z.string().trim().min(2).max(120),
    email: emailSchema,
    password: z.string().min(8).max(128),
  }),
  refresh: z.object({
    refreshToken: z.string().min(10),
  }),
  forgotPassword: z.object({
    email: emailSchema,
  }),
  resetPassword: z.object({
    token: z.string().min(10),
    password: z.string().min(8).max(128),
  }),
  verifyEmail: z.object({
    token: z.string().min(10),
  }),
  watchlistCreate: z.object({
    symbol: z.string().trim().min(1).max(30),
    name: z.string().trim().optional(),
    price: z.number().nonnegative().optional(),
  }),
  watchlistDelete: z.object({
    symbol: z.string().trim().min(1).max(30),
  }),
  settingsPatch: z.object({
    sectionTitle: z.string().trim().min(1),
    itemLabel: z.string().trim().min(1),
    value: z.any(),
  }),
  alertPatch: z.object({
    id: z.string().trim().min(1),
    enabled: z.boolean(),
  }),
  screenerPresetCreate: z.object({
    name: z.string().trim().min(2).max(80),
    sector: z.string().optional().default(""),
    marketCapBucket: z.string().optional().default(""),
    minPe: z.coerce.number().optional(),
    maxPe: z.coerce.number().optional(),
    minDividendYield: z.coerce.number().optional(),
    predictionBias: z.enum(["bullish", "bearish", "neutral_or_better", "any"]).optional().default("any"),
    minRsi: z.coerce.number().optional(),
    maxVolatility: z.coerce.number().optional(),
  }),
  orderCreate: z.object({
    symbol: z.string().trim().min(1).max(30),
    side: z.enum(["buy", "sell"]),
    amount: z.number().positive(),
  }),
  symbolQuery: z.object({
    query: z.string().optional().default(""),
    sector: z.string().optional(),
    marketCapBucket: z.string().optional(),
    sort: z.enum(["symbol", "name"]).optional(),
  }),
  screenerQuery: z.object({
    sector: z.string().optional(),
    marketCapBucket: z.string().optional(),
    minPe: z.coerce.number().optional(),
    maxPe: z.coerce.number().optional(),
    minDividendYield: z.coerce.number().optional(),
    predictionBias: z.enum(["bullish", "bearish", "neutral_or_better", "any"]).optional(),
    minRsi: z.coerce.number().optional(),
    maxVolatility: z.coerce.number().optional(),
    limit: z.coerce.number().int().positive().max(50).optional().default(20),
  }),
  compareQuery: z.object({
    symbols: z.string().trim().min(1),
  }),
};

function parseOrThrow(schema, payload) {
  const result = schema.safeParse(payload);
  if (!result.success) {
    throw new AppError(400, "Validation failed.", result.error.flatten());
  }
  return result.data;
}

module.exports = {
  schemas,
  parseOrThrow,
};
