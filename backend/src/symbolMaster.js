const fs = require("fs");
const path = require("path");

const csvPath = path.join(__dirname, "..", "data", "nifty200.csv");
const LARGE_CAP_SYMBOLS = new Set([
  "ADANIENT",
  "ADANIGREEN",
  "ADANIPORTS",
  "ADANIENSOL",
  "APOLLOHOSP",
  "ASIANPAINT",
  "AXISBANK",
  "BAJAJ-AUTO",
  "BAJAJFINSV",
  "BAJFINANCE",
  "BHARTIARTL",
  "BRITANNIA",
  "CIPLA",
  "COALINDIA",
  "DMART",
  "DRREDDY",
  "EICHERMOT",
  "GRASIM",
  "HCLTECH",
  "HDFCBANK",
  "HDFCLIFE",
  "HEROMOTOCO",
  "HINDALCO",
  "HINDUNILVR",
  "ICICIBANK",
  "INDUSINDBK",
  "INFY",
  "ITC",
  "JSWSTEEL",
  "KOTAKBANK",
  "LT",
  "M&M",
  "MARUTI",
  "NESTLEIND",
  "NTPC",
  "ONGC",
  "POWERGRID",
  "RELIANCE",
  "SBILIFE",
  "SBIN",
  "SUNPHARMA",
  "TATAMOTORS",
  "TATASTEEL",
  "TCS",
  "TECHM",
  "TITAN",
  "ULTRACEMCO",
  "WIPRO",
]);

let cachedSymbols;

function parseCsvLine(line) {
  const values = [];
  let current = "";
  let inQuotes = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    if (char === '"') {
      if (inQuotes && line[index + 1] === '"') {
        current += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      values.push(current);
      current = "";
      continue;
    }

    current += char;
  }

  values.push(current);
  return values.map((value) => value.trim());
}

function titleCase(value) {
  return value
    .toLowerCase()
    .split(/\s+/)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function normalizeSector(industry) {
  const normalized = (industry || "").toLowerCase();
  if (normalized.includes("financial")) return "Banking & Financials";
  if (normalized.includes("health")) return "Healthcare";
  if (normalized.includes("power")) return "Power";
  if (normalized.includes("oil") || normalized.includes("gas")) return "Energy";
  if (normalized.includes("metal")) return "Metals";
  if (normalized.includes("capital goods")) return "Capital Goods";
  if (normalized.includes("services")) return "Services";
  if (normalized.includes("telecom")) return "Telecom";
  if (normalized.includes("construction")) return "Construction Materials";
  if (normalized.includes("it") || normalized.includes("software")) return "IT";
  return titleCase(industry || "Diversified");
}

function marketCapBucket(index, symbol) {
  if (LARGE_CAP_SYMBOLS.has(symbol)) return "Large Cap";
  if (index < 120) return "Large / Mid Cap";
  return "Mid Cap";
}

function loadSymbolMaster() {
  if (cachedSymbols) {
    return cachedSymbols;
  }

  const raw = fs.readFileSync(csvPath, "utf8");
  const lines = raw.split(/\r?\n/).filter(Boolean);
  const dataLines = lines.slice(1);

  cachedSymbols = dataLines
    .map((line, index) => {
      const [companyName, industry, symbol, series, isinCode] = parseCsvLine(line);
      if (!symbol) {
        return null;
      }

      return {
        id: `NSE:${symbol}`,
        exchange: "NSE",
        symbol: symbol.toUpperCase(),
        displayName: companyName,
        sector: normalizeSector(industry),
        industry: industry || "Diversified",
        marketCapBucket: marketCapBucket(index, symbol.toUpperCase()),
        series: series || "EQ",
        isinCode: isinCode || "",
        active: true,
      };
    })
    .filter(Boolean);

  return cachedSymbols;
}

function findSymbolMeta(symbol) {
  const normalized = String(symbol || "").trim().toUpperCase();
  return loadSymbolMaster().find((item) => item.symbol === normalized) || null;
}

module.exports = {
  loadSymbolMaster,
  findSymbolMeta,
};
