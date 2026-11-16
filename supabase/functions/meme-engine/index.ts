import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const PROFILES_URL =
  "https://api.dexscreener.com/token-profiles/latest/v1";

const TOKEN_PAIRS_URL =
  "https://api.dexscreener.com/token-pairs/v1";

const MIN_LIQUIDITY = 15_000;
const MIN_MARKET_CAP = 30_000;
const MAX_MARKET_CAP = 5_000_000;
const MIN_VOLUME_1H = 20_000;

const MIN_SCORE = 75;

async function fetchJson(url: string) {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(
      `API error ${response.status}: ${url}`
    );
  }

  return await response.json();
}

// ============================================================
// PROFILES
// ============================================================

async function getTrendingProfiles() {
  const data =
    await fetchJson(PROFILES_URL);

  return Array.isArray(data)
    ? data
    : [];
}

// ============================================================
// TOKEN PAIRS
// ============================================================

async function getTokenPairs(
  tokenAddress: string
) {
  const data =
    await fetchJson(
      `${TOKEN_PAIRS_URL}/solana/${tokenAddress}`
    );

  return Array.isArray(data)
    ? data
    : [];
}

// ============================================================
// NORMALIZE PAIR
// ============================================================

function normalizePair(pair: any) {
  return {
    chainId: pair.chainId,
    dexId: pair.dexId,

    symbol:
      pair.baseToken?.symbol ??
      "UNKNOWN",

    name:
      pair.baseToken?.name ??
      "Unknown",

    address:
      pair.baseToken?.address ??
      null,

    price:
      Number(pair.priceUsd ?? 0),

    priceChange5m:
      Number(
        pair.priceChange?.m5 ?? 0
      ),

    priceChange1h:
      Number(
        pair.priceChange?.h1 ?? 0
      ),

    priceChange6h:
      Number(
        pair.priceChange?.h6 ?? 0
      ),

    priceChange24h:
      Number(
        pair.priceChange?.h24 ?? 0
      ),

    volume5m:
      Number(
        pair.volume?.m5 ?? 0
      ),

    volume1h:
      Number(
        pair.volume?.h1 ?? 0
      ),

    volume6h:
      Number(
        pair.volume?.h6 ?? 0
      ),

    volume24h:
      Number(
        pair.volume?.h24 ?? 0
      ),

    liquidity:
      Number(
        pair.liquidity?.usd ?? 0
      ),

    marketCap:
      Number(
        pair.marketCap ??
        pair.fdv ??
        0
      ),

    fdv:
      Number(
        pair.fdv ?? 0
      ),

    pairAddress:
      pair.pairAddress ??
      null,

    pairCreatedAt:
      pair.pairCreatedAt ??
      null,

    txns5m:
      pair.txns?.m5 ?? null,

    txns1h:
      pair.txns?.h1 ?? null,

    txns6h:
      pair.txns?.h6 ?? null,

    txns24h:
      pair.txns?.h24 ?? null,

    url:
      pair.url ?? null,
  };
}

// ============================================================
// BASIC SAFETY FILTER
// ============================================================

function passesSafetyFilter(
  token: any
): boolean {

  if (!token.address) {
    return false;
  }

  if (
    token.price <= 0
  ) {
    return false;
  }

  if (
    token.liquidity <
    MIN_LIQUIDITY
  ) {
    return false;
  }

  if (
    token.marketCap <
      MIN_MARKET_CAP ||
    token.marketCap >
      MAX_MARKET_CAP
  ) {
    return false;
  }

  if (
    token.volume1h <
    MIN_VOLUME_1H
  ) {
    return false;
  }

  return true;
}

// ============================================================
// CLAMP
// ============================================================

function clamp(
  value: number,
  min = 0,
  max = 100
) {
  return Math.max(
    min,
    Math.min(max, value)
  );
}

// ============================================================
// MOMENTUM SCORE
// ============================================================

function calculateMomentumScore(
  token: any
): number {

  const change1h =
    token.priceChange1h;

  const change5m =
    token.priceChange5m;

  let score = 50;

  // 1h momentum
  if (change1h >= 5) {
    score += 10;
  }

  if (change1h >= 10) {
    score += 10;
  }

  if (change1h >= 25) {
    score += 10;
  }

  if (change1h >= 50) {
    score += 5;
  }

  // Short-term momentum
  if (change5m > 0) {
    score += 5;
  }

  if (change5m >= 3) {
    score += 5;
  }

  // Penalize extreme collapse
  if (change1h < -20) {
    score -= 30;
  }

  return Math.round(
    clamp(score)
  );
}

