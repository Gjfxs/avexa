
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SYSTEM_PROMPT = `
You are Avexa AI Chart Analyst, an advanced cryptocurrency technical analyst.

Analyze ONLY information visible in the supplied chart image.
Never invent prices, indicators, levels, patterns or market data.
If information cannot be determined, use "Not visible".
For entry, stop loss and take profit, use "Not enough information"
when the chart does not support a responsible estimate.
Do not claim certainty. This is technical analysis, not financial advice.

Return ONLY a valid JSON object with exactly these keys:
{
  "market_structure": "string",
  "trend": "Bullish | Bearish | Sideways | Unclear",
  "trend_summary": "string",
  "momentum": "string",
  "support": "string",
  "resistance": "string",
  "pattern": "string",
  "setup": "string",
  "entry": "string",
  "stop_loss": "string",
  "take_profit": "string",
  "risk_reward": "string",
  "risk": "Low | Moderate | High | Unclear",
  "risk_explanation": "string",
  "sentiment": "string",
  "recommendation": "string",
  "confidence": 0,
  "confidence_explanation": "string"
}

Rules:
- confidence must be an integer from 0 to 100.
- Confidence measures only chart clarity and strength of visible evidence.
- Do not imply confidence is a probability of profit.
- Use concise, clear English.
- Use plain strings for all fields except confidence.
- Use "Not visible" whenever a field cannot be supported by the image.
- Keep the whole response concise, approximately 350 words maximum.
- Do not include Markdown fences or text outside the JSON object.
`;

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function readableAnalysis(a: Record<string, unknown>): string {
  const sections: [string, string][] = [
    ["📊 Market Structure", "market_structure"],
    ["📈 Trend", "trend"],
    ["Trend Summary", "trend_summary"],
    ["⚡ Momentum", "momentum"],
    ["🟢 Support", "support"],
    ["🔴 Resistance", "resistance"],
    ["🔍 Pattern", "pattern"],
    ["🎯 Setup", "setup"],
    ["📍 Entry", "entry"],
    ["🛑 Stop Loss", "stop_loss"],
    ["💰 Take Profit", "take_profit"],
    ["⚖ Risk / Reward", "risk_reward"],
    ["Risk", "risk"],
    ["Risk Explanation", "risk_explanation"],
    ["🧠 Market Sentiment", "sentiment"],
    ["Recommendation", "recommendation"],
    ["AI Confidence", "confidence"],
    ["Confidence Explanation", "confidence_explanation"],
  ];

  return sections
    .map(([label, key]) => `${label}\n${String(a[key] ?? "Not visible")}`)
    .join("\n\n");
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    if (!OPENAI_API_KEY) {
      return jsonResponse({ error: "OPENAI_API_KEY not found" }, 500);
    }

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return jsonResponse({
        error: "Supabase environment variables not configured",
      }, 500);
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return jsonResponse({ error: "Authentication required" }, 401);
    }

    const supabaseAdmin = createClient(
      SUPABASE_URL,
      SUPABASE_SERVICE_ROLE_KEY,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );

    const token = authHeader.substring("Bearer ".length);
    const {
      data: { user },
      error: userError,
    } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return jsonResponse({
        error: "Invalid or expired authentication.",
      }, 401);
    }

    const body = await req.json();
    const image = body?.image;

    if (
      typeof image !== "string" ||
      !/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(image)
    ) {
      return jsonResponse({ error: "Invalid or missing chart image" }, 400);
    }

    const response = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4.1-mini",
          temperature: 0.2,
          max_tokens: 1100,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: "Analyze this cryptocurrency chart and return the requested JSON.",
                },
                {
                  type: "image_url",
                  image_url: { url: image },
                },
              ],
            },
          ],
        }),
      },
    );

    const data = await response.json();

    if (!response.ok) {
      console.error("OpenAI error:", data);
      return jsonResponse({
        error: data?.error?.message ?? "OpenAI chart analysis failed.",
      }, response.status);
    }

    const raw = data?.choices?.[0]?.message?.content;

    if (typeof raw !== "string" || !raw.trim()) {
      return jsonResponse({ error: "No analysis returned by AI." }, 500);
    }

    let analysisData: Record<string, unknown>;

    try {
      analysisData = JSON.parse(raw);
    } catch {
      console.error("AI returned invalid JSON:", raw);
      return jsonResponse({
        error: "The AI returned an invalid analysis format. Please try again.",
      }, 502);
    }

    const requiredKeys = [
      "market_structure", "trend", "trend_summary", "momentum",
      "support", "resistance", "pattern", "setup", "entry",
      "stop_loss", "take_profit", "risk_reward", "risk",
      "risk_explanation", "sentiment", "recommendation",
      "confidence", "confidence_explanation",
    ];

    for (const key of requiredKeys) {
      if (analysisData[key] === undefined || analysisData[key] === null) {
        analysisData[key] = key === "confidence" ? 0 : "Not visible";
      }
    }

    const confidence = Number(analysisData.confidence);
    analysisData.confidence = Number.isFinite(confidence)
      ? Math.max(0, Math.min(100, Math.round(confidence)))
      : 0;

    // Keep the existing history column compatible with older records.
    const analysis = readableAnalysis(analysisData);

    const {
      data: savedAnalysis,
      error: saveError,
    } = await supabaseAdmin
      .from("ai_chart_analyses")
      .insert({
        user_id: user.id,
        analysis,
      })
      .select("id, created_at")
      .single();

    if (saveError) {
      console.error("Failed to save chart analysis:", saveError);
      return jsonResponse({
        error: "Analysis was generated, but could not be saved.",
      }, 500);
    }

    return jsonResponse({
      analysis,
      analysis_data: analysisData,
      saved: true,
      analysis_id: savedAnalysis?.id,
      created_at: savedAnalysis?.created_at,
    });
  } catch (error) {
    console.error("Chart analysis error:", error);
    return jsonResponse({ error: "An unexpected chart analysis error occurred." }, 500);
  }
});
