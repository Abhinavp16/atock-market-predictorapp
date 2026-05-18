const crypto = require("crypto");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { nanoid } = require("nanoid");
const { config } = require("./config");
const { createId, nowIso } = require("./database");
const { AppError } = require("./errors");
const { buildDefaultPortfolio, buildDefaultSettings } = require("./defaults");

function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function expiresAt(seconds) {
  return new Date(Date.now() + seconds * 1000).toISOString();
}

function publicUserFromRecord(user) {
  return {
    id: user.id,
    name: user.name,
    firstName: user.firstName,
    email: user.email,
    role: user.role,
    avatarInitials: user.avatarInitials,
    location: user.location,
    memberSince: user.memberSince,
    riskProfile: user.riskProfile,
    portfolioValue: user.portfolioValue,
    notificationCount: user.notificationCount || 0,
    emailVerified: Boolean(user.emailVerifiedAt),
    authProvider: user.authProvider || "password",
  };
}

function firstNameForName(fullName) {
  return String(fullName || "").trim().split(/\s+/).filter(Boolean)[0] || "Investor";
}

function initialsForName(fullName) {
  return String(fullName || "")
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join("");
}

class AuthService {
  constructor(database, seedUser) {
    this.database = database;
    this.seedUser = seedUser;
  }

  async ensureSeedUser(password = process.env.SEED_USER_PASSWORD || "password!") {
    const email = String(this.seedUser.email).toLowerCase();
    const existing = await this.database.getUserByEmail(email);
    if (existing) return existing;
    const passwordHash = await bcrypt.hash(password, 12);
    const user = {
      id: this.seedUser.id,
      name: this.seedUser.name,
      firstName: this.seedUser.firstName,
      email,
      passwordHash,
      authProvider: "password",
      role: this.seedUser.role,
      avatarInitials: this.seedUser.avatarInitials,
      location: this.seedUser.location,
      memberSince: this.seedUser.memberSince,
      riskProfile: this.seedUser.riskProfile,
      portfolioValue: this.seedUser.portfolioValue,
      notificationCount: this.seedUser.notificationCount,
      emailVerifiedAt: nowIso(),
      verificationStatus: "verified",
      preferences: buildDefaultSettings(),
      portfolioSeed: buildDefaultPortfolio(),
      createdAt: nowIso(),
      updatedAt: nowIso(),
    };
    await this.database.createUser(user);
    await this.database.ensureUserScaffold(user.id);
    return user;
  }

  signAccessToken(user) {
    return jwt.sign(
      {
        sub: user.id,
        email: user.email,
        type: "access",
      },
      config.auth.jwtSecret,
      { expiresIn: config.auth.accessTokenTtlSeconds },
    );
  }

  async createRefreshToken(user) {
    const tokenId = createId("rfs");
    const rawToken = nanoid(48);
    const tokenHash = hashToken(rawToken);
    await this.database.createRefreshSession({
      id: tokenId,
      userId: user.id,
      tokenHash,
      createdAt: nowIso(),
      expiresAt: expiresAt(config.auth.refreshTokenTtlSeconds),
      revokedAt: null,
    });
    return `${tokenId}.${rawToken}`;
  }

  verifyAccessToken(token) {
    try {
      return jwt.verify(token, config.auth.jwtSecret);
    } catch (_error) {
      return null;
    }
  }

  async authenticateAccessToken(token) {
    const payload = this.verifyAccessToken(token);
    if (!payload?.sub) return null;
    return this.database.getUserById(payload.sub);
  }

  async issueSession(user, extra = {}) {
    const accessToken = this.signAccessToken(user);
    const refreshToken = await this.createRefreshToken(user);
    return {
      token: accessToken,
      accessToken,
      refreshToken,
      expiresIn: config.auth.accessTokenTtlSeconds,
      user: publicUserFromRecord(user),
      ...extra,
    };
  }

