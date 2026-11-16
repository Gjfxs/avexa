import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL =
  Deno.env.get("SUPABASE_URL")!;

const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const DEXSCREENER_PAIR_URL =
  "https://api.dexscreener.com/latest/dex/pairs";

const DEXSCREENER_TOKEN_PAIRS_URL =
  "https://api.dexscreener.com/token-pairs/v1/solana";

const headers = {
  "Content-Type": "application/json",
  "apikey": SUPABASE_SERVICE_ROLE_KEY,
  "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
};

async function fetchJson(url: string) {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(
      `API error ${response.status}: ${url}`
    );
  }

  return await response.json();
}

async function getActiveSignals() {
  const url =
    `${SUPABASE_URL}/rest/v1/signals` +
    `?status=eq.ACTIVE` +
    `&select=*` +
    `&order=created_at.asc`;

  const response =
    await fetch(url, { headers });

  if (!response.ok) {
    throw new Error(
      `Failed to fetch signals: ${response.status}`
    );
  }

  return await response.json();
}

/**
 * Get current price.
 *
 * Priority:
 * 1. pair_address - direct DexScreener pair lookup
 * 2. token_address - fallback token lookup
 */
async function getCurrentPrice(
  tokenAddress: string,
  pairAddress?: string | null
) {
  // =========================================================
  // 1. DIRECT PAIR LOOKUP
  // =========================================================

  if (pairAddress) {
    try {
      const data =
        await fetchJson(
          `${DEXSCREENER_PAIR_URL}/solana/${pairAddress}`
        );

      const pair =
        Array.isArray(data?.pairs)
          ? data.pairs[0] ?? null
          : null;

      const price =
        Number(pair?.priceUsd ?? 0);

      if (pair && price > 0) {
        return {
          price,
          pairAddress:
            pair?.pairAddress ??
            pairAddress,
          symbol:
            pair?.baseToken?.symbol ??
            null,
        };
      }
    } catch (error) {
      console.error(
        `PAIR LOOKUP ERROR ${pairAddress}:`,
        error
      );
    }
  }

  // =========================================================
  // 2. TOKEN LOOKUP FALLBACK
  // =========================================================

  if (!tokenAddress) {
    return null;
  }

  try {
    const pairs =
      await fetchJson(
        `${DEXSCREENER_TOKEN_PAIRS_URL}/${tokenAddress}`
      );

    if (!Array.isArray(pairs) ||
        pairs.length === 0) {
      return null;
    }

    let pair = null;

    // If pair_address exists but direct lookup failed,
    // try to find exactly the same pair in token results.
    if (pairAddress) {
      pair =
        pairs.find(
          (p: any) =>
            p?.pairAddress === pairAddress
        ) ?? null;
    }

    // Otherwise use the most liquid valid Solana pair.
    if (!pair) {
      pair =
        [...pairs]
          .filter(
            (p: any) =>
              p?.chainId === "solana" &&
              Number(p?.priceUsd ?? 0) > 0
          )
          .sort(
            (a: any, b: any) =>
              Number(b?.liquidity?.usd ?? 0) -
              Number(a?.liquidity?.usd ?? 0)
          )[0] ?? null;
    }

    if (!pair) {
      return null;
    }

    const price =
      Number(pair?.priceUsd ?? 0);

    if (price <= 0) {
      return null;
    }

    return {
      price,
      pairAddress:
        pair?.pairAddress ?? null,
      symbol:
        pair?.baseToken?.symbol ?? null,
    };
  } catch (error) {
    console.error(
      `TOKEN LOOKUP ERROR ${tokenAddress}:`,
      error
    );

    return null;
  }
}

async function updateSignal(
  id: string,
  payload: any
) {
  const response =
    await fetch(
      `${SUPABASE_URL}/rest/v1/signals?id=eq.${id}`,
      {
        method: "PATCH",
        headers: {
          ...headers,
          "Prefer": "return=representation",
        },
        body: JSON.stringify(payload),
      }
    );

  if (!response.ok) {
    const error =
      await response.text();

    throw new Error(
      `Signal update failed: ${error}`
    );
  }

  return await response.json();
}

