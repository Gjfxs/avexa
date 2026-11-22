import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const supabaseUrl =
  Deno.env.get("SUPABASE_URL") ?? "";

const secretKeysRaw =
  Deno.env.get("SUPABASE_SECRET_KEYS");

const serviceRoleKey = secretKeysRaw
  ? JSON.parse(secretKeysRaw)["default"]
  : Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!serviceRoleKey) {
  throw new Error("Supabase service role key is missing.");
}

const supabaseAdmin = createClient(
  supabaseUrl,
  serviceRoleKey,
);

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
    // ==========================================================
    // READ REQUEST
    // ==========================================================

    const body = await req.json();

    const signalId =
      body.signal_id?.toString().trim();

    const tokenAddress =
      body.token_address?.toString().trim();

    if (!signalId && !tokenAddress) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "Provide signal_id or token_address.",
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

    // ==========================================================
    // GET TOKEN ADDRESS
    // ==========================================================

    let address = tokenAddress;

    if (!address && signalId) {
      const { data: signal, error } =
        await supabaseAdmin
          .from("signals")
          .select(
            "id, symbol, token_address, image_url",
          )
          .eq("id", signalId)
          .maybeSingle();

      if (error) {
        throw new Error(
          `Database error: ${error.message}`,
        );
      }

      if (!signal) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "Signal not found.",
          }),
          {
            status: 404,
            headers: {
              ...corsHeaders,
              "Content-Type":
                "application/json",
            },
          },
        );
      }

      address =
        signal.token_address
          ?.toString()
          .trim();
    }

    if (!address) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "Signal does not have a token address.",
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // ==========================================================
    // DEXSCREENER
    // ==========================================================

    const dexUrl =
      `https://api.dexscreener.com/token-pairs/v1/solana/${address}`;

    const dexResponse =
      await fetch(dexUrl);

    if (!dexResponse.ok) {
      throw new Error(
        `DexScreener returned ${dexResponse.status}`,
      );
    }

    const dexData =
      await dexResponse.json();

    // Endpoint /token-pairs/v1/solana/{token}
    // zwraca BEZPOŚREDNIO tablicę par.

    const pairs =
      Array.isArray(dexData)
        ? dexData
        : [];

    if (pairs.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "DexScreener returned no pairs.",
          token_address: address,
          raw_response: dexData,
        }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // ==========================================================
    // SELECT BEST PAIR
    // ==========================================================

    const solanaPairs =
      pairs.filter(
        (pair: any) =>
          pair?.chainId === "solana",
      );

    if (solanaPairs.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "No Solana pair found.",
          token_address: address,
        }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // Wybieramy najbardziej płynną parę.
    solanaPairs.sort(
      (a: any, b: any) =>
        Number(
          b?.liquidity?.usd ?? 0,
        ) -
        Number(
          a?.liquidity?.usd ?? 0,
        ),
    );

    const bestPair =
      solanaPairs[0];

    // ==========================================================
    // FIND IMAGE
    // ==========================================================

    const imageUrl =
      typeof bestPair?.info?.imageUrl ===
        "string" &&
      bestPair.info.imageUrl.trim().length > 0
        ? bestPair.info.imageUrl.trim()
        : null;

    if (!imageUrl) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "DexScreener pair found, but no token image was available.",
          token_address: address,
          pair_address:
            bestPair?.pairAddress ?? null,
        }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // ==========================================================
    // UPDATE SIGNAL
    // ==========================================================

    if (signalId) {
      const { error } =
        await supabaseAdmin
          .from("signals")
          .update({
            image_url: imageUrl,
          })
          .eq("id", signalId);

      if (error) {
        throw new Error(
          `Failed to update signal: ${error.message}`,
        );
      }
    } else {
      const { error } =
        await supabaseAdmin
          .from("signals")
          .update({
            image_url: imageUrl,
          })
          .eq(
            "token_address",
            address,
          );

      if (error) {
        throw new Error(
          `Failed to update signals: ${error.message}`,
        );
      }
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    return new Response(
      JSON.stringify({
        success: true,
        symbol:
          bestPair?.baseToken?.symbol ??
          null,
        token_address: address,
        pair_address:
          bestPair?.pairAddress ??
          null,
        image_url: imageUrl,
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
      "sync-token-image error:",
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