// ============================================================
// LIQUIDITY SCORE
// ============================================================

function calculateLiquidityScore(
  token: any
): number {

  const liquidity =
    token.liquidity;

  if (
    liquidity >= 1_000_000
  ) {
    return 100;
  }

  if (
    liquidity >= 500_000
  ) {
    return 90;
  }

  if (
    liquidity >= 250_000
  ) {
    return 80;
  }

  if (
    liquidity >= 100_000
  ) {
    return 70;
  }

  if (
    liquidity >= 50_000
  ) {
    return 60;
  }

  if (
    liquidity >= 25_000
  ) {
    return 50;
  }

  return 40;
}

// ============================================================
// VOLUME SCORE
// ============================================================

function calculateVolumeScore(
  token: any
): number {

  const volume =
    token.volume1h;

  const liquidity =
    token.liquidity;

  if (
    liquidity <= 0
  ) {
    return 0;
  }

  const ratio =
    volume / liquidity;

  let score = 50;

  if (ratio >= 0.5) {
    score += 10;
  }

  if (ratio >= 1) {
    score += 15;
  }

  if (ratio >= 2) {
    score += 15;
  }

  if (ratio >= 4) {
    score += 10;
  }

  return Math.round(
    clamp(score)
  );
}

// ============================================================
// BUY / SELL PRESSURE
// ============================================================

function calculatePressureScore(
  token: any
): number {

  const txns =
    token.txns1h;

  if (!txns) {
    return 50;
  }

  const buys =
    Number(txns.buys ?? 0);

  const sells =
    Number(txns.sells ?? 0);

  const total =
    buys + sells;

  if (total <= 0) {
    return 50;
  }

  const buyRatio =
    buys / total;

  return Math.round(
    clamp(
      30 + buyRatio * 70
    )
  );
}

// ============================================================
// MARKET CAP / UPSIDE SCORE
// ============================================================

function calculateUpsideScore(
  token: any
): number {

  const marketCap =
    token.marketCap;

  if (
    marketCap <= 0
  ) {
    return 0;
  }

  if (
    marketCap <= 100_000
  ) {
    return 100;
  }

  if (
    marketCap <= 250_000
  ) {
    return 90;
  }

  if (
    marketCap <= 500_000
  ) {
    return 80;
  }

  if (
    marketCap <= 1_000_000
  ) {
    return 70;
  }

  if (
    marketCap <= 2_500_000
  ) {
    return 60;
  }

  return 50;
}

// ============================================================
// VOLUME ACCELERATION
// ============================================================

function calculateAccelerationScore(
  token: any
): number {

  const volume1h =
    token.volume1h;

  const volume24h =
    token.volume24h;

  if (
    volume1h <= 0 ||
    volume24h <= 0
  ) {
    return 50;
  }

  const expectedHourly =
    volume24h / 24;

  if (
    expectedHourly <= 0
  ) {
    return 50;
  }

  const acceleration =
    volume1h /
    expectedHourly;

  let score = 50;

  if (
    acceleration >= 1.5
  ) {
    score += 10;
  }

  if (
    acceleration >= 2
  ) {
    score += 10;
  }

  if (
    acceleration >= 4
  ) {
    score += 15;
  }

  if (
    acceleration >= 8
  ) {
    score += 15;
  }

  return Math.round(
    clamp(score)
  );
}

// ============================================================
// PAIR AGE SCORE
// ============================================================

function calculateAgeScore(
  token: any
): number {

  if (
    !token.pairCreatedAt
  ) {
    return 50;
  }

  const created =
    Number(
      token.pairCreatedAt
    );

  if (
    !created ||
    Number.isNaN(created)
  ) {
    return 50;
  }

  const ageHours =
    (
      Date.now() -
      created
    ) /
    (
      1000 *
      60 *
      60
    );

  // Too new = dangerous
  if (
    ageHours < 1
  ) {
    return 35;
  }

  if (
    ageHours < 6
  ) {
    return 60;
  }

  if (
    ageHours < 24
  ) {
    return 75;
  }

  if (
    ageHours < 72
  ) {
    return 85;
  }

  return 70;
}

// ============================================================
// TOTAL AI SCORE
// ============================================================

