const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { MongoClient, ObjectId } = require("mongodb");
const { config } = require("./config");
const { buildDefaultNotifications, buildDefaultPortfolio, buildDefaultSettings, DEFAULT_WATCHLIST_SYMBOLS } = require("./defaults");

const LOCAL_DB_PATH = config.database.localFilePath || path.join(__dirname, "..", "data", "appdb.json");

function nowIso() {
  return new Date().toISOString();
}

function createId(prefix) {
  return `${prefix}_${crypto.randomUUID().replace(/-/g, "").slice(0, 16)}`;
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

class LocalDatabaseProvider {
  constructor() {
    this.state = null;
  }

  async init() {
    fs.mkdirSync(path.dirname(LOCAL_DB_PATH), { recursive: true });
    if (!fs.existsSync(LOCAL_DB_PATH)) {
      this.state = this.defaultState();
      this.persist();
      return;
    }
    const raw = fs.readFileSync(LOCAL_DB_PATH, "utf8");
    this.state = raw ? JSON.parse(raw) : this.defaultState();
  }

  defaultState() {
    return {
      users: [],
      sessions: [],
      watchlists: [],
      portfolios: [],
      orders: [],
      settings: [],
      notifications: [],
      alerts: [],
    };
  }

  persist() {
    fs.writeFileSync(LOCAL_DB_PATH, JSON.stringify(this.state, null, 2));
  }

  async getUserByEmail(email) {
    return this.state.users.find((item) => item.email === email) || null;
  }

  async getUserById(id) {
    return this.state.users.find((item) => item.id === id) || null;
  }

  async getUserByEmailVerificationToken(tokenHash) {
    return this.state.users.find((item) => item.emailVerificationTokenHash === tokenHash) || null;
  }

  async getUserByPasswordResetToken(tokenHash) {
    return this.state.users.find((item) => item.passwordResetTokenHash === tokenHash) || null;
  }

  async createUser(user) {
    this.state.users.push(user);
    this.persist();
    return user;
  }

  async updateUser(userId, patch) {
    const user = await this.getUserById(userId);
    if (!user) return null;
    Object.assign(user, patch, { updatedAt: nowIso() });
    this.persist();
    return user;
  }

  async createRefreshSession(session) {
    this.state.sessions.push(session);
    this.persist();
    return session;
  }

  async getRefreshSession(tokenId) {
    return this.state.sessions.find((item) => item.id === tokenId) || null;
  }

  async revokeRefreshSession(tokenId) {
    const session = await this.getRefreshSession(tokenId);
    if (!session) return null;
    session.revokedAt = nowIso();
    this.persist();
    return session;
  }

  async revokeRefreshSessionsForUser(userId) {
    this.state.sessions
      .filter((item) => item.userId === userId && !item.revokedAt)
      .forEach((item) => {
        item.revokedAt = nowIso();
      });
    this.persist();
  }

  async ensureUserScaffold(userId) {
    if (!this.state.watchlists.some((item) => item.userId === userId)) {
      this.state.watchlists.push({
        userId,
        symbols: [...DEFAULT_WATCHLIST_SYMBOLS],
        updatedAt: nowIso(),
      });
    }
    if (!this.state.portfolios.some((item) => item.userId === userId)) {
      this.state.portfolios.push({
        userId,
        ...buildDefaultPortfolio(),
        updatedAt: nowIso(),
      });
    }
    if (!this.state.settings.some((item) => item.userId === userId)) {
      this.state.settings.push({
        userId,
        document: buildDefaultSettings(),
        updatedAt: nowIso(),
      });
    }
    if (!this.state.notifications.some((item) => item.userId === userId)) {
      this.state.notifications.push({
        userId,
        items: buildDefaultNotifications().map((notification) => ({
          ...notification,
          userId,
        })),
        updatedAt: nowIso(),
      });
    }
    this.persist();
  }

  async getWatchlist(userId) {
    await this.ensureUserScaffold(userId);
    return this.state.watchlists.find((item) => item.userId === userId) || null;
  }

  async saveWatchlist(userId, symbols) {
    const doc = await this.getWatchlist(userId);
    doc.symbols = [...symbols];
    doc.updatedAt = nowIso();
    this.persist();
    return doc;
  }

  async getPortfolio(userId) {
    await this.ensureUserScaffold(userId);
    return this.state.portfolios.find((item) => item.userId === userId) || null;
  }

  async savePortfolio(userId, portfolio) {
    const existing = await this.getPortfolio(userId);
    Object.assign(existing, portfolio, { updatedAt: nowIso() });
    this.persist();
    return existing;
  }

  async createOrder(order) {
    this.state.orders.push(order);
    this.persist();
    return order;
  }

  async listOrders(userId) {
    return this.state.orders.filter((item) => item.userId === userId).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  }

  async getSettings(userId) {
    await this.ensureUserScaffold(userId);
    return this.state.settings.find((item) => item.userId === userId) || null;
  }

  async saveSettings(userId, document) {
    const existing = await this.getSettings(userId);
    existing.document = clone(document);
    existing.updatedAt = nowIso();
    this.persist();
    return existing;
  }

  async getNotifications(userId) {
    await this.ensureUserScaffold(userId);
    return this.state.notifications.find((item) => item.userId === userId) || null;
  }

  async saveNotifications(userId, items) {
    const existing = await this.getNotifications(userId);
    existing.items = clone(items);
    existing.updatedAt = nowIso();
    this.persist();
    return existing;
  }
}

class MongoDatabaseProvider {
  constructor() {
    this.client = null;
    this.db = null;
  }

  async init() {
    this.client = new MongoClient(config.database.mongoUri);
    await this.client.connect();
    this.db = this.client.db(config.database.mongoDbName);
    await Promise.all([
      this.db.collection("users").createIndex({ email: 1 }, { unique: true }),
      this.db.collection("sessions").createIndex({ userId: 1 }),
      this.db.collection("orders").createIndex({ userId: 1 }),
    ]);
  }

  collection(name) {
    return this.db.collection(name);
  }

  sanitizeId(doc) {
    if (!doc) return null;
    if (doc._id && !doc.id) {
      return { ...doc, id: String(doc._id), _id: undefined };
    }
    return doc;
  }

  async getUserByEmail(email) {
    return this.sanitizeId(await this.collection("users").findOne({ email }));
  }

  async getUserById(id) {
    const doc = await this.collection("users").findOne({
      $or: [{ id }, ObjectId.isValid(id) ? { _id: new ObjectId(id) } : { id: "__none__" }],
    });
    return this.sanitizeId(doc);
  }

  async getUserByEmailVerificationToken(tokenHash) {
    return this.sanitizeId(await this.collection("users").findOne({ emailVerificationTokenHash: tokenHash }));
  }

  async getUserByPasswordResetToken(tokenHash) {
    return this.sanitizeId(await this.collection("users").findOne({ passwordResetTokenHash: tokenHash }));
  }

  async createUser(user) {
    await this.collection("users").insertOne(user);
    return user;
  }

  async updateUser(userId, patch) {
    await this.collection("users").updateOne({ id: userId }, { $set: { ...patch, updatedAt: nowIso() } });
    return this.getUserById(userId);
  }

  async createRefreshSession(session) {
    await this.collection("sessions").insertOne(session);
    return session;
  }

  async getRefreshSession(tokenId) {
    return this.sanitizeId(await this.collection("sessions").findOne({ id: tokenId }));
  }

  async revokeRefreshSession(tokenId) {
    await this.collection("sessions").updateOne({ id: tokenId }, { $set: { revokedAt: nowIso() } });
  }

  async revokeRefreshSessionsForUser(userId) {
    await this.collection("sessions").updateMany({ userId, revokedAt: null }, { $set: { revokedAt: nowIso() } });
  }

  async ensureUserScaffold(userId) {
    await Promise.all([
      this.collection("watchlists").updateOne(
        { userId },
        { $setOnInsert: { userId, symbols: [...DEFAULT_WATCHLIST_SYMBOLS], updatedAt: nowIso() } },
        { upsert: true },
      ),
      this.collection("portfolios").updateOne(
        { userId },
        { $setOnInsert: { userId, ...buildDefaultPortfolio(), updatedAt: nowIso() } },
        { upsert: true },
      ),
      this.collection("settings").updateOne(
        { userId },
        { $setOnInsert: { userId, document: buildDefaultSettings(), updatedAt: nowIso() } },
        { upsert: true },
      ),
      this.collection("notifications").updateOne(
        { userId },
        {
          $setOnInsert: {
            userId,
            items: buildDefaultNotifications().map((item) => ({ ...item, userId })),
            updatedAt: nowIso(),
          },
        },
        { upsert: true },
      ),
    ]);
  }

  async getWatchlist(userId) {
    await this.ensureUserScaffold(userId);
    return this.sanitizeId(await this.collection("watchlists").findOne({ userId }));
  }

  async saveWatchlist(userId, symbols) {
    await this.collection("watchlists").updateOne({ userId }, { $set: { symbols: [...symbols], updatedAt: nowIso() } }, { upsert: true });
    return this.getWatchlist(userId);
  }

  async getPortfolio(userId) {
    await this.ensureUserScaffold(userId);
    return this.sanitizeId(await this.collection("portfolios").findOne({ userId }));
  }

  async savePortfolio(userId, portfolio) {
    await this.collection("portfolios").updateOne({ userId }, { $set: { ...portfolio, userId, updatedAt: nowIso() } }, { upsert: true });
    return this.getPortfolio(userId);
  }

  async createOrder(order) {
    await this.collection("orders").insertOne(order);
    return order;
  }

  async listOrders(userId) {
    return this.collection("orders").find({ userId }).sort({ createdAt: -1 }).toArray();
  }

  async getSettings(userId) {
    await this.ensureUserScaffold(userId);
    return this.sanitizeId(await this.collection("settings").findOne({ userId }));
  }

  async saveSettings(userId, document) {
    await this.collection("settings").updateOne({ userId }, { $set: { userId, document: clone(document), updatedAt: nowIso() } }, { upsert: true });
    return this.getSettings(userId);
  }

  async getNotifications(userId) {
    await this.ensureUserScaffold(userId);
    return this.sanitizeId(await this.collection("notifications").findOne({ userId }));
  }

  async saveNotifications(userId, items) {
    await this.collection("notifications").updateOne({ userId }, { $set: { userId, items: clone(items), updatedAt: nowIso() } }, { upsert: true });
    return this.getNotifications(userId);
  }
}

function createDatabaseProvider() {
  return config.database.provider === "mongo" ? new MongoDatabaseProvider() : new LocalDatabaseProvider();
}

module.exports = {
  createDatabaseProvider,
  createId,
  nowIso,
};