  async register(fullName, email, password) {
    const normalizedEmail = String(email).trim().toLowerCase();
    const existing = await this.database.getUserByEmail(normalizedEmail);
    if (existing) {
      throw new AppError(409, "An account with this email already exists.");
    }
    const passwordHash = await bcrypt.hash(password, 12);
    const verificationToken = nanoid(40);
    const user = {
      id: createId("usr"),
      name: String(fullName).trim(),
      firstName: firstNameForName(fullName),
      email: normalizedEmail,
      passwordHash,
      authProvider: "password",
      role: "NiveshIQ Member",
      avatarInitials: initialsForName(fullName),
      location: this.seedUser.location,
      memberSince: String(new Date().getFullYear()),
      riskProfile: this.seedUser.riskProfile,
      portfolioValue: 0,
      notificationCount: 0,
      verificationStatus: "pending",
      emailVerifiedAt: null,
      emailVerificationTokenHash: hashToken(verificationToken),
      emailVerificationExpiresAt: expiresAt(60 * 60 * 24),
      passwordResetTokenHash: null,
      passwordResetExpiresAt: null,
      createdAt: nowIso(),
      updatedAt: nowIso(),
    };
    await this.database.createUser(user);
    await this.database.ensureUserScaffold(user.id);
    return this.issueSession(user, {
      message: "Registration successful. Verify the email token to complete onboarding.",
      verificationRequired: true,
      verificationTokenPreview: config.env === "production" ? undefined : verificationToken,
    });
  }

  async login(email, password) {
    const user = await this.database.getUserByEmail(String(email).trim().toLowerCase());
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      throw new AppError(401, "Invalid email or password.");
    }
    return this.issueSession(user, {
      message: user.emailVerifiedAt ? "Login successful." : "Login successful. Email verification is still pending.",
      verificationRequired: !user.emailVerifiedAt,
    });
  }

  async refresh(refreshToken) {
    const [tokenId, rawSecret] = String(refreshToken || "").split(".");
    if (!tokenId || !rawSecret) {
      throw new AppError(401, "Invalid refresh token.");
    }
    const session = await this.database.getRefreshSession(tokenId);
    if (!session || session.revokedAt || session.expiresAt < nowIso()) {
      throw new AppError(401, "Refresh token is expired or revoked.");
    }
    if (session.tokenHash !== hashToken(rawSecret)) {
      throw new AppError(401, "Refresh token is invalid.");
    }
    await this.database.revokeRefreshSession(tokenId);
    const user = await this.database.getUserById(session.userId);
    if (!user) {
      throw new AppError(401, "User session is no longer valid.");
    }
    return this.issueSession(user, {
      message: "Session refreshed.",
    });
  }

  async logout(refreshToken) {
    const [tokenId] = String(refreshToken || "").split(".");
    if (tokenId) {
      await this.database.revokeRefreshSession(tokenId);
    }
    return { message: "Logged out." };
  }

  async verifyEmail(token) {
    const tokenHash = hashToken(token);
    const user = await this.database.getUserByEmailVerificationToken(tokenHash);
    if (!user || !user.emailVerificationExpiresAt || user.emailVerificationExpiresAt < nowIso()) {
      throw new AppError(400, "Verification token is invalid or expired.");
    }
    await this.database.updateUser(user.id, {
      verificationStatus: "verified",
      emailVerifiedAt: nowIso(),
      emailVerificationTokenHash: null,
      emailVerificationExpiresAt: null,
    });
    return { message: "Email verified successfully." };
  }

  async forgotPassword(email) {
    const user = await this.database.getUserByEmail(String(email).trim().toLowerCase());
    if (!user) {
      return { message: "If the account exists, a reset token has been generated." };
    }
    const resetToken = nanoid(40);
    await this.database.updateUser(user.id, {
      passwordResetTokenHash: hashToken(resetToken),
      passwordResetExpiresAt: expiresAt(60 * 30),
    });
    return {
      message: "If the account exists, a reset token has been generated.",
      resetTokenPreview: config.env === "production" ? undefined : resetToken,
    };
  }

  async resetPassword(token, password) {
    const tokenHash = hashToken(token);
    const user = await this.database.getUserByPasswordResetToken(tokenHash);
    if (!user || !user.passwordResetExpiresAt || user.passwordResetExpiresAt < nowIso()) {
      throw new AppError(400, "Password reset token is invalid or expired.");
    }
    const passwordHash = await bcrypt.hash(password, 12);
    await this.database.updateUser(user.id, {
      passwordHash,
      passwordResetTokenHash: null,
      passwordResetExpiresAt: null,
    });
    await this.database.revokeRefreshSessionsForUser(user.id);
    return { message: "Password updated successfully." };
  }
}

module.exports = {
  AuthService,
  publicUserFromRecord,
};