async function sendPush(
  event:
    | "tp1_hit"
    | "tp2_hit"
    | "tp3_hit"
    | "stop_loss"
    | "pro_signal_expired",
  signal: any
) {
  const response =
    await fetch(
      `${SUPABASE_URL}/functions/v1/send-push`,
      {
        method: "POST",
        headers: {
          "Content-Type":
            "application/json",
          "apikey":
            SUPABASE_SERVICE_ROLE_KEY,
          "Authorization":
            `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
        body: JSON.stringify({
          event,

          signal: {
            id: signal.id,
            symbol: signal.symbol,
            direction: signal.direction,
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
              signal.market ?? "MEME",
            tier:
              signal.tier ?? "",
          },
        }),
      }
    );

  const result =
    await response.text();

  if (!response.ok) {
    throw new Error(
      `Push notification failed (${response.status}): ${result}`
    );
  }

  console.log(
    `PUSH SENT: ${event} ${signal.symbol}`
  );

  return result;
}

async function trackSignal(
  signal: any
) {
  const tokenAddress =
    signal.token_address;

  if (!tokenAddress) {
    return {
      symbol: signal.symbol,
      updated: false,
      reason: "NO_TOKEN_ADDRESS",
    };
  }

  const marketData =
    await getCurrentPrice(
      tokenAddress,
      signal.pair_address
    );

  if (!marketData) {
    return {
      symbol: signal.symbol,
      updated: false,
      reason: "NO_PRICE_DATA",
    };
  }

  const price =
    marketData.price;

  const entry =
    Number(signal.entry_price);

  const stopLoss =
    Number(signal.stop_loss);

  const tp1 =
    Number(signal.take_profit_1);

  const tp2 =
    Number(
      signal.take_profit_2 ?? 0
    );

  const tp3 =
    Number(
      signal.take_profit_3 ?? 0
    );

  const direction =
    String(
      signal.direction ?? "LONG"
    ).toUpperCase();

  const isShort =
    direction === "SHORT";

  const now =
    new Date().toISOString();

  // =========================================================
  // EXPIRATION
  // =========================================================

  if (
    signal.expires_at &&
    new Date(
      signal.expires_at
    ).getTime() <= Date.now()
  ) {
    await updateSignal(
      signal.id,
      {
        status: "EXPIRED",
        closed_at: now,
      }
    );

    // Send expiry notification only for PRO signals.
    // FREE signals do not receive expiry notifications.
    if (
      String(signal.tier ?? "").toUpperCase() === "PRO"
    ) {
      try {
        await sendPush(
          "pro_signal_expired",
          signal
        );
      } catch (error) {
        console.error(
          "PRO EXPIRY PUSH ERROR:",
          error
        );
      }
    }

    return {
      symbol: signal.symbol,
      updated: true,
      status: "EXPIRED",
      price,
    };
  }

  // =========================================================
  // STOP LOSS
  // =========================================================

  const stopLossHit =
    isShort
      ? price >= stopLoss
      : price <= stopLoss;

  if (stopLossHit) {
    await updateSignal(
      signal.id,
      {
        status: "STOPPED",
        closed_at: now,
      }
    );

    try {
      await sendPush(
        "stop_loss",
        signal
      );
    } catch (error) {
      console.error(
        "STOP LOSS PUSH ERROR:",
        error
      );
    }

    return {
      symbol: signal.symbol,
      updated: true,
      status: "STOPPED",
      price,
    };
  }

  // =========================================================
  // TAKE PROFITS
  // =========================================================

  const tp1Hit =
    isShort
      ? price <= tp1
      : price >= tp1;

  const tp2Hit =
    tp2 > 0 &&
    (
      isShort
        ? price <= tp2
        : price >= tp2
    );

  const tp3Hit =
    tp3 > 0 &&
    (
      isShort
        ? price <= tp3
        : price >= tp3
    );

  // =========================================================
  // TP3
  // =========================================================

  if (tp3Hit) {
    if (!signal.tp1_hit) {
      try {
        await sendPush(
          "tp1_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP1 PUSH ERROR:",
          error
        );
      }
    }

    if (!signal.tp2_hit) {
      try {
        await sendPush(
          "tp2_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP2 PUSH ERROR:",
          error
        );
      }
    }

    if (!signal.tp3_hit) {
      try {
        await sendPush(
          "tp3_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP3 PUSH ERROR:",
          error
        );
      }
    }

    await updateSignal(
      signal.id,
      {
        tp1_hit: true,
        tp2_hit: true,
        tp3_hit: true,

        tp1_hit_at:
          signal.tp1_hit_at ?? now,

        tp2_hit_at:
          signal.tp2_hit_at ?? now,

        tp3_hit_at:
          signal.tp3_hit_at ?? now,

        status: "TP3_HIT",
        closed_at: now,
      }
    );

    return {
      symbol: signal.symbol,
      updated: true,
      status: "TP3_HIT",
      price,
    };
  }

  // =========================================================
  // TP2
  // =========================================================

  if (tp2Hit) {
    if (!signal.tp1_hit) {
      try {
        await sendPush(
          "tp1_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP1 PUSH ERROR:",
          error
        );
      }
    }

    if (!signal.tp2_hit) {
      try {
        await sendPush(
          "tp2_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP2 PUSH ERROR:",
          error
        );
      }
    }

    await updateSignal(
      signal.id,
      {
        tp1_hit: true,
        tp2_hit: true,

        tp1_hit_at:
          signal.tp1_hit_at ?? now,

        tp2_hit_at:
          signal.tp2_hit_at ?? now,
      }
    );

    return {
      symbol: signal.symbol,
      updated: true,
      status: "TP2_HIT",
      price,
    };
  }

  // =========================================================
  // TP1
  // =========================================================

  if (tp1Hit) {
    if (!signal.tp1_hit) {
      try {
        await sendPush(
          "tp1_hit",
          signal
        );
      } catch (error) {
        console.error(
          "TP1 PUSH ERROR:",
          error
        );
      }

      await updateSignal(
        signal.id,
        {
          tp1_hit: true,
          tp1_hit_at:
            signal.tp1_hit_at ?? now,
        }
      );

      return {
        symbol: signal.symbol,
        updated: true,
        status: "TP1_HIT",
        price,
      };
    }

    return {
      symbol: signal.symbol,
      updated: false,
      status: "ACTIVE",
      price,
      entry,
      stopLoss,
      tp1,
      tp2,
      tp3,
    };
  }

  // =========================================================
  // STILL ACTIVE
  // =========================================================

  return {
    symbol: signal.symbol,
    updated: false,
    status: "ACTIVE",
    price,
    entry,
    stopLoss,
    tp1,
    tp2,
    tp3,
  };
}

Deno.serve(async () => {
  try {
    const signals =
      await getActiveSignals();

    const results = [];

    for (const signal of signals) {
      try {
        const result =
          await trackSignal(signal);

        results.push(result);
      } catch (error) {
        results.push({
          symbol: signal.symbol,
          updated: false,
          error: String(error),
        });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        signalsScanned:
          signals.length,
        results,
        analyzedAt:
          new Date().toISOString(),
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
    console.error(error);

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