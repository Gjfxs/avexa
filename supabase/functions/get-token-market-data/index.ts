import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods":
    "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  // ============================================================
  // CORS
  // ============================================================

  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  try {
    // ============================================================
    // REQUEST
    // ============================================================

    const body = await req.json();

    const tokenAddress =
      body.token_address?.toString().trim();

    if (!tokenAddress) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "token_address is required.",
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // ============================================================
    // DEXSCREENER
    // ============================================================

    const url =
      `https://api.dexscreener.com/token-pairs/v1/solana/${tokenAddress}`;

    const response = await fetch(url);

    if (!response.ok) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            `DexScreener returned ${response.status}.`,
        }),
        {
          status: 502,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const pairs = await response.json();

    if (!Array.isArray(pairs) || pairs.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "No DexScreener pairs found.",
          token_address: tokenAddress,
        }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // ============================================================
    // SELECT BEST PAIR
    // ============================================================

    const validPairs = pairs.filter(
      (pair: any) =>
        pair &&
        pair.baseToken &&
        pair.liquidity,
    );

    if (validPairs.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "No valid trading pair found.",
          token_address: tokenAddress,
        }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    validPairs.sort(
      (a: any, b: any) =>
        Number(b.liquidity?.usd ?? 0) -
        Number(a.liquidity?.usd ?? 0),
    );

    const pair = validPairs[0];

    // ============================================================
    // MARKET DATA
    // ============================================================

    const marketData = {
      success: true,

      token_address: tokenAddress,

      symbol:
        pair.baseToken?.symbol ?? null,

      name:
        pair.baseToken?.name ?? null,

      price_usd:
        pair.priceUsd ?? null,

      market_cap:
        pair.marketCap ?? null,

      fdv:
        pair.fdv ?? null,

      volume_24h:
        pair.volume?.h24 ?? null,

      volume_6h:
        pair.volume?.h6 ?? null,

      volume_1h:
        pair.volume?.h1 ?? null,

      liquidity_usd:
        pair.liquidity?.usd ?? null,

      price_change_24h:
        pair.priceChange?.h24 ?? null,

      price_change_6h:
        pair.priceChange?.h6 ?? null,

      price_change_1h:
        pair.priceChange?.h1 ?? null,

      pair_address:
        pair.pairAddress ?? null,

      dex:
        pair.dexId ?? null,

      dex_url:
        pair.url ?? null,

      image_url:
        pair.info?.imageUrl ?? null,

      updated_at:
        new Date().toISOString(),
    };

    return new Response(
      JSON.stringify(marketData),
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
      "get-token-market-data error:",
      error,
    );

    return new Response(
      JSON.stringify({
        success: false,
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