function calculateAIScore(
  token: any
) {

  const momentum =
    calculateMomentumScore(
      token
    );

  const liquidity =
    calculateLiquidityScore(
      token
    );

  const volume =
    calculateVolumeScore(
      token
    );

  const pressure =
    calculatePressureScore(
      token
    );

  const upside =
    calculateUpsideScore(
      token
    );

  const acceleration =
    calculateAccelerationScore(
      token
    );

  const age =
    calculateAgeScore(
      token
    );

  const score =
    Math.round(

      momentum * 0.20 +

      liquidity * 0.15 +

      volume * 0.15 +

      pressure * 0.15 +

      upside * 0.10 +

      acceleration * 0.15 +

      age * 0.10

    );

  return {
    score,

    momentumScore:
      momentum,

    liquidityScore:
      liquidity,

    volumeScore:
      volume,

    pressureScore:
      pressure,

    upsideScore:
      upside,

    accelerationScore:
      acceleration,

    ageScore:
      age,
  };
}

// ============================================================
// FINAL MEME SIGNAL GENERATOR
// ============================================================

function generateMemeSignal(token: any) {
  if (!token.qualifies) {
    return null;
  }

  const price = Number(token.price ?? 0);

  if (price <= 0) {
    return null;
  }

  // ==========================================================
  // EXTREME PUMP PROTECTION
  // ==========================================================

  const change1h =
    Number(token.priceChange1h ?? 0);

  const change5m =
    Number(token.priceChange5m ?? 0);

  // Don't generate a fresh LONG after an extreme pump.
  if (change1h >= 2000) {
    return null;
  }

  // Strong short-term reversal protection.
  if (change5m <= -35) {
    return null;
  }

  // ==========================================================
  // DIRECTION
  // ==========================================================

  const direction = "LONG";

  // ==========================================================
  // ENTRY
  // ==========================================================

  const entryPrice = price;

  // ==========================================================
  // DYNAMIC STOP LOSS
  // ==========================================================

  let stopPercent = 0.10;

  if (change1h >= 100) {
    stopPercent = 0.11;
  }

  if (change1h >= 300) {
    stopPercent = 0.12;
  }

  if (change1h >= 700) {
    stopPercent = 0.13;
  }

  if (change1h >= 1200) {
    stopPercent = 0.14;
  }

  const stopLoss =
    entryPrice * (1 - stopPercent);

  // ==========================================================
  // TAKE PROFITS
  // ==========================================================

  // Minimum target = 2R
  const risk =
    entryPrice - stopLoss;

  const tp1 =
    entryPrice + risk * 2;

  const tp2 =
    entryPrice + risk * 3.5;

  const tp3 =
    entryPrice + risk * 5;

  // ==========================================================
  // RISK / REWARD
  // ==========================================================

  const reward =
    tp1 - entryPrice;

  const riskReward =
    risk > 0
      ? reward / risk
      : 0;

  // ==========================================================
  // FINAL R:R PROTECTION
  // ==========================================================

  if (riskReward < 2) {
    return null;
  }

  // ==========================================================
  // RISK LEVEL
  // ==========================================================

  let riskLevel = "HIGH";

  if (
    token.liquidity >= 100_000 &&
    token.ageScore >= 70 &&
    change1h < 300
  ) {
    riskLevel = "MEDIUM";
  }

  if (
    token.liquidity >= 250_000 &&
    token.ageScore >= 80 &&
    change1h < 150
  ) {
    riskLevel = "LOW";
  }

  // ==========================================================
  // REASONS
  // ==========================================================

  const reasons: string[] = [];

  if (token.momentumScore >= 75) {
    reasons.push(
      "Strong short-term momentum"
    );
  }

  if (token.volumeScore >= 75) {
    reasons.push(
      "High trading volume"
    );
  }

  if (token.pressureScore >= 60) {
    reasons.push(
      "Buy pressure is dominant"
    );
  }

  if (token.accelerationScore >= 75) {
    reasons.push(
      "Volume acceleration detected"
    );
  }

  if (token.upsideScore >= 80) {
    reasons.push(
      "Low market cap offers high upside potential"
    );
  }

  if (token.ageScore >= 70) {
    reasons.push(
      "Token has passed the initial launch phase"
    );
  }

  if (reasons.length === 0) {
    reasons.push(
      "Multiple market factors aligned"
    );
  }

  // ==========================================================
  // CONFIDENCE
  // ==========================================================

  let confidence =
    Math.round(
      clamp(token.score)
    );

  // Slight penalty for very young tokens.
  if (token.ageScore < 50) {
    confidence -= 5;
  }

  // Slight penalty for extreme 1h momentum.
  if (change1h >= 700) {
    confidence -= 5;
  }

  confidence =
    Math.round(
      clamp(confidence)
    );

  // ==========================================================
  // FINAL SIGNAL
  // ==========================================================

  return {
    symbol:
      token.symbol,

    name:
      token.name,

    market:
      "MEME",

    timeframe:
      "5m",

    direction,

    address:
      token.address,

    pairAddress:
      token.pairAddress,

    price:
      entryPrice,

    entryPrice,

    stopLoss,

    takeProfit1:
      tp1,

    takeProfit2:
      tp2,

    takeProfit3:
      tp3,

    confidence,

    riskLevel,

    riskReward:
      Number(
        riskReward.toFixed(2)
      ),

    reason:
      reasons.join(" • "),

    technicalScore:
      token.momentumScore,

    momentumScore:
      token.momentumScore,

    volumeScore:
      token.volumeScore,

    whaleScore:
      50,

    openInterestScore:
      0,

    fundingScore:
      0,

    status:
      "ACTIVE",

    source:
      "DEXSCREENER",

    createdAt:
      new Date().toISOString(),
  };
}

