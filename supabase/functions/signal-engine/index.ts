import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// ============================================================
// PRO FUTURES SIGNAL ENGINE
// DATA SOURCE: OKX PUBLIC API
// FREE SIGNALS ARE NOT TOUCHED
// ============================================================

// ============================================================
// CONFIG
// ============================================================

const BASE_URL = "https://www.okx.com";

const TIMEFRAME = "15m";
const CANDLE_LIMIT = 200;

const MAX_SYMBOLS_TO_ANALYZE = 30;

const MIN_CONFIDENCE = 80;
const MIN_24H_VOLUME = 10_000_000;

const MIN_ATR_PERCENT = 0.15;
const MAX_ATR_PERCENT = 15;

const SIGNAL_LIFETIME_HOURS = 6;

const MAX_NEW_SIGNALS = 5;

const MIN_DIRECTION_SEPARATION = 5;

// ============================================================
// SUPABASE
// ============================================================

const SUPABASE_URL =
  Deno.env.get("SUPABASE_URL")!;

const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const SUPABASE_HEADERS = {
  "Content-Type": "application/json",
  "apikey": SUPABASE_SERVICE_ROLE_KEY,
  "Authorization":
    `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
};

// ============================================================
// FETCH
// ============================================================

async function fetchJson(url: string) {
  const response = await fetch(url);

  if (!response.ok) {
    const text = await response.text();

    throw new Error(
      `API error ${response.status}: ${text}`
    );
  }

  const data = await response.json();

  if (
    data?.code !== undefined &&
    data.code !== "0" &&
    data.code !== 0
  ) {
    throw new Error(
      `OKX API error ${data.code}: ${
        data.msg ?? "Unknown error"
      }`
    );
  }

  return data;
}

// ============================================================
// SAFE NUMBER
// ============================================================

function safeNumber(
  value: any,
  fallback = 0
) {
  const number =
    Number(value);

  return Number.isFinite(number)
    ? number
    : fallback;
}

// ============================================================
// OKX DATA
// ============================================================

// ------------------------------------------------------------
// Instruments
// ------------------------------------------------------------

async function getInstruments() {
  const data =
    await fetchJson(
      `${BASE_URL}/api/v5/public/instruments` +
      `?instType=SWAP`
    );

  return data?.data ?? [];
}

// ------------------------------------------------------------
// 24h Tickers
// ------------------------------------------------------------

async function getTickers() {
  const data =
    await fetchJson(
      `${BASE_URL}/api/v5/market/tickers` +
      `?instType=SWAP`
    );

  return data?.data ?? [];
}

// ------------------------------------------------------------
// Candles
// ------------------------------------------------------------

async function getCandles(
  instId: string,
  bar: string,
  limit = CANDLE_LIMIT
) {
  const data =
    await fetchJson(
      `${BASE_URL}/api/v5/market/candles` +
      `?instId=${encodeURIComponent(instId)}` +
      `&bar=${encodeURIComponent(bar)}` +
      `&limit=${limit}`
    );

  return data?.data ?? [];
}

// ------------------------------------------------------------
// Open Interest
// ------------------------------------------------------------

async function getOpenInterest(
  instId: string
) {
  try {
    const data =
      await fetchJson(
        `${BASE_URL}/api/v5/public/open-interest` +
        `?instType=SWAP` +
        `&instId=${encodeURIComponent(instId)}`
      );

    return data?.data?.[0] ?? null;
  } catch (error) {
    console.error(
      `OI error ${instId}:`,
      error
    );

    return null;
  }
}

// ------------------------------------------------------------
// Funding
// ------------------------------------------------------------

async function getFunding(
  instId: string
) {
  try {
    const data =
      await fetchJson(
        `${BASE_URL}/api/v5/public/funding-rate` +
        `?instId=${encodeURIComponent(instId)}`
      );

    return data?.data?.[0] ?? null;
  } catch (error) {
    console.error(
      `Funding error ${instId}:`,
      error
    );

    return null;
  }
}

// ============================================================
// HELPERS
// ============================================================

function clamp(
  value: number,
  min = 0,
  max = 100
) {
  if (!Number.isFinite(value)) {
    return min;
  }

  return Math.max(
    min,
    Math.min(max, value)
  );
}

function average(
  values: number[]
) {
  if (!values.length) {
    return 0;
  }

  return (
    values.reduce(
      (sum, value) =>
        sum + value,
      0
    ) / values.length
  );
}

// ============================================================
// EMA
// ============================================================

function calculateEMA(
  values: number[],
  period: number
) {
  if (!values.length) {
    return 0;
  }

  if (
    values.length < period
  ) {
    return values[
      values.length - 1
    ];
  }

  const multiplier =
    2 / (period + 1);

  let ema =
    average(
      values.slice(
        0,
        period
      )
    );

  for (
    let i = period;
    i < values.length;
    i++
  ) {
    ema =
      (
        values[i] - ema
      ) *
        multiplier +
      ema;
  }

  return ema;
}

// ============================================================
// RSI
// ============================================================

function calculateRSI(
  closes: number[],
  period = 14
) {
  if (
    closes.length <= period
  ) {
    return 50;
  }

  let gains = 0;
  let losses = 0;

  for (
    let i = 1;
    i <= period;
    i++
  ) {
    const change =
      closes[i] -
      closes[i - 1];

    if (change > 0) {
      gains += change;
    } else {
      losses +=
        Math.abs(change);
    }
  }

  let averageGain =
    gains / period;

  let averageLoss =
    losses / period;

  for (
    let i = period + 1;
    i < closes.length;
    i++
  ) {
    const change =
      closes[i] -
      closes[i - 1];

    const gain =
      change > 0
        ? change
        : 0;

    const loss =
      change < 0
        ? Math.abs(change)
        : 0;

    averageGain =
      (
        averageGain *
          (period - 1) +
        gain
      ) / period;

    averageLoss =
      (
        averageLoss *
          (period - 1) +
        loss
      ) / period;
  }

  if (
    averageLoss === 0
  ) {
    return 100;
  }

  const rs =
    averageGain /
    averageLoss;

  return (
    100 -
    100 / (1 + rs)
  );
}

// ============================================================
// ATR
// ============================================================

function calculateATR(
  candles: any[],
  period = 14
) {
  if (
    candles.length <= period
  ) {
    return 0;
  }

  const trueRanges: number[] =
    [];

  for (
    let i = 1;
    i < candles.length;
    i++
  ) {
    const high =
      safeNumber(
        candles[i][2]
      );

    const low =
      safeNumber(
        candles[i][3]
      );

    const previousClose =
      safeNumber(
        candles[i - 1][4]
      );

    const tr =
      Math.max(
        high - low,
        Math.abs(
          high -
          previousClose
        ),
        Math.abs(
          low -
          previousClose
        )
      );

    trueRanges.push(tr);
  }

  return average(
    trueRanges.slice(
      -period
    )
  );
}

// ============================================================
// PRICE CHANGE
// ============================================================

function calculatePriceChange(
  closes: number[],
  candlesBack: number
) {
  if (
    closes.length <=
    candlesBack
  ) {
    return 0;
  }

  const latest =
    closes[
      closes.length - 1
    ];

  const previous =
    closes[
      closes.length -
        1 -
        candlesBack
    ];

  if (
    previous <= 0
  ) {
    return 0;
  }

  return (
    (
      (latest - previous) /
      previous
    ) * 100
  );
}

// ============================================================
// TECHNICAL ANALYSIS
// ============================================================

function analyzeTechnical(
  closes: number[]
) {
  const price =
    closes[
      closes.length - 1
    ];

  const ema20 =
    calculateEMA(
      closes,
      20
    );

  const ema50 =
    calculateEMA(
      closes,
      50
    );

  const rsi =
    calculateRSI(
      closes
    );

  let longScore = 50;
  let shortScore = 50;

  // ----------------------------------------------------------
  // PRICE VS EMA20
  // ----------------------------------------------------------

  if (
    price > ema20
  ) {
    longScore += 15;
  } else {
    shortScore += 15;
  }

  // ----------------------------------------------------------
  // EMA20 VS EMA50
  // ----------------------------------------------------------

  if (
    ema20 > ema50
  ) {
    longScore += 20;
  } else {
    shortScore += 20;
  }

  // ----------------------------------------------------------
  // RSI
  // ----------------------------------------------------------

  if (
    rsi >= 50 &&
    rsi <= 65
  ) {
    longScore += 15;
  } else if (
    rsi > 65 &&
    rsi <= 70
  ) {
    longScore += 8;
  }

  if (
    rsi >= 35 &&
    rsi < 50
  ) {
    shortScore += 15;
  } else if (
    rsi >= 30 &&
    rsi < 35
  ) {
    shortScore += 8;
  }

  // ----------------------------------------------------------
  // EXTREME RSI
  // ----------------------------------------------------------

  if (
    rsi > 75
  ) {
    longScore -= 15;
  }

  if (
    rsi < 25
  ) {
    shortScore -= 15;
  }

  return {
    longScore:
      Math.round(
        clamp(longScore)
      ),

    shortScore:
      Math.round(
        clamp(shortScore)
      ),

    ema20,
    ema50,
    rsi,
  };
}

// ============================================================
// MULTI-TIMEFRAME MOMENTUM
// ============================================================

function analyzeMomentum(
  candles15m: any[],
  candles1h: any[],
  candles4h: any[]
) {
  const closes15m =
    candles15m.map(
      (c: any) =>
        safeNumber(c[4])
    );

  const closes1h =
    candles1h.map(
      (c: any) =>
        safeNumber(c[4])
    );

  const closes4h =
    candles4h.map(
      (c: any) =>
        safeNumber(c[4])
    );

  const change15m =
    calculatePriceChange(
      closes15m,
      1
    );

  const change1h =
    calculatePriceChange(
      closes1h,
      1
    );

  const change4h =
    calculatePriceChange(
      closes4h,
      1
    );

  let longScore = 50;
  let shortScore = 50;

  // ----------------------------------------------------------
  // 15M
  // ----------------------------------------------------------

  if (
    change15m > 0.05
  ) {
    longScore += 15;
  } else if (
    change15m < -0.05
  ) {
    shortScore += 15;
  }

  // ----------------------------------------------------------
  // 1H
  // ----------------------------------------------------------

  if (
    change1h > 0.10
  ) {
    longScore += 20;
  } else if (
    change1h < -0.10
  ) {
    shortScore += 20;
  }

  // ----------------------------------------------------------
  // 4H
  // ----------------------------------------------------------

  if (
    change4h > 0.20
  ) {
    longScore += 20;
  } else if (
    change4h < -0.20
  ) {
    shortScore += 20;
  }

  return {
    longScore:
      Math.round(
        clamp(longScore)
      ),

    shortScore:
      Math.round(
        clamp(shortScore)
      ),

    change15m,
    change1h,
    change4h,
  };
}

// ============================================================
// VOLUME
// ============================================================

function analyzeVolume(
  candles: any[]
) {
  // OKX returns the newest candle first.
  // Remove the currently forming candle.

  const closedCandles =
    candles.length > 1
      ? candles.slice(1)
      : candles;

  const volumes =
    closedCandles.map(
      (c: any) =>
        safeNumber(c[5])
    );

  if (
    volumes.length < 21
  ) {
    return {
      score: 50,
      ratio: 1,
    };
  }

  const current =
    volumes[0];

  const previous =
    volumes.slice(
      1,
      21
    );

  const avg =
    average(previous);

  if (
    avg <= 0
  ) {
    return {
      score: 50,
      ratio: 1,
    };
  }

  const ratio =
    current / avg;

  let score = 50;

  if (
    ratio >= 1.1
  ) {
    score += 8;
  }

  if (
    ratio >= 1.5
  ) {
    score += 8;
  }

  if (
    ratio >= 2
  ) {
    score += 9;
  }

  if (
    ratio >= 3
  ) {
    score += 10;
  }

  if (
    ratio < 0.5
  ) {
    score -= 20;
  } else if (
    ratio < 0.75
  ) {
    score -= 10;
  }

  return {
    score:
      Math.round(
        clamp(score)
      ),

    ratio,
  };
}

// ============================================================
// OPEN INTEREST
// ============================================================

function analyzeOpenInterest(
  oi: any
) {
  if (!oi) {
    return {
      longScore: 50,
      shortScore: 50,
      score: 50,
      change: 0,
      interpretation:
        "NEUTRAL",
    };
  }

  const openInterest =
    safeNumber(
      oi.oi
    );

  if (
    openInterest <= 0
  ) {
    return {
      longScore: 50,
      shortScore: 50,
      score: 50,
      change: 0,
      interpretation:
        "NEUTRAL",
    };
  }

  /*
   * OKX public OI endpoint gives current OI.
   *
   * We deliberately do not invent historical OI.
   * Until a reliable historical series is available,
   * OI remains neutral rather than producing fake
   * LONG_BUILDUP / SHORT_BUILDUP signals.
   */

  return {
    longScore: 50,
    shortScore: 50,
    score: 50,
    change: 0,
    interpretation:
      "CURRENT_OI_ONLY",
    openInterest,
  };
}

// ============================================================
// FUNDING
// ============================================================

function analyzeFunding(
  fundingRate: number | null
) {
  if (
    fundingRate === null ||
    !Number.isFinite(
      fundingRate
    )
  ) {
    return {
      longScore: 50,
      shortScore: 50,
      fundingPercent: 0,
      available: false,
    };
  }

  const fundingPercent =
    fundingRate * 100;

  let longScore = 50;
  let shortScore = 50;

  // ----------------------------------------------------------
  // NEGATIVE FUNDING -> LONG
  // ----------------------------------------------------------

  if (
    fundingPercent < -0.01
  ) {
    longScore += 20;
  }

  // ----------------------------------------------------------
  // POSITIVE FUNDING -> SHORT
  // ----------------------------------------------------------

  if (
    fundingPercent > 0.01
  ) {
    shortScore += 20;
  }

  // ----------------------------------------------------------
  // EXTREME POSITIVE FUNDING
  // ----------------------------------------------------------

  if (
    fundingPercent > 0.05
  ) {
    shortScore += 10;
    longScore -= 10;
  }

  // ----------------------------------------------------------
  // EXTREME NEGATIVE FUNDING
  // ----------------------------------------------------------

  if (
    fundingPercent < -0.05
  ) {
    longScore += 10;
    shortScore -= 10;
  }

  return {
    longScore:
      Math.round(
        clamp(longScore)
      ),

    shortScore:
      Math.round(
        clamp(shortScore)
      ),

    fundingPercent,

    available: true,
  };
}

// ============================================================
// DIRECTION
// ============================================================

function determineDirection(
  technical: any,
  momentum: any,
  volume: number,
  oi: any,
  funding: any
) {
  let longScore = 0;
  let shortScore = 0;

  // Technical — 30%
  longScore +=
    technical.longScore *
    0.30;

  shortScore +=
    technical.shortScore *
    0.30;

  // Momentum — 30%
  longScore +=
    momentum.longScore *
    0.30;

  shortScore +=
    momentum.shortScore *
    0.30;

  // Volume — neutral
  longScore +=
    volume * 0.10;

  shortScore +=
    volume * 0.10;

  // OI — 20%
  longScore +=
    oi.longScore * 0.20;

  shortScore +=
    oi.shortScore * 0.20;

  // Funding — 10%
  longScore +=
    funding.longScore * 0.10;

  shortScore +=
    funding.shortScore * 0.10;

  const direction =
    longScore >= shortScore
      ? "LONG"
      : "SHORT";

  const winningScore =
    Math.max(
      longScore,
      shortScore
    );

  const losingScore =
    Math.min(
      longScore,
      shortScore
    );

  return {
    direction,

    longScore:
      Math.round(
        clamp(longScore)
      ),

    shortScore:
      Math.round(
        clamp(shortScore)
      ),

    separation:
      winningScore -
      losingScore,
  };
}

// ============================================================
// DIRECTIONAL SCORE
// ============================================================

function calculateDirectionalScore(
  direction: string,
  technical: any,
  momentum: any,
  oi: any,
  funding: any
) {
  let score = 50;

  if (
    direction === "LONG"
  ) {
    score +=
      (
        technical.longScore -
        50
      ) * 0.30;

    score +=
      (
        momentum.longScore -
        50
      ) * 0.30;

    score +=
      (
        oi.longScore -
        50
      ) * 0.20;

    score +=
      (
        funding.longScore -
        50
      ) * 0.20;
  } else {
    score +=
      (
        technical.shortScore -
        50
      ) * 0.30;

    score +=
      (
        momentum.shortScore -
        50
      ) * 0.30;

    score +=
      (
        oi.shortScore -
        50
      ) * 0.20;

    score +=
      (
        funding.shortScore -
        50
      ) * 0.20;
  }

  return Math.round(
    clamp(score)
  );
}

// ============================================================
// CONFIDENCE
// ============================================================

function calculateConfidence(
  direction: string,
  technical: any,
  momentum: any,
  volume: number,
  oi: any,
  funding: any,
  directional: number,
  separation: number
) {
  const technicalScore =
    direction === "LONG"
      ? technical.longScore
      : technical.shortScore;

  const momentumScore =
    direction === "LONG"
      ? momentum.longScore
      : momentum.shortScore;

  const oiScore =
    direction === "LONG"
      ? oi.longScore
      : oi.shortScore;

  const fundingScore =
    direction === "LONG"
      ? funding.longScore
      : funding.shortScore;

  let confidence =
    technicalScore * 0.25 +
    momentumScore * 0.25 +
    volume * 0.15 +
    oiScore * 0.15 +
    fundingScore * 0.10 +
    directional * 0.10;

  if (
    separation >= 20
  ) {
    confidence += 5;
  } else if (
    separation >= 12
  ) {
    confidence += 3;
  } else if (
    separation < 5
  ) {
    confidence -= 12;
  } else if (
    separation <
    MIN_DIRECTION_SEPARATION
  ) {
    confidence -= 6;
  }

  const weakestFactor =
    Math.min(
      technicalScore,
      momentumScore,
      volume,
      oiScore,
      fundingScore,
      directional
    );

  if (
    weakestFactor < 30
  ) {
    confidence -= 15;
  } else if (
    weakestFactor < 40
  ) {
    confidence -= 10;
  } else if (
    weakestFactor < 50
  ) {
    confidence -= 5;
  }

  return Math.round(
    clamp(confidence)
  );
}

// ============================================================
// RISK
// ============================================================

function calculateRiskLevel(
  atrPercent: number,
  confidence: number
) {
  if (
    confidence >= 90 &&
    atrPercent < 2.5
  ) {
    return "LOW";
  }

  if (
    confidence >= 82 &&
    atrPercent < 5
  ) {
    return "MEDIUM";
  }

  return "HIGH";
}

// ============================================================
// PRICE ROUNDING
// ============================================================

function roundPrice(
  price: number
) {
  if (
    price >= 1000
  ) {
    return Number(
      price.toFixed(2)
    );
  }

  if (
    price >= 1
  ) {
    return Number(
      price.toFixed(4)
    );
  }

  if (
    price >= 0.01
  ) {
    return Number(
      price.toFixed(6)
    );
  }

  return Number(
    price.toPrecision(6)
  );
}

// ============================================================
// ACTIVE SIGNAL CHECK
// ============================================================

async function hasActiveSignal(
  symbol: string
) {
  const url =
    `${SUPABASE_URL}/rest/v1/signals` +
    `?symbol=eq.${encodeURIComponent(symbol)}` +
    `&market=eq.FUTURES` +
    `&status=in.(ACTIVE,TP1_HIT,TP2_HIT)` +
    `&select=id`;

  const response =
    await fetch(
      url,
      {
        headers:
          SUPABASE_HEADERS,
      }
    );

  if (
    !response.ok
  ) {
    const text =
      await response.text();

    throw new Error(
      `Active signal check failed: ${response.status}: ${text}`
    );
  }

  const data =
    await response.json();

  return (
    Array.isArray(data) &&
    data.length > 0
  );
}

// ============================================================
// SAVE SIGNAL
// ============================================================

async function saveSignal(
  signal: any
) {
  if (
    await hasActiveSignal(
      signal.symbol
    )
  ) {
    return {
      saved: false,
      reason:
        "ACTIVE_SIGNAL_EXISTS",
    };
  }

  const payload = {
    symbol:
      signal.symbol,

    token_address:
      null,

    market:
      "FUTURES",

    timeframe:
      signal.timeframe,

    direction:
      signal.direction,

    entry_price:
      signal.entryPrice,

    stop_loss:
      signal.stopLoss,

    take_profit_1:
      signal.takeProfit1,

    take_profit_2:
      signal.takeProfit2,

    take_profit_3:
      signal.takeProfit3,

    confidence:
      signal.confidence,

    risk_level:
      signal.riskLevel,

    risk_reward:
      signal.riskReward,

    reason:
      signal.reason,

    technical_score:
      signal.technicalScore,

    momentum_score:
      signal.momentumScore,

    volume_score:
      signal.volumeScore,

    whale_score:
      null,

    open_interest_score:
      signal.openInterestScore,

    funding_score:
      signal.fundingScore,

    status:
      "ACTIVE",

    expires_at:
      signal.expiresAt,
  };

  const response =
    await fetch(
      `${SUPABASE_URL}/rest/v1/signals`,
      {
        method: "POST",

        headers: {
          ...SUPABASE_HEADERS,

          Prefer:
            "return=representation",
        },

        body:
          JSON.stringify(
            payload
          ),
      }
    );

  if (
    !response.ok
  ) {
    const error =
      await response.text();

    throw new Error(
      `Signal save failed: ${error}`
    );
  }

  return {
    saved: true,

    data:
      await response.json(),
  };
}

// ============================================================
// ANALYZE SYMBOL
// ============================================================

async function analyzeSymbol(
  instId: string,
  ticker: any
) {
  const [
    candles15m,
    candles1h,
    candles4h,
    oi,
    funding,
  ] =
    await Promise.all([
      getCandles(
        instId,
        "15m",
        200
      ),

      getCandles(
        instId,
        "1H",
        100
      ),

      getCandles(
        instId,
        "4H",
        100
      ),

      getOpenInterest(
        instId
      ),

      getFunding(
        instId
      ),
    ]);

  if (
    !Array.isArray(
      candles15m
    ) ||
    candles15m.length < 60
  ) {
    throw new Error(
      "Not enough 15m candle data"
    );
  }

  if (
    !Array.isArray(
      candles1h
    ) ||
    candles1h.length < 30
  ) {
    throw new Error(
      "Not enough 1H candle data"
    );
  }

  if (
    !Array.isArray(
      candles4h
    ) ||
    candles4h.length < 30
  ) {
    throw new Error(
      "Not enough 4H candle data"
    );
  }

  // OKX candles are newest first.
  const ordered15m =
    [...candles15m]
      .reverse();

  const ordered1h =
    [...candles1h]
      .reverse();

  const ordered4h =
    [...candles4h]
      .reverse();

  const closes15m =
    ordered15m.map(
      (c: any) =>
        safeNumber(c[4])
    );

  const price =
    closes15m[
      closes15m.length - 1
    ];

  if (
    !Number.isFinite(price) ||
    price <= 0
  ) {
    throw new Error(
      "Invalid price"
    );
  }

  // ==========================================================
  // ANALYSIS
  // ==========================================================

  const technical =
    analyzeTechnical(
      closes15m
    );

  const momentum =
    analyzeMomentum(
      ordered15m,
      ordered1h,
      ordered4h
    );

  const volume =
    analyzeVolume(
      candles15m
    );

  const atr =
    calculateATR(
      ordered15m,
      14
    );

  const atrPercent =
    (
      atr / price
    ) * 100;

  const oiAnalysis =
    analyzeOpenInterest(
      oi
    );

  const fundingRate =
    funding
      ? safeNumber(
          funding.fundingRate,
          0
        )
      : null;

  const fundingAnalysis =
    analyzeFunding(
      fundingRate
    );

  // ==========================================================
  // DIRECTION
  // ==========================================================

  const directionData =
    determineDirection(
      technical,
      momentum,
      volume.score,
      oiAnalysis,
      fundingAnalysis
    );

  const direction =
    directionData.direction;

  // ==========================================================
  // DIRECTIONAL SCORE
  // ==========================================================

  const directionalScore =
    calculateDirectionalScore(
      direction,
      technical,
      momentum,
      oiAnalysis,
      fundingAnalysis
    );

  // ==========================================================
  // CONFIDENCE
  // ==========================================================

  const confidence =
    calculateConfidence(
      direction,
      technical,
      momentum,
      volume.score,
      oiAnalysis,
      fundingAnalysis,
      directionalScore,
      directionData.separation
    );

  // ==========================================================
  // ENTRY / SL / TP
  // ==========================================================

  const entryPrice =
    price;

  let stopMultiplier =
    1.5;

  if (
    atrPercent > 5
  ) {
    stopMultiplier =
      1.75;
  }

  if (
    atrPercent > 8
  ) {
    stopMultiplier =
      2;
  }

  const stopDistance =
    atr *
    stopMultiplier;

  const tp1Distance =
    atr * 3.75;

  const tp2Distance =
    atr * 5.25;

  const tp3Distance =
    atr * 6.75;

  let stopLoss: number;
  let tp1: number;
  let tp2: number;
  let tp3: number;

  if (
    direction === "LONG"
  ) {
    stopLoss =
      entryPrice -
      stopDistance;

    tp1 =
      entryPrice +
      tp1Distance;

    tp2 =
      entryPrice +
      tp2Distance;

    tp3 =
      entryPrice +
      tp3Distance;
  } else {
    stopLoss =
      entryPrice +
      stopDistance;

    tp1 =
      entryPrice -
      tp1Distance;

    tp2 =
      entryPrice -
      tp2Distance;

    tp3 =
      entryPrice -
      tp3Distance;
  }

  if (
    stopLoss <= 0 ||
    tp1 <= 0 ||
    tp2 <= 0 ||
    tp3 <= 0
  ) {
    throw new Error(
      "Invalid SL/TP calculation"
    );
  }

  // ==========================================================
  // RISK / REWARD
  // ==========================================================

  const risk =
    Math.abs(
      entryPrice -
      stopLoss
    );

  const reward =
    Math.abs(
      tp1 -
      entryPrice
    );

  const riskReward =
    risk > 0
      ? reward / risk
      : 0;

  const riskLevel =
    calculateRiskLevel(
      atrPercent,
      confidence
    );

  // ==========================================================
  // QUALIFICATION
  // ==========================================================

  const rejectionReasons:
    string[] = [];

  if (
    confidence <
    MIN_CONFIDENCE
  ) {
    rejectionReasons.push(
      `CONFIDENCE_BELOW_${MIN_CONFIDENCE}`
    );
  }

  if (
    atrPercent <
    MIN_ATR_PERCENT
  ) {
    rejectionReasons.push(
      "ATR_TOO_LOW"
    );
  }

  if (
    atrPercent >
    MAX_ATR_PERCENT
  ) {
    rejectionReasons.push(
      "ATR_TOO_HIGH"
    );
  }

  // ----------------------------------------------------------
  // 1H MOMENTUM CONFIRMATION
  // ----------------------------------------------------------

  if (
    direction === "LONG" &&
    momentum.change1h <= 0
  ) {
    rejectionReasons.push(
      "LONG_1H_MOMENTUM_NOT_CONFIRMED"
    );
  }

  if (
    direction === "SHORT" &&
    momentum.change1h >= 0
  ) {
    rejectionReasons.push(
      "SHORT_1H_MOMENTUM_NOT_CONFIRMED"
    );
  }

  // ----------------------------------------------------------
  // RISK / REWARD
  // ----------------------------------------------------------

  if (
    riskReward < 2
  ) {
    rejectionReasons.push(
      "RISK_REWARD_TOO_LOW"
    );
  }

  // ----------------------------------------------------------
  // DIRECTIONAL TECHNICAL
  // ----------------------------------------------------------

  const directionScore =
    direction === "LONG"
      ? technical.longScore
      : technical.shortScore;

  if (
    directionScore < 55
  ) {
    rejectionReasons.push(
      "DIRECTIONAL_TECHNICAL_SCORE_TOO_LOW"
    );
  }

  // ----------------------------------------------------------
  // MOMENTUM
  // ----------------------------------------------------------

  const momentumScore =
    direction === "LONG"
      ? momentum.longScore
      : momentum.shortScore;

  if (
    momentumScore < 50
  ) {
    rejectionReasons.push(
      "DIRECTIONAL_MOMENTUM_TOO_LOW"
    );
  }

  // ----------------------------------------------------------
  // DIRECTION SEPARATION
  // ----------------------------------------------------------

  if (
    directionData.separation <
    MIN_DIRECTION_SEPARATION
  ) {
    rejectionReasons.push(
      "DIRECTION_TOO_CLOSE"
    );
  }

  const qualifies =
    rejectionReasons.length === 0;

  // ==========================================================
  // REASON
  // ==========================================================

  const reasons:
    string[] = [];

  if (
    direction === "LONG"
  ) {
    reasons.push(
      "Bullish market structure"
    );
  } else {
    reasons.push(
      "Bearish market structure"
    );
  }

  if (
    directionScore >= 70
  ) {
    reasons.push(
      "Strong technical confirmation"
    );
  }

  if (
    direction === "LONG" &&
    momentum.change1h > 0
  ) {
    reasons.push(
      "Positive 1h momentum"
    );
  }

  if (
    direction === "SHORT" &&
    momentum.change1h < 0
  ) {
    reasons.push(
      "Negative 1h momentum"
    );
  }

  if (
    direction === "LONG" &&
    momentum.change4h > 0
  ) {
    reasons.push(
      "Positive 4h trend confirmation"
    );
  }

  if (
    direction === "SHORT" &&
    momentum.change4h < 0
  ) {
    reasons.push(
      "Negative 4h trend confirmation"
    );
  }

  if (
    volume.score >= 65
  ) {
    reasons.push(
      "Above-average volume"
    );
  }

  if (
    fundingAnalysis.available &&
    direction === "LONG" &&
    fundingAnalysis.longScore >= 65
  ) {
    reasons.push(
      "Funding supports LONG"
    );
  }

  if (
    fundingAnalysis.available &&
    direction === "SHORT" &&
    fundingAnalysis.shortScore >= 65
  ) {
    reasons.push(
      "Funding supports SHORT"
    );
  }

  if (
    reasons.length === 0
  ) {
    reasons.push(
      "Multiple market factors aligned"
    );
  }

  // ==========================================================
  // EXPIRATION
  // ==========================================================

  const expiresAt =
    new Date(
      Date.now() +
        SIGNAL_LIFETIME_HOURS *
          60 *
          60 *
          1000
    ).toISOString();

  // ==========================================================
  // RESULT
  // ==========================================================

  return {
    symbol:
      instId,

    timeframe:
      TIMEFRAME,

    direction,

    price,

    ema20:
      technical.ema20,

    ema50:
      technical.ema50,

    rsi:
      technical.rsi,

    atr,

    atrPercent,

    fundingRate:
      fundingRate ?? 0,

    fundingPercent:
      fundingAnalysis.fundingPercent,

    openInterest:
      oi
        ? safeNumber(
            oi.oi
          )
        : 0,

    oiChange:
      oiAnalysis.change,

    oiInterpretation:
      oiAnalysis.interpretation,

    technicalScore:
      direction === "LONG"
        ? technical.longScore
        : technical.shortScore,

    momentumScore:
      direction === "LONG"
        ? momentum.longScore
        : momentum.shortScore,

    volumeScore:
      volume.score,

    whaleScore:
      null,

    openInterestScore:
      direction === "LONG"
        ? oiAnalysis.longScore
        : oiAnalysis.shortScore,

    fundingScore:
      direction === "LONG"
        ? fundingAnalysis.longScore
        : fundingAnalysis.shortScore,

    directionalScore,

    longScore:
      directionData.longScore,

    shortScore:
      directionData.shortScore,

    directionSeparation:
      directionData.separation,

    confidence,

    entryPrice:
      roundPrice(
        entryPrice
      ),

    stopLoss:
      roundPrice(
        stopLoss
      ),

    takeProfit1:
      roundPrice(
        tp1
      ),

    takeProfit2:
      roundPrice(
        tp2
      ),

    takeProfit3:
      roundPrice(
        tp3
      ),

    riskReward:
      Number(
        riskReward.toFixed(2)
      ),

    riskLevel,

    reason:
      reasons.join(
        " • "
      ),

    qualifies,

    rejectionReasons,

    expiresAt,

    market:
      "FUTURES",

    status:
      "ACTIVE",

    source:
      "OKX",

    ticker24hVolume:
      safeNumber(
        ticker?.volCcy24h ??
        0
      ),
  };
}

// ============================================================
// MAIN
// ============================================================

Deno.serve(
  async () => {
    try {
      // ======================================================
      // 1. MARKET DATA
      // ======================================================

      const [
        instruments,
        tickers,
      ] =
        await Promise.all([
          getInstruments(),
          getTickers(),
        ]);

      // ======================================================
      // 2. VALID USDT PERPETUALS
      // ======================================================

      const validInstruments =
        instruments.filter(
          (item: any) =>
            item?.instType ===
              "SWAP" &&
            item?.settleCcy ===
              "USDT" &&
            item?.state ===
              "live"
        );

      const validSymbols =
        new Set(
          validInstruments.map(
            (item: any) =>
              item.instId
          )
        );

      // ======================================================
      // 3. FILTER MARKET
      // ======================================================

      const marketCandidates =
        (
          Array.isArray(
            tickers
          )
            ? tickers
            : []
        )
          .filter(
            (ticker: any) =>
              validSymbols.has(
                ticker.instId
              )
          )
          .map(
            (ticker: any) => ({
              ...ticker,

              volume24h:
                safeNumber(
                  ticker.volCcy24h
                ),

              lastPrice:
                safeNumber(
                  ticker.last
                ),

              priceChangePercent:
                safeNumber(
                  ticker.sodUtc8
                ),
            })
          )
          .filter(
            (ticker: any) =>
              ticker.lastPrice > 0 &&
              ticker.volume24h >=
                MIN_24H_VOLUME
          )
          .sort(
            (
              a: any,
              b: any
            ) =>
              b.volume24h -
              a.volume24h
          )
          .slice(
            0,
            MAX_SYMBOLS_TO_ANALYZE
          );

      // ======================================================
      // 4. ANALYZE
      // ======================================================

      const analyses:
        any[] = [];

      for (
        const ticker of
          marketCandidates
      ) {
        try {
          const analysis =
            await analyzeSymbol(
              ticker.instId,
              ticker
            );

          analyses.push(
            analysis
          );
        } catch (
          error
        ) {
          console.error(
            `ANALYSIS ERROR ${ticker.instId}:`,
            error
          );

          analyses.push({
            symbol:
              ticker.instId,

            qualifies:
              false,

            confidence:
              0,

            error:
              error instanceof Error
                ? error.message
                : String(error),
          });
        }
      }

      // ======================================================
      // 5. SORT
      // ======================================================

      analyses.sort(
        (
          a,
          b
        ) =>
          Number(
            b.confidence ??
            0
          ) -
          Number(
            a.confidence ??
            0
          )
      );

      // ======================================================
      // 6. QUALIFIED
      // ======================================================

      const candidates =
        analyses.filter(
          (
            analysis
          ) =>
            analysis.qualifies ===
            true
        );

      // ======================================================
      // 7. SAVE
      // ======================================================

      const savedSignals:
        any[] = [];

      for (
        const candidate of
          candidates.slice(
            0,
            MAX_NEW_SIGNALS
          )
      ) {
        try {
          const result =
            await saveSignal(
              candidate
            );

          savedSignals.push({
            symbol:
              candidate.symbol,

            direction:
              candidate.direction,

            confidence:
              candidate.confidence,

            riskLevel:
              candidate.riskLevel,

            riskReward:
              candidate.riskReward,

            saved:
              result.saved,

            reason:
              result.reason ??
              null,
          });
        } catch (
          error
        ) {
          savedSignals.push({
            symbol:
              candidate.symbol,

            saved:
              false,

            error:
              error instanceof Error
                ? error.message
                : String(error),
          });
        }
      }

      // ======================================================
      // 8. RESPONSE
      // ======================================================

      return new Response(
        JSON.stringify({
          success:
            true,

          provider:
            "OKX",

          timeframe:
            TIMEFRAME,

          marketUniverse:
            validSymbols.size,

          marketCandidates:
            marketCandidates.length,

          analyzed:
            analyses.length,

          candidates:
            candidates.length,

          savedSignals,

          analyzedAt:
            new Date().toISOString(),

          results:
            analyses.slice(
              0,
              MAX_SYMBOLS_TO_ANALYZE
            ),
        }),
        {
          status: 200,

          headers: {
            "Content-Type":
              "application/json",
          },
        }
      );
    } catch (
      error
    ) {
      console.error(
        "PRO FUTURES signal-engine error:",
        error
      );

      return new Response(
        JSON.stringify({
          success:
            false,

          error:
            error instanceof Error
              ? error.message
              : String(error),
        }),
        {
          status: 500,

          headers: {
            "Content-Type":
              "application/json",
          },
        }
      );
    }
  }
);