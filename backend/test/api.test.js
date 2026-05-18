const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const os = require("os");
const path = require("path");
const request = require("supertest");

const dbPath = path.join(os.tmpdir(), `niveshiq-test-${Date.now()}.json`);
process.env.NODE_ENV = "test";
process.env.DATABASE_PROVIDER = "local";
process.env.LOCAL_DB_FILE_PATH = dbPath;
process.env.AUTH_SECRET = "test-secret";
process.env.SEED_USER_PASSWORD = "password!";

const { createApp } = require("../src/index");

let app;

test.before(async () => {
  if (fs.existsSync(dbPath)) {
    fs.unlinkSync(dbPath);
  }
  app = await createApp();
});

test.after(() => {
  if (fs.existsSync(dbPath)) {
    fs.unlinkSync(dbPath);
  }
});

test("register, verify, login, and session flow works", async () => {
  const registerResponse = await request(app)
    .post("/api/auth/register")
    .send({
      fullName: "Test User",
      email: "test@example.com",
      password: "password123",
    })
    .expect(201);

  assert.equal(registerResponse.body.user.email, "test@example.com");
  assert.equal(registerResponse.body.verificationRequired, true);
  assert.ok(registerResponse.body.verificationTokenPreview);

  await request(app)
    .post("/api/auth/verify-email")
    .send({ token: registerResponse.body.verificationTokenPreview })
    .expect(200);

  const loginResponse = await request(app)
    .post("/api/auth/login")
    .send({
      email: "test@example.com",
      password: "password123",
    })
    .expect(200);

  assert.ok(loginResponse.body.token);
  assert.ok(loginResponse.body.refreshToken);

  const sessionResponse = await request(app)
    .get("/api/session")
    .set("Authorization", `Bearer ${loginResponse.body.token}`)
    .expect(200);

  assert.equal(sessionResponse.body.user.email, "test@example.com");

  const refreshResponse = await request(app)
    .post("/api/auth/refresh")
    .send({ refreshToken: loginResponse.body.refreshToken })
    .expect(200);

  assert.ok(refreshResponse.body.token);
});

test("watchlists and paper orders are user scoped", async () => {
  const userA = await request(app)
    .post("/api/auth/login")
    .send({ email: "pradeep@niveshiq.in", password: "password!" })
    .expect(200);

  const userBRegister = await request(app)
    .post("/api/auth/register")
    .send({
      fullName: "Second User",
      email: "second@example.com",
      password: "password123",
    })
    .expect(201);

  await request(app)
    .post("/api/watchlist")
    .set("Authorization", `Bearer ${userA.body.token}`)
    .send({ symbol: "ICICIBANK" })
    .expect(201);

  const watchlistA = await request(app)
    .get("/api/watchlist")
    .set("Authorization", `Bearer ${userA.body.token}`)
    .expect(200);

  assert.ok(watchlistA.body.assets.some((item) => item.symbol === "ICICIBANK"));

  const watchlistB = await request(app)
    .get("/api/watchlist")
    .set("Authorization", `Bearer ${userBRegister.body.token}`)
    .expect(200);

  assert.equal(watchlistB.body.assets.some((item) => item.symbol === "ICICIBANK"), false);

  const tradeResponse = await request(app)
    .post("/api/trade")
    .set("Authorization", `Bearer ${userA.body.token}`)
    .send({ symbol: "INFY", side: "buy", amount: 25000 })
    .expect(201);

  assert.equal(tradeResponse.body.status, "filled");
  assert.ok(tradeResponse.body.portfolio.positions.length >= 1);
});