// ============================================================
// MAIN
// ============================================================

Deno.serve(async () => {

  try {

    // --------------------------------------------------------
    // 1. PROFILES
    // --------------------------------------------------------

    const profiles =
      await getTrendingProfiles();

    const solanaProfiles =
      profiles.filter(
        (token: any) =>
          token?.chainId ===
          "solana"
      );

    // --------------------------------------------------------
    // 2. UNIQUE TOKEN ADDRESSES
    // --------------------------------------------------------

    const addresses =
      Array.from(
        new Set(
          solanaProfiles
            .map(
              (token: any) =>
                token?.tokenAddress
            )
            .filter(Boolean)
        )
      );

    // --------------------------------------------------------
    // 3. FETCH PAIRS
    // --------------------------------------------------------

    const allPairs: any[] = [];

    for (
      const address of addresses
    ) {

      try {

        const pairs =
          await getTokenPairs(
            address
          );

        for (
          const pair of pairs
        ) {

          if (
            pair?.chainId ===
            "solana"
          ) {

            allPairs.push(
              pair
            );
          }
        }

      } catch (error) {

        console.error(
          `PAIR ERROR ${address}:`,
          error
        );
      }
    }

    // --------------------------------------------------------
    // 4. UNIQUE PAIRS
    // --------------------------------------------------------

    const uniquePairs =
      Array.from(
        new Map(
          allPairs
            .filter(
              (pair) =>
                pair?.pairAddress
            )
            .map(
              (pair) => [
                pair.pairAddress,
                pair,
              ]
            )
        ).values()
      );

    // --------------------------------------------------------
    // 5. NORMALIZE
    // --------------------------------------------------------

    const normalized =
      uniquePairs.map(
        normalizePair
      );

    // --------------------------------------------------------
    // 6. GROUP BY TOKEN
    // --------------------------------------------------------

    const tokenGroups =
      new Map<
        string,
        any[]
      >();

    for (
      const token of normalized
    ) {

      if (
        !token.address
      ) {
        continue;
      }

      if (
        !tokenGroups.has(
          token.address
        )
      ) {
        tokenGroups.set(
          token.address,
          []
        );
      }

      tokenGroups
        .get(token.address)!
        .push(token);
    }

    // --------------------------------------------------------
    // 7. SELECT BEST PAIR
    // --------------------------------------------------------

    const bestTokens: any[] = [];

    for (
      const [
        address,
        pairs
      ] of tokenGroups
    ) {

      const sorted =
        pairs.sort(
          (a, b) =>
            b.liquidity -
            a.liquidity
        );

      const best =
        sorted[0];

      if (
        passesSafetyFilter(
          best
        )
      ) {

        bestTokens.push(
          best
        );
      }
    }

    // --------------------------------------------------------
    // 8. SCORE
    // --------------------------------------------------------

    const scored =
      bestTokens
        .map(
          (token) => {

            const ai =
              calculateAIScore(
                token
              );

            return {
              ...token,
              ...ai,
              qualifies:
                ai.score >=
                MIN_SCORE,
            };
          }
        )
        .sort(
          (a, b) =>
            b.score -
            a.score
        );

    // --------------------------------------------------------
    // 9. FINAL CANDIDATES
    // --------------------------------------------------------

    const candidates =
      scored.filter(
        (token) =>
          token.qualifies
      );

    // ============================================================
    // SAVE SIGNALS TO SUPABASE
    // ============================================================

    const SUPABASE_URL =
      Deno.env.get("SUPABASE_URL")!;

    const SUPABASE_SERVICE_ROLE_KEY =
      Deno.env.get(
        "SUPABASE_SERVICE_ROLE_KEY"
      )!;

    async function saveSignal(
      signal: any
    ) {
      const headers = {
        "Content-Type": "application/json",
        "apikey":
          SUPABASE_SERVICE_ROLE_KEY,
        "Authorization":
          `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      };

      // ----------------------------------------------------------
      // CHECK FOR EXISTING ACTIVE SIGNAL
      // ----------------------------------------------------------

      const checkUrl =
        `${SUPABASE_URL}/rest/v1/signals` +
        `?symbol=eq.${encodeURIComponent(signal.symbol)}` +
        `&market=eq.MEME` +
        `&status=eq.ACTIVE` +
        `&select=id`;

      const checkResponse =
        await fetch(
          checkUrl,
          {
            headers,
          }
        );

      if (!checkResponse.ok) {
        throw new Error(
          `Signal check failed: ${checkResponse.status}`
        );
      }

      const existing =
        await checkResponse.json();

      // Don't create duplicate active signals
      if (
        Array.isArray(existing) &&
        existing.length > 0
      ) {
        return {
          saved: false,
          reason:
            "ACTIVE_SIGNAL_EXISTS",
        };
      }

      // ----------------------------------------------------------
      // BUILD DATABASE PAYLOAD
      // ----------------------------------------------------------

      const payload = {
        symbol:
          signal.symbol,

        token_address:
          signal.address ?? null,

        pair_address:
          signal.pairAddress ?? null,

        market:
          "MEME",

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
          signal.whaleScore ?? 50,

        open_interest_score:
          signal.openInterestScore ?? 0,

        funding_score:
          signal.fundingScore ?? 0,

        status:
          "ACTIVE",

        expires_at:
          new Date(
            Date.now() +
            6 * 60 * 60 * 1000
          ).toISOString(),
      };

      // ----------------------------------------------------------
      // INSERT SIGNAL
      // ----------------------------------------------------------

      const response =
        await fetch(
          `${SUPABASE_URL}/rest/v1/signals`,
          {
            method: "POST",

            headers: {
              ...headers,
              "Prefer":
                "return=representation",
            },

            body:
              JSON.stringify(
                payload
              ),
          }
        );

      if (!response.ok) {
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
    // SAVE GENERATED SIGNALS
    // ============================================================

    const savedSignals: any[] = [];

    for (
      const candidate of candidates
    ) {
      const signal =
        generateMemeSignal(
          candidate
        );

      if (!signal) {
        continue;
      }

      try {
        const result =
          await saveSignal(
            signal
          );

        savedSignals.push({
          symbol:
            signal.symbol,

          saved:
            result.saved,

          reason:
            result.reason ?? null,
        });
      } catch (error) {
        savedSignals.push({
          symbol:
            signal.symbol,

          saved: false,

          error:
            String(error),
        });
      }
    }

    const signals =
      candidates
        .map(
          (token) =>
            generateMemeSignal(token)
        )
        .filter(Boolean);

    // --------------------------------------------------------
    // RESPONSE
    // --------------------------------------------------------

    return new Response(
      JSON.stringify({

        success: true,

        profilesScanned:
          solanaProfiles.length,

        tokenAddresses:
          addresses.length,

        pairsScanned:
          uniquePairs.length,

        tokensAfterSafety:
          bestTokens.length,

        candidateCount:
          candidates.length,

        analyzedAt:
          new Date()
            .toISOString(),

        results:
          scored.slice(0, 20),

        candidates:
          candidates,

        signals:
          signals,

        savedSignals:
          savedSignals,

      }),
      {
        headers: {
          "Content-Type":
            "application/json",
        },

        status: 200,
      }
    );

  } catch (error) {

    console.error(
      error
    );

    return new Response(
      JSON.stringify({
        success: false,
        error: String(error),
      }),
      {
        headers: {
          "Content-Type":
            "application/json",
        },

        status: 500,
      }
    );
  }
});