import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
);

const DEX_BASE = "https://api.dexscreener.com";

const MARKET = "MEME";
const TIER = "FREE";

const MAX_SIGNALS_PER_24H = 3;
const COOLDOWN_HOURS = 3;
const SIGNAL_LIFETIME_MINUTES = 10;

// FREE filters — relaxed to find more valid setups.
const MIN_MARKET_CAP = 5_000;
const MAX_MARKET_CAP = 500_000;
const MIN_LIQUIDITY = 5_000;
const MIN_VOLUME_24H = 20_000;

const MIN_SCORE = 60;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type JsonMap = Record<string, any>;

// ===============================================================
// HELPERS
// ===============================================================

async function fetchJson(
  url: string,
): Promise<any> {
  const response = await fetch(url, {
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(
      `DEX Screener ${response.status}: ${await response.text()}`,
    );
  }

  return await response.json();
}

function num(
  value: any,
): number {
  const parsed =
    Number(value);

  return Number.isFinite(
    parsed,
  )
    ? parsed
    : 0;
}

function clamp(
  value: number,
  min: number,
  max: number,
): number {
  return Math.max(
    min,
    Math.min(max, value),
  );
}

function getNested(
  object: JsonMap,
  parent: string,
  child: string,
): number {
  return num(
    object?.[parent]?.[child],
  );
}

// ===============================================================
// SCORE
// ===============================================================

function calculateScore(
  pair: JsonMap,
): number {
  const h1Change =
    getNested(
      pair,
      "priceChange",
      "h1",
    );

  const h6Change =
    getNested(
      pair,
      "priceChange",
      "h6",
    );

  const h24Change =
    getNested(
      pair,
      "priceChange",
      "h24",
    );

  const volume24 =
    getNested(
      pair,
      "volume",
      "h24",
    );

  const liquidity =
    num(
      pair?.liquidity?.usd,
    );

  const boosts =
    num(
      pair?.boosts?.active,
    );

  let score = 0;

  // Short-term momentum
  if (h1Change >= 15) {
    score += 20;
  } else if (h1Change >= 8) {
    score += 16;
  } else if (h1Change >= 3) {
    score += 12;
  } else if (h1Change > 0) {
    score += 8;
  }

  // Medium-term momentum
  if (h6Change >= 30) {
    score += 15;
  } else if (h6Change >= 15) {
    score += 12;
  } else if (h6Change >= 5) {
    score += 9;
  } else if (h6Change > 0) {
    score += 5;
  }

  // 24h momentum
  if (h24Change >= 50) {
    score += 10;
  } else if (h24Change >= 20) {
    score += 8;
  } else if (h24Change >= 5) {
    score += 5;
  }

  // Volume / liquidity quality
  const volumeLiquidityRatio =
    liquidity > 0
      ? volume24 / liquidity
      : 0;

  if (
    volumeLiquidityRatio >=
    10
  ) {
    score += 15;
  } else if (
    volumeLiquidityRatio >=
    5
  ) {
    score += 12;
  } else if (
    volumeLiquidityRatio >=
    2
  ) {
    score += 8;
  } else if (
    volumeLiquidityRatio >=
    1
  ) {
    score += 5;
  }

  // Liquidity
  if (liquidity >= 50_000) {
    score += 10;
  } else if (
    liquidity >= 25_000
  ) {
    score += 8;
  } else if (
    liquidity >= 15_000
  ) {
    score += 6;
  } else {
    score += 3;
  }

  // Boost activity
  if (boosts >= 5) {
    score += 5;
  } else if (
    boosts >= 1
  ) {
    score += 3;
  }

  // Buy pressure
  const h1Txns =
    pair?.txns?.h1 ?? {};

  const buys =
    num(h1Txns.buys);

  const sells =
    num(h1Txns.sells);

  const total =
    buys + sells;

  if (total > 0) {
    const buyRatio =
      buys / total;

    if (buyRatio >= 0.65) {
      score += 15;
    } else if (
      buyRatio >= 0.55
    ) {
      score += 10;
    } else if (
      buyRatio >= 0.50
    ) {
      score += 5;
    }
  }

  return clamp(
    Math.round(score),
    0,
    100,
  );
}

function riskLevel(
  confidence: number,
): string {
  if (confidence >= 85) {
    return "LOW";
  }

  if (confidence >= 75) {
    return "MEDIUM";
  }

  return "HIGH";
}

function buildReason(
  pair: JsonMap,
  score: number,
): string {
  const symbol =
    pair?.baseToken?.symbol ??
    "TOKEN";

  const h1 =
    getNested(
      pair,
      "priceChange",
      "h1",
    );

  const h6 =
    getNested(
      pair,
      "priceChange",
      "h6",
    );

  const volume =
    getNested(
      pair,
      "volume",
      "h24",
    );

  const liquidity =
    num(
      pair?.liquidity?.usd,
    );

  return [
    `${symbol} selected from Solana memecoin liquidity and momentum data on DEX Screener.`,
    `Score ${score}/100.`,
    `1h price change: ${h1.toFixed(2)}%.`,
    `6h price change: ${h6.toFixed(2)}%.`,
    `24h volume: $${Math.round(volume).toLocaleString()}.`,
    `Liquidity: $${Math.round(liquidity).toLocaleString()}.`,
    "Educational market example — not financial advice.",
  ].join(" ");
}

// ===============================================================
// RECENT FREE SIGNALS
// ===============================================================

async function getRecentSignals() {
  const since24h =
    new Date(
      Date.now() -
        24 *
          60 *
          60 *
          1000,
    ).toISOString();

  const { data, error } =
    await supabase
      .from("signals")
      .select(
        "id, created_at, token_address, status, expires_at",
      )
      .eq("market", MARKET)
      .eq("tier", TIER)
      .gte(
        "created_at",
        since24h,
      )
      .order(
        "created_at",
        {
          ascending: false,
        },
      );

  if (error) {
    throw error;
  }

  return data ?? [];
}

// ===============================================================
// FREE LIMIT / COOLDOWN
// ===============================================================

async function canCreateSignal(): Promise<{
  allowed: boolean;
  reason?: string;
}> {
  const signals =
    await getRecentSignals();

  if (
    signals.length >=
    MAX_SIGNALS_PER_24H
  ) {
    return {
      allowed: false,
      reason:
        "FREE daily limit reached.",
    };
  }

  const latest =
    signals[0];

  if (latest?.created_at) {
    const latestTime =
      new Date(
        latest.created_at,
      ).getTime();

    const cooldownMs =
      COOLDOWN_HOURS *
      60 *
      60 *
      1000;

    if (
      Date.now() -
        latestTime <
        cooldownMs
    ) {
      return {
        allowed: false,
        reason:
          "FREE cooldown is still active.",
      };
    }
  }

  return {
    allowed: true,
  };
}

// ===============================================================
// CANDIDATES
// ===============================================================


async function getCandidates(): Promise<JsonMap[]> {
  const sources = [
    `${DEX_BASE}/token-boosts/latest/v1`,
    `${DEX_BASE}/token-boosts/top/v1`,
    `${DEX_BASE}/token-profiles/latest/v1`,
  ];

  const addresses = new Set<string>();

  for (const url of sources) {
    try {
      const data = await fetchJson(url);
      const list = Array.isArray(data) ? data : [];

      for (const item of list) {
        if (item?.chainId !== "solana") continue;

        const address = item?.tokenAddress;

        if (
          typeof address === "string" &&
          address.length > 0
        ) {
          addresses.add(address);
        }
      }
    } catch (error) {
      console.error(
        "FREE candidate source failed:",
        url,
        error,
      );
    }
  }

  const allPairs: JsonMap[] = [];
  const addressList = Array.from(addresses);

  // DexScreener's batch token endpoint accepts up to 30
  // addresses per request.
  for (let i = 0; i < addressList.length; i += 30) {
    const batch = addressList.slice(i, i + 30);

    try {
      const url =
        `${DEX_BASE}/tokens/v1/solana/` +
        batch.join(",");

      const data = await fetchJson(url);

      if (Array.isArray(data)) {
        allPairs.push(...data);
      }
    } catch (error) {
      console.error(
        "FREE token batch failed:",
        i,
        error,
      );
    }
  }

  // Keep only valid Solana pairs and select the most liquid
  // pair for each token to avoid duplicate candidates.
  const bestPairByToken = new Map<string, JsonMap>();

  for (const pair of allPairs) {
    if (
      pair?.chainId !== "solana" ||
      !pair?.baseToken?.address ||
      !num(pair?.priceUsd)
    ) {
      continue;
    }

    const address = pair.baseToken.address;
    const previous = bestPairByToken.get(address);

    if (
      !previous ||
      num(pair?.liquidity?.usd) >
        num(previous?.liquidity?.usd)
    ) {
      bestPairByToken.set(address, pair);
    }
  }

  const result = Array.from(bestPairByToken.values());

  console.log(
    "FREE CANDIDATE DISCOVERY:",
    JSON.stringify({
      sourceAddresses: addressList.length,
      fetchedPairs: allPairs.length,
      uniqueSolanaTokens: result.length,
    }),
  );

  return result;
}

// ===============================================================
// ALL QUALIFYING CANDIDATES
// ===============================================================


function selectCandidates(
  pairs: JsonMap[],
): JsonMap[] {
  const rejected = {
    marketCap: 0,
    liquidity: 0,
    volume: 0,
    score: 0,
  };

  const diagnostics: JsonMap[] = [];

  const candidates = pairs
    .map((pair) => {
      const marketCap =
        num(pair.marketCap) ||
        num(pair.fdv);

      const liquidity =
        num(pair?.liquidity?.usd);

      const volume24 =
        getNested(pair, "volume", "h24");

      const score = calculateScore(pair);

      const stats = {
        symbol: pair?.baseToken?.symbol ?? "UNKNOWN",
        marketCap: Math.round(marketCap),
        liquidity: Math.round(liquidity),
        volume24: Math.round(volume24),
        score,
      };

      diagnostics.push(stats);

      if (
        marketCap < MIN_MARKET_CAP ||
        marketCap > MAX_MARKET_CAP
      ) {
        rejected.marketCap++;
        return null;
      }

      if (liquidity < MIN_LIQUIDITY) {
        rejected.liquidity++;
        return null;
      }

      if (volume24 < MIN_VOLUME_24H) {
        rejected.volume++;
        return null;
      }

      if (score < MIN_SCORE) {
        rejected.score++;
        return null;
      }

      return {
        pair,
        score,
      };
    })
    .filter(
      (
        item,
      ): item is {
        pair: JsonMap;
        score: number;
      } => item !== null,
    )
    .sort((a, b) => b.score - a.score)
    .map((item) => ({
      ...item.pair,
      __score: item.score,
    }));

  console.log(
    "FREE FILTER DIAGNOSTICS:",
    JSON.stringify({
      total: pairs.length,
      qualifying: candidates.length,
      rejected,
    }),
  );

  console.log(
    "FREE TOP CANDIDATES:",
    JSON.stringify(
      diagnostics
        .sort((a, b) => b.score - a.score)
        .slice(0, 10),
    ),
  );

  return candidates;
}

// ===============================================================
// RECENT TOKEN CHECK
// ===============================================================


async function hasRecentTokenSignal(
  tokenAddress: string,
): Promise<boolean> {
  const since = new Date(
    Date.now() - 24 * 60 * 60 * 1000,
  ).toISOString();

  const { data, error } = await supabase
    .from("signals")
    .select("id")
    .eq("market", MARKET)
    .eq("tier", TIER)
    .eq("token_address", tokenAddress)
    .gte("created_at", since)
    .limit(1);

  if (error) {
    throw error;
  }

  return (data?.length ?? 0) > 0;
}

// ===============================================================
// SAVE SIGNAL
// ===============================================================

async function saveSignal(
  pair: JsonMap,
): Promise<JsonMap> {
  const entry =
    num(pair.priceUsd);

  if (entry <= 0) {
    throw new Error(
      "Invalid entry price.",
    );
  }

  const stopLoss =
    entry * 0.92;

  const tp1 =
    entry * 1.12;

  const tp2 =
    entry * 1.20;

  const tp3 =
    entry * 1.35;

  const confidence =
    clamp(
      num(pair.__score),
      0,
      100,
    );

  const expiresAt =
    new Date(
      Date.now() +
        SIGNAL_LIFETIME_MINUTES *
          60 *
          1000,
    ).toISOString();

  const risk =
    entry - stopLoss;

  const reward =
    tp1 - entry;

  const riskReward =
    risk > 0
      ? reward / risk
      : null;

  const payload = {
    symbol:
      pair?.baseToken?.symbol ??
      "UNKNOWN",

    market: MARKET,

    tier: TIER,

    timeframe: "1h",

    direction: "LONG",

    entry_price: entry,

    stop_loss: stopLoss,

    take_profit_1: tp1,

    take_profit_2: tp2,

    take_profit_3: tp3,

    confidence,

    risk_level:
      riskLevel(confidence),

    risk_reward:
      riskReward,

    reason:
      buildReason(
        pair,
        confidence,
      ),

    technical_score:
      confidence,

    momentum_score:
      Math.round(
        confidence * 0.9,
      ),

    volume_score:
      Math.round(
        confidence * 0.85,
      ),

    whale_score: null,

    open_interest_score:
      null,

    funding_score:
      null,

    status: "ACTIVE",

    expires_at:
      expiresAt,

    token_address:
      pair?.baseToken?.address,

    pair_address:
      pair?.pairAddress ??
      null,

    image_url:
      pair?.info?.imageUrl ??
      null,

    tp1_hit: false,
    tp2_hit: false,
    tp3_hit: false,
  };

  const { data, error } =
    await supabase
      .from("signals")
      .insert(payload)
      .select()
      .single();

  if (error) {
    throw error;
  }

  return data;
}

// ===============================================================
// MAIN
// ===============================================================


Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  // Only POST requests are allowed.
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        success: false,
        error: "Method not allowed.",
      }),
      {
        status: 405,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  // Require a valid authenticated Supabase user.
  const authorization = req.headers.get("Authorization");

  if (!authorization?.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "Authentication required.",
      }),
      {
        status: 401,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  const token = authorization.substring(7);

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser(token);

  if (authError || !user) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "Invalid or expired authentication token.",
      }),
      {
        status: 401,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  try {
    console.log(
      "FREE MEME ENGINE: started",
    );

    console.log(
      "FREE MEME ENGINE: started",
    );

    // -----------------------------------------------------------
    // 1. Check FREE limits
    // -----------------------------------------------------------

    const permission =
      await canCreateSignal();

    if (
      !permission.allowed
    ) {
      console.log(
        permission.reason,
      );

      return new Response(
        JSON.stringify({
          success: false,
          created: false,
          reason:
            permission.reason,
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // -----------------------------------------------------------
    // 2. Get market data
    // -----------------------------------------------------------

    const pairs =
      await getCandidates();

    console.log(
      `FREE MEME ENGINE: ${pairs.length} raw candidates`,
    );

    // -----------------------------------------------------------
    // 3. Get ALL qualifying candidates
    // -----------------------------------------------------------

    const candidates =
      selectCandidates(
        pairs,
      );

    console.log(
      `FREE MEME ENGINE: ${candidates.length} qualifying candidates`,
    );

    if (
      candidates.length === 0
    ) {
      console.log(
        "FREE MEME ENGINE: no qualifying setup",
      );

      return new Response(
        JSON.stringify({
          success: true,
          created: false,
          reason:
            "No qualifying Solana memecoin setup.",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // -----------------------------------------------------------
    // 4. Try candidates one by one
    // -----------------------------------------------------------

    let candidate:
      JsonMap | null = null;

    for (
      const item of candidates
    ) {
      const tokenAddress =
        item
          ?.baseToken
          ?.address;

      if (!tokenAddress) {
        continue;
      }

      const alreadyUsed =
        await hasRecentTokenSignal(
          tokenAddress,
        );

      if (alreadyUsed) {
        console.log(
          "FREE MEME ENGINE: skipping recently used token",
          tokenAddress,
        );

        continue;
      }

      candidate = item;

      break;
    }

    // -----------------------------------------------------------
    // 5. No unused candidate
    // -----------------------------------------------------------

    if (!candidate) {
      console.log(
        "FREE MEME ENGINE: all qualifying candidates were used recently",
      );

      return new Response(
        JSON.stringify({
          success: true,
          created: false,
          reason:
            "All qualifying candidates were already used within 24h.",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // -----------------------------------------------------------
    // 6. Final token validation
    // -----------------------------------------------------------

    const tokenAddress =
      candidate
        ?.baseToken
        ?.address;

    if (!tokenAddress) {
      throw new Error(
        "Candidate has no token address.",
      );
    }

    const alreadyUsed =
      await hasRecentTokenSignal(
        tokenAddress,
      );

    if (alreadyUsed) {
      console.log(
        "FREE MEME ENGINE: token already used recently",
        tokenAddress,
      );

      return new Response(
        JSON.stringify({
          success: true,
          created: false,
          reason:
            "Candidate already used within 24h.",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // -----------------------------------------------------------
    // 7. Save signal
    // -----------------------------------------------------------

    const signal =
      await saveSignal(
        candidate,
      );

    console.log(
      `FREE MEME ENGINE: signal created ${signal.id} ${signal.symbol}`,
    );

    // -----------------------------------------------------------
    // 8. Return
    // -----------------------------------------------------------

    return new Response(
      JSON.stringify({
        success: true,
        created: true,
        signal,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type":
            "application/json",
        },
      },
    );
  } catch (error) {
    console.error(
      "FREE MEME ENGINE ERROR:",
      error,
    );

    return new Response(
      JSON.stringify({
        success: false,
        created: false,
        error:
          error instanceof Error
            ? error.message
            : String(error),
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type":
            "application/json",
        },
      },
    );
  }
});