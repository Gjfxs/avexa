import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const INTERNAL_PUSH_SECRET =
  Deno.env.get("INTERNAL_PUSH_SECRET")!;

const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
);

const DEX_BASE = "https://api.dexscreener.com";

const MARKET = "MEME";
const TIER = "PRO";

const MAX_ACTIVE_PRO_SIGNALS = 5;
const SIGNAL_LIFETIME_HOURS = 3;

const MIN_MARKET_CAP = 5_000;
const MAX_MARKET_CAP = 1_000_000;
const MIN_LIQUIDITY = 5_000;
const MIN_VOLUME_24H = 20_000;

const MIN_SCORE = 55;

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

function num(value: any): number {
  const parsed = Number(value);

  return Number.isFinite(parsed)
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

function priceChange(
  pair: JsonMap,
  timeframe: string,
): number {
  return num(
    pair?.priceChange?.[timeframe],
  );
}

function volume(
  pair: JsonMap,
): number {
  return num(
    pair?.volume?.h24,
  );
}

function liquidity(
  pair: JsonMap,
): number {
  return num(
    pair?.liquidity?.usd,
  );
}

// ===============================================================
// SCORE
// ===============================================================

function calculateScore(
  pair: JsonMap,
): number {
  const h1 = priceChange(pair, "h1");
  const h6 = priceChange(pair, "h6");
  const h24 = priceChange(pair, "h24");

  const volume24 = volume(pair);
  const liquidityUsd = liquidity(pair);

  const boosts =
    num(pair?.boosts?.active);

  const txns =
    pair?.txns?.h1 ?? {};

  const buys =
    num(txns.buys);

  const sells =
    num(txns.sells);

  let score = 0;

  // 1h momentum
  if (h1 >= 20) {
    score += 20;
  } else if (h1 >= 10) {
    score += 17;
  } else if (h1 >= 5) {
    score += 13;
  } else if (h1 > 0) {
    score += 8;
  }

  // 6h momentum
  if (h6 >= 40) {
    score += 15;
  } else if (h6 >= 20) {
    score += 12;
  } else if (h6 >= 8) {
    score += 9;
  } else if (h6 > 0) {
    score += 5;
  }

  // 24h momentum
  if (h24 >= 75) {
    score += 10;
  } else if (h24 >= 30) {
    score += 8;
  } else if (h24 >= 10) {
    score += 5;
  }

  // Volume / liquidity
  const volumeLiquidityRatio =
    liquidityUsd > 0
      ? volume24 / liquidityUsd
      : 0;

  if (volumeLiquidityRatio >= 10) {
    score += 15;
  } else if (volumeLiquidityRatio >= 5) {
    score += 12;
  } else if (volumeLiquidityRatio >= 2) {
    score += 9;
  } else if (volumeLiquidityRatio >= 1) {
    score += 5;
  }

  // Liquidity
  if (liquidityUsd >= 50_000) {
    score += 10;
  } else if (liquidityUsd >= 25_000) {
    score += 8;
  } else if (liquidityUsd >= 10_000) {
    score += 6;
  } else {
    score += 3;
  }

  // Boost activity
  if (boosts >= 5) {
    score += 5;
  } else if (boosts >= 1) {
    score += 3;
  }

  // Buy pressure
  const total =
    buys + sells;

  if (total > 0) {
    const buyRatio =
      buys / total;

    if (buyRatio >= 0.65) {
      score += 15;
    } else if (buyRatio >= 0.55) {
      score += 10;
    } else if (buyRatio >= 0.50) {
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

  if (confidence >= 70) {
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
    priceChange(pair, "h1");

  const h6 =
    priceChange(pair, "h6");

  const h24 =
    priceChange(pair, "h24");

  const volume24 =
    volume(pair);

  const liquidityUsd =
    liquidity(pair);

  return [
    `${symbol} selected from Solana memecoin market data on DEX Screener.`,
    `PRO score ${score}/100.`,
    `1h: ${h1.toFixed(2)}%.`,
    `6h: ${h6.toFixed(2)}%.`,
    `24h: ${h24.toFixed(2)}%.`,
    `24h volume: $${Math.round(volume24).toLocaleString()}.`,
    `Liquidity: $${Math.round(liquidityUsd).toLocaleString()}.`,
    "Educational market example — not financial advice.",
  ].join(" ");
}

// ===============================================================
// ACTIVE PRO SIGNAL LIMIT
// ===============================================================

async function canCreateSignal(): Promise<{
  allowed: boolean;
  reason?: string;
}> {
  const now =
    new Date().toISOString();

  const { count, error } =
    await supabase
      .from("signals")
      .select("id", {
        count: "exact",
        head: true,
      })
      .eq("market", MARKET)
      .eq("tier", TIER)
      .eq("status", "ACTIVE")
      .or(
        `expires_at.is.null,expires_at.gt.${now}`,
      );

  if (error) {
    throw error;
  }

  const activeCount =
    count ?? 0;

  console.log(
    `PRO MEME ENGINE: active PRO signals = ${activeCount}/${MAX_ACTIVE_PRO_SIGNALS}`,
  );

  if (
    activeCount >=
    MAX_ACTIVE_PRO_SIGNALS
  ) {
    return {
      allowed: false,
      reason:
        "Maximum of 5 active PRO signals reached.",
    };
  }

  return {
    allowed: true,
  };
}

// ===============================================================
// CANDIDATES
// ===============================================================

async function getCandidates(): Promise<
  JsonMap[]
> {
  const sources = [
    `${DEX_BASE}/token-boosts/latest/v1`,
    `${DEX_BASE}/token-boosts/top/v1`,
  ];

  const tokens =
    new Map<string, JsonMap>();

  for (const url of sources) {
    try {
      const data =
        await fetchJson(url);

      const list =
        Array.isArray(data)
          ? data
          : [];

      for (const item of list) {
        if (
          item?.chainId !==
          "solana"
        ) {
          continue;
        }

        const address =
          item?.tokenAddress;

        if (!address) {
          continue;
        }

        tokens.set(
          address,
          item,
        );
      }
    } catch (error) {
      console.error(
        "Candidate source failed:",
        error,
      );
    }
  }

  // Give the PRO engine a larger candidate pool.
  const addresses =
    Array.from(
      tokens.keys(),
    ).slice(0, 100);

  if (addresses.length === 0) {
    return [];
  }

  const tokenUrl =
    `${DEX_BASE}/tokens/v1/solana/` +
    addresses.join(",");

  const pairs =
    await fetchJson(tokenUrl);

  if (!Array.isArray(pairs)) {
    return [];
  }

  return pairs.filter(
    (pair: JsonMap) =>
      pair?.chainId ===
        "solana" &&
      pair?.baseToken?.address &&
      pair?.priceUsd,
  );
}

// ===============================================================
// QUALIFYING CANDIDATES
// ===============================================================

function selectCandidates(
  pairs: JsonMap[],
): JsonMap[] {
  return pairs
    .map((pair) => {
      const marketCap =
        num(pair?.marketCap) ||
        num(pair?.fdv);

      const liquidityUsd =
        liquidity(pair);

      const volume24 =
        volume(pair);

      if (
        marketCap <
          MIN_MARKET_CAP ||
        marketCap >
          MAX_MARKET_CAP
      ) {
        return null;
      }

      if (
        liquidityUsd <
        MIN_LIQUIDITY
      ) {
        return null;
      }

      if (
        volume24 <
        MIN_VOLUME_24H
      ) {
        return null;
      }

      const score =
        calculateScore(pair);

      if (
        score <
        MIN_SCORE
      ) {
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
      } =>
        item !== null,
    )
    .sort(
      (a, b) =>
        b.score -
        a.score,
    )
    .map((item) => ({
      ...item.pair,
      __score: item.score,
    }));
}

// ===============================================================
// RECENT TOKEN CHECK
// ===============================================================

async function hasRecentTokenSignal(
  tokenAddress: string,
): Promise<boolean> {
  const since =
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
      .select("id")
      .eq("market", MARKET)
      .eq(
        "token_address",
        tokenAddress,
      )
      .gte(
        "created_at",
        since,
      )
      .limit(1);

  if (error) {
    throw error;
  }

  return (
    (data?.length ?? 0) >
    0
  );
}

// ===============================================================
// SAVE SIGNAL
// ===============================================================

async function saveSignal(
  pair: JsonMap,
): Promise<JsonMap> {
  const entry =
    num(pair?.priceUsd);

  if (entry <= 0) {
    throw new Error(
      "Invalid entry price.",
    );
  }

  const stopLoss =
    entry * 0.90;

  const tp1 =
    entry * 1.10;

  const tp2 =
    entry * 1.18;

  const tp3 =
    entry * 1.30;

  const confidence =
    clamp(
      num(pair.__score),
      0,
      100,
    );

  const expiresAt =
    new Date(
      Date.now() +
        SIGNAL_LIFETIME_HOURS *
          60 *
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
      confidence,

    volume_score:
      confidence,

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
// PUSH
// ===============================================================

async function sendNewProPush(
  signal: JsonMap,
) {
  const response =
    await fetch(
      `${SUPABASE_URL}/functions/v1/send-push`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "apikey": SUPABASE_SERVICE_ROLE_KEY,
          "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          "x-internal-secret": INTERNAL_PUSH_SECRET,
        },
        body: JSON.stringify({
          event:
            "new_pro_signal",
          signal: {
            id: signal.id,
            symbol:
              signal.symbol,
            direction:
              signal.direction,
            entry_price:
              signal.entry_price,
            take_profit_1:
              signal.take_profit_1,
            take_profit_2:
              signal.take_profit_2,
            take_profit_3:
              signal.take_profit_3,
            stop_loss:
              signal.stop_loss,
            market:
              signal.market ??
              "MEME",
            tier:
              signal.tier ??
              "PRO",
          },
        }),
      },
    );

  const result =
    await response.text();

  if (!response.ok) {
    throw new Error(
      `PRO push failed (${response.status}): ${result}`,
    );
  }

  console.log(
    `PRO PUSH SENT: ${signal.symbol}`,
  );

  return result;
}

// ===============================================================
// MAIN
// ===============================================================

Deno.serve(async (req) => {
  if (
    req.method ===
    "OPTIONS"
  ) {
    return new Response(
      "ok",
      {
        headers:
          corsHeaders,
      },
    );
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  const authHeader = req.headers.get("Authorization");
  const token = authHeader?.replace(/^Bearer\s+/i, "");

  if (!token) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      {
        status: 401,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  const { data: { user }, error: authError } =
    await supabase.auth.getUser(token);

  if (authError || !user) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      {
        status: 401,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("plan")
    .eq("id", user.id)
    .maybeSingle();

  if (profileError) {
    console.error("PRO profile check failed:", profileError);
    return new Response(
      JSON.stringify({ error: "Could not verify subscription" }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  if (String(profile?.plan ?? "").toUpperCase() !== "PRO") {
    return new Response(
      JSON.stringify({ error: "PRO subscription required" }),
      {
        status: 403,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
  try {
    console.log(
      "PRO MEME ENGINE: started",
    );

    // -----------------------------------------------------------
    // 1. Check active signal limit
    // -----------------------------------------------------------

    const permission =
      await canCreateSignal();

    if (!permission.allowed) {
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
    // 2. Get market candidates
    // -----------------------------------------------------------

    const pairs =
      await getCandidates();

    console.log(
      `PRO MEME ENGINE: ${pairs.length} raw candidates`,
    );

    // -----------------------------------------------------------
    // 3. Filter and score
    // -----------------------------------------------------------

    const candidates =
      selectCandidates(
        pairs,
      );

    console.log(
      `PRO MEME ENGINE: ${candidates.length} qualifying candidates`,
    );

    if (
      candidates.length === 0
    ) {
      console.log(
        "PRO MEME ENGINE: no qualifying setup",
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
    // 4. Find first unused token
    // -----------------------------------------------------------

    let candidate:
      JsonMap | null = null;

    for (
      const item of candidates
    ) {
      const tokenAddress =
        item?.baseToken?.address;

      if (!tokenAddress) {
        continue;
      }

      const alreadyUsed =
        await hasRecentTokenSignal(
          tokenAddress,
        );

      if (alreadyUsed) {
        console.log(
          "PRO MEME ENGINE: skipping recently used token",
          tokenAddress,
        );

        continue;
      }

      candidate = item;

      break;
    }

    if (!candidate) {
      console.log(
        "PRO MEME ENGINE: all qualifying candidates were used recently",
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
    // 5. Final token validation
    // -----------------------------------------------------------

    const tokenAddress =
      candidate?.baseToken?.address;

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
        "PRO MEME ENGINE: token already used recently",
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
    // 6. Save
    // -----------------------------------------------------------

    const signal =
      await saveSignal(
        candidate,
      );

    console.log(
      `PRO MEME ENGINE: signal created ${signal.id} ${signal.symbol}`,
    );

    // -----------------------------------------------------------
    // 7. Push notification
    // -----------------------------------------------------------

    try {
      await sendNewProPush(
        signal,
      );
    } catch (error) {
      console.error(
        "PRO PUSH ERROR:",
        error,
      );
    }

    // -----------------------------------------------------------
    // 8. Response
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
      "PRO MEME ENGINE ERROR:",
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