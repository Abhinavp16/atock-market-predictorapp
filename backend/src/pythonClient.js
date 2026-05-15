const DEFAULT_TIMEOUT_MS = Number(process.env.ML_SERVICE_TIMEOUT_MS || 6000);
const DEFAULT_BASE_URL = process.env.ML_SERVICE_BASE_URL || "http://127.0.0.1:8000";

function buildUrl(path, query = {}) {
  const url = new URL(path, DEFAULT_BASE_URL.endsWith("/") ? DEFAULT_BASE_URL : `${DEFAULT_BASE_URL}/`);
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") {
      url.searchParams.set(key, String(value));
    }
  });
  return url;
}

async function requestJson(path, { method = "GET", query, body } = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEFAULT_TIMEOUT_MS);

  try {
    const response = await fetch(buildUrl(path, query), {
      method,
      headers: body ? { "Content-Type": "application/json" } : undefined,
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });

    const text = await response.text();
    const payload = text ? JSON.parse(text) : {};
    if (!response.ok) {
      throw new Error(payload.detail || payload.message || `ML service request failed for ${path}`);
    }
    return payload;
  } finally {
    clearTimeout(timeout);
  }
}

class PythonMarketClient {
  async health() {
    return requestJson("/health");
  }

  async searchSymbols(query) {
    return requestJson("/symbols", { query: { query, limit: 20 } });
  }

  async getQuote(symbol) {
    return requestJson(`/quotes/${String(symbol).toUpperCase()}`);
  }

  async getChart(symbol, range) {
    return requestJson(`/charts/${String(symbol).toUpperCase()}`, { query: { range } });
  }

  async getCompany(symbol) {
    return requestJson(`/company/${String(symbol).toUpperCase()}`);
  }

  async getPrediction(symbol) {
    return requestJson(`/predict/${String(symbol).toUpperCase()}`);
  }

  async train(symbols) {
    return requestJson("/train", { method: "POST", body: { symbols } });
  }
}

module.exports = {
  PythonMarketClient,
};
