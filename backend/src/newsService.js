const TOPIC_CONFIG = {
  all: {
    label: "All",
    query: "stock market OR share market OR nifty OR sensex",
    locale: { hl: "en-IN", gl: "IN", ceid: "IN:en" },
  },
  india: {
    label: "India",
    query: "Indian stock market OR NSE OR BSE OR Nifty OR Sensex",
    locale: { hl: "en-IN", gl: "IN", ceid: "IN:en" },
  },
  banking: {
    label: "Banking",
    query: "bank stocks India OR banking sector India",
    locale: { hl: "en-IN", gl: "IN", ceid: "IN:en" },
  },
  earnings: {
    label: "Earnings",
    query: "earnings stocks India",
    locale: { hl: "en-IN", gl: "IN", ceid: "IN:en" },
  },
  global: {
    label: "Global",
    query: "global stock market",
    locale: { hl: "en-US", gl: "US", ceid: "US:en" },
  },
  ipo: {
    label: "IPO",
    query: "IPO market India",
    locale: { hl: "en-IN", gl: "IN", ceid: "IN:en" },
  },
};

const cache = new Map();
const CACHE_TTL_MS = 5 * 60 * 1000;

const fallbackNews = [
  {
    id: "fallback_1",
    title: "Indian market breadth remains in focus as sector rotation accelerates",
    summary:
      "A fallback headline used when live market-news aggregation is temporarily unavailable.",
    source: "NiveshIQ",
    publishedAt: "Latest",
    sentiment: "Neutral",
    topic: "all",
    link: "",
  },
  {
    id: "fallback_2",
    title: "Banking, IT, and capital goods continue to dominate model attention",
    summary:
      "The platform will switch back to live publisher headlines automatically once the feed responds.",
    source: "NiveshIQ",
    publishedAt: "Latest",
    sentiment: "Positive",
    topic: "india",
    link: "",
  },
];

function xmlDecode(value) {
  return String(value || "")
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function extractTag(block, tag) {
  const match = block.match(new RegExp(`<${tag}>([\\s\\S]*?)<\\/${tag}>`, "i"));
  return match ? xmlDecode(match[1]) : "";
}

function inferSentiment(text) {
  const normalized = String(text || "").toLowerCase();
  const positiveHints = ["surge", "rally", "gain", "up", "record", "beat", "rise", "bull"];
  const negativeHints = ["fall", "drop", "down", "slump", "miss", "weak", "bear", "selloff"];
  if (positiveHints.some((hint) => normalized.includes(hint))) return "Positive";
  if (negativeHints.some((hint) => normalized.includes(hint))) return "Negative";
  return "Neutral";
}

function normalizePublisher(title) {
  const parts = String(title || "").split(" - ");
  if (parts.length >= 2) {
    return {
      title: parts.slice(0, -1).join(" - ").trim(),
      source: parts.at(-1).trim(),
    };
  }
  return { title: String(title || "").trim(), source: "" };
}

function buildFeedUrl(topicKey, query) {
  const topic = TOPIC_CONFIG[topicKey] || TOPIC_CONFIG.all;
  const effectiveQuery = query
    ? `${query} stock market OR share price OR NSE OR BSE`
    : topic.query;
  const url = new URL("https://news.google.com/rss/search");
  url.searchParams.set("q", effectiveQuery);
  url.searchParams.set("hl", topic.locale.hl);
  url.searchParams.set("gl", topic.locale.gl);
  url.searchParams.set("ceid", topic.locale.ceid);
  return url.toString();
}

function parseRss(xml, topicKey) {
  const itemMatches = xml.match(/<item>[\s\S]*?<\/item>/gi) || [];
  const items = itemMatches.map((block, index) => {
    const rawTitle = extractTag(block, "title");
    const { title, source } = normalizePublisher(rawTitle);
    const summary = extractTag(block, "description");
    const link = extractTag(block, "link");
    const publishedAt = extractTag(block, "pubDate");
    return {
      id: `${topicKey}_${index}_${title.slice(0, 24).replace(/\W+/g, "_")}`,
      title,
      summary,
      source: source || "Google News",
      publishedAt,
      sentiment: inferSentiment(`${title} ${summary}`),
      topic: topicKey,
      link,
    };
  });
  return items.filter((item) => item.title);
}

async function fetchNews({ topic = "all", query = "" } = {}) {
  const normalizedTopic = TOPIC_CONFIG[topic] ? topic : "all";
  const normalizedQuery = String(query || "").trim();
  const cacheKey = `${normalizedTopic}:${normalizedQuery.toLowerCase()}`;
  const cached = cache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.payload;
  }

  const payloadBase = {
    title: "Market News",
    subtitle: "Live stock-market headlines aggregated for your trading workspace.",
    topics: Object.entries(TOPIC_CONFIG).map(([key, value]) => ({
      key,
      label: value.label,
    })),
    selectedTopic: normalizedTopic,
    query: normalizedQuery,
    updatedAt: new Date().toISOString(),
  };

  try {
    const response = await fetch(buildFeedUrl(normalizedTopic, normalizedQuery), {
      headers: {
        "User-Agent": "NiveshIQ/1.0",
      },
    });
    const xml = await response.text();
    const items = parseRss(xml, normalizedTopic).slice(0, 18);
    const payload = {
      ...payloadBase,
      items: items.length ? items : fallbackNews,
    };
    cache.set(cacheKey, { payload, expiresAt: Date.now() + CACHE_TTL_MS });
    return payload;
  } catch (_error) {
    return {
      ...payloadBase,
      items: fallbackNews,
    };
  }
}

module.exports = {
  fetchNews,
};
