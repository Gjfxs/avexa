const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export default {
  async fetch(req: Request): Promise<Response> {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: corsHeaders,
      });
    }

    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({
          error: "Only POST requests are allowed",
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

    try {
      const body = await req.json();

      const query =
        typeof body.query === "string" && body.query.trim().length > 0
          ? body.query.trim()
          : "crypto -is:retweet";

      const maxResults = Math.min(
        Math.max(Number(body.max_results) || 10, 10),
        100,
      );

      const bearerToken = Deno.env.get("X_BEARER_TOKEN");

      if (!bearerToken) {
        return new Response(
          JSON.stringify({
            error: "X_BEARER_TOKEN is not configured",
          }),
          {
            status: 500,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      const params = new URLSearchParams();

      params.set("query", query);
      params.set("max_results", maxResults.toString());

      params.set(
        "tweet.fields",
        "created_at,public_metrics,author_id,lang,conversation_id",
      );

      params.set(
        "user.fields",
        "name,username,profile_image_url,verified,public_metrics",
      );

      params.set("expansions", "author_id");

      const controller = new AbortController();

      const timeout = setTimeout(() => {
      controller.abort();
      }, 8000);

      let response: Response;

      try {
        response = await fetch(
          `https://api.x.com/2/tweets/search/recent?${params.toString()}`,
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${bearerToken}`,
            },
            signal: controller.signal,
          },
        );
      } finally {
        clearTimeout(timeout);
      }

      const data = await response.json();

      if (!response.ok) {
        return new Response(
          JSON.stringify({
            error: "X API request failed",
            details: data,
          }),
          {
            status: response.status,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      return new Response(
        JSON.stringify(data),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    } catch (error) {
      return new Response(
        JSON.stringify({
          error: "Internal server error",
          message: error instanceof Error
            ? error.message
            : String(error),
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }
  },
};