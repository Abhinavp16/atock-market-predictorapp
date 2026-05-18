const {
  settings: defaultSettings,
  notifications: defaultNotifications,
  alertRules: defaultAlertRules,
  screenerPresets: defaultScreenerPresets,
} = require("./mockData");

const DEFAULT_WATCHLIST_SYMBOLS = ["RELIANCE", "TCS", "INFY", "HDFCBANK", "SBIN"];

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function buildDefaultSettings() {
  return clone(defaultSettings);
}

function buildDefaultNotifications() {
  return clone(defaultNotifications.items).map((item) => ({
    ...item,
    userId: null,
  }));
}

function buildDefaultPortfolio() {
  return {
    cashBalance: 500000,
    realizedPnl: 0,
    positions: [],
    analytics: {
      totalValue: 500000,
      investedValue: 0,
      unrealizedPnl: 0,
      exposureBySector: [],
    },
  };
}

function buildDefaultAlertRules() {
  return clone(defaultAlertRules);
}

function buildDefaultScreenerPresets() {
  return clone(defaultScreenerPresets);
}

module.exports = {
  DEFAULT_WATCHLIST_SYMBOLS,
  buildDefaultAlertRules,
  buildDefaultNotifications,
  buildDefaultPortfolio,
  buildDefaultScreenerPresets,
  buildDefaultSettings,
};
