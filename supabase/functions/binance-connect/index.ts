import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

async function sign(secret: string, message: string) {
  const encoder = new TextEncoder();

  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    {
      name: "HMAC",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(message),
  );

  return [...new Uint8Array(signature)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return Response.json(
        { success: false },
        { status: 405 },
      );
    }

    const { apiKey, apiSecret } = await req.json();

    if (!apiKey || !apiSecret) {
      return Response.json(
        {
          success: false,
          message: "Missing API credentials",
        },
        { status: 400 },
      );
    }

    const timestamp = Date.now();

    const query = `timestamp=${timestamp}`;

    const signature = await sign(
      apiSecret,
      query,
    );

    const response = await fetch(
      `https://api.binance.com/api/v3/account?${query}&signature=${signature}`,
      {
        headers: {
          "X-MBX-APIKEY": apiKey,
        },
      },
    );

    const data = await response.json();

    if (!response.ok) {
      return Response.json({
        success: false,
        message:
          data.msg ?? "Binance authentication failed.",
      });
    }

    return Response.json({
      success: true,
      accountType: data.accountType,
      balances: data.balances.length,
      canTrade: data.canTrade,
      canWithdraw: data.canWithdraw,
      canDeposit: data.canDeposit,
    });

  } catch (e) {

    return Response.json(
      {
        success: false,
        message: e.toString(),
      },
      { status: 500 },
    );
  }
});