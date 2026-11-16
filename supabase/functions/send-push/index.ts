import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { GoogleAuth } from "npm:google-auth-library@10.5.0";

const SUPABASE_URL =
  Deno.env.get("SUPABASE_URL")!;

const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const FIREBASE_SERVICE_ACCOUNT_RAW =
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

const INTERNAL_PUSH_SECRET =
  Deno.env.get("INTERNAL_PUSH_SECRET");

const headers = {
  "Content-Type": "application/json",
  "apikey": SUPABASE_SERVICE_ROLE_KEY,
  "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
};

type PushEvent =
  | "new_free_signal"
  | "new_pro_signal"
  | "tp1_hit"
  | "tp2_hit"
  | "tp3_hit"
  | "stop_loss"
  | "pro_signal_expired"
  | "test";

type PushRequest = {
  event: PushEvent;

  signal?: {
    id?: string;
    symbol?: string;
    direction?: string;
    entry_price?: number;
    take_profit_1?: number;
    take_profit_2?: number;
    take_profit_3?: number;
    stop_loss?: number;
    market?: string;
    tier?: string;
  };

  user_id?: string;
};

function getNotificationContent(
  event: PushEvent,
  signal?: PushRequest["signal"],
) {
  const symbol =
    signal?.symbol ?? "MEME";

  const direction =
    signal?.direction ?? "";

  switch (event) {
    case "new_free_signal":
      return {
        title: "⚡ FREE Signal Ready",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} — a new FREE MEME signal is available.`,
      };

    case "new_pro_signal":
      return {
        title: "✨ New PRO Signal",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} — a new PRO MEME signal is available.`,
      };

    case "tp1_hit":
      return {
        title: "🎯 TP1 HIT",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} reached Take Profit 1.`,
      };

    case "tp2_hit":
      return {
        title: "🎯 TP2 HIT",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} reached Take Profit 2.`,
      };

    case "tp3_hit":
      return {
        title: "🎯 TP3 HIT",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} reached Take Profit 3.`,
      };

    case "stop_loss":
      return {
        title: "🛑 STOP LOSS",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} reached the stop loss.`,
      };

    case "pro_signal_expired":
      return {
        title: "⏰ PRO Signal Expired",
        body:
          `${symbol}${direction ? ` ${direction}` : ""} — the PRO signal has expired.`,
      };

    case "test":
      return {
        title: "🔔 Avexa Notification Test",
        body: "Avexa notification system is working correctly!",
      };


  }
}

function getSettingColumn(event: PushEvent) {
  switch (event) {
    case "new_free_signal":
      return "free_signals";

    case "new_pro_signal":
      return "pro_signals";

    case "tp1_hit":
    case "tp2_hit":
    case "tp3_hit":
    case "stop_loss":
      return "tp_hits";

    case "pro_signal_expired":
      return "pro_signals";

    case "test":
      return "push_enabled";
  }
}

async function getFirebaseAccessToken() {
  if (!FIREBASE_SERVICE_ACCOUNT_RAW) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT secret is missing",
    );
  }

  const serviceAccount =
    JSON.parse(FIREBASE_SERVICE_ACCOUNT_RAW);

  const projectId =
    serviceAccount.project_id;

  if (!projectId) {
    throw new Error(
      "Firebase service account does not contain project_id",
    );
  }

  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: [
      "https://www.googleapis.com/auth/firebase.messaging",
    ],
  });

  const client =
    await auth.getClient();

  const accessTokenResponse =
    await client.getAccessToken();

  const accessToken =
    typeof accessTokenResponse === "string"
      ? accessTokenResponse
      : accessTokenResponse?.token;

  if (!accessToken) {
    throw new Error(
      "Could not obtain Firebase access token",
    );
  }

  return {
    projectId,
    accessToken,
  };
}

async function getDevices(
  event: PushEvent,
  userId?: string,
) {
  const settingColumn =
    getSettingColumn(event);

  let settingsUrl =
    `${SUPABASE_URL}/rest/v1/notification_settings` +
    `?select=user_id` +
    `&push_enabled=eq.true` +
    `&${settingColumn}=eq.true`;

  if (userId) {
    settingsUrl +=
      `&user_id=eq.${encodeURIComponent(userId)}`;
  }

  const settingsResponse =
    await fetch(
      settingsUrl,
      {
        headers,
      },
    );

  if (!settingsResponse.ok) {
    throw new Error(
      `Failed to fetch notification settings: ${settingsResponse.status}`,
    );
  }

  const settings =
    await settingsResponse.json();

  if (!Array.isArray(settings) ||
      settings.length === 0) {
    return [];
  }

  const userIds =
    settings.map(
      (item: any) => item.user_id,
    );

  const devicesUrl =
    `${SUPABASE_URL}/rest/v1/user_devices` +
    `?select=user_id,fcm_token,platform` +
    `&platform=eq.ios` +
    `&user_id=in.(${userIds.join(",")})`;

  const devicesResponse =
    await fetch(
      devicesUrl,
      {
        headers,
      },
    );

  if (!devicesResponse.ok) {
    throw new Error(
      `Failed to fetch devices: ${devicesResponse.status}`,
    );
  }

  return await devicesResponse.json();
}

async function sendFcmMessage(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  projectId: string,
  accessToken: string,
) {
  const response =
    await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization:
            `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token,

            notification: {
              title,
              body,
            },

            data,

            apns: {
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
                },
              },
            },
          },
        }),
      },
    );

  const result =
    await response.text();

  return {
    success: response.ok,
    status: response.status,
    result,
  };
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({
          error: "POST required",
        }),
        {
          status: 405,
          headers: {
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    const providedSecret =
      req.headers.get("x-internal-secret");

    if (!INTERNAL_PUSH_SECRET) {
      console.error("INTERNAL_PUSH_SECRET is missing");

      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    if (
      !providedSecret ||
      providedSecret !== INTERNAL_PUSH_SECRET
    ) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const body =
      await req.json() as PushRequest;

    const event =
      body.event;

    const allowedEvents = [
      "new_free_signal",
      "new_pro_signal",
      "tp1_hit",
      "tp2_hit",
      "tp3_hit",
      "stop_loss",
      "pro_signal_expired",
      "test",
    ];

    if (!allowedEvents.includes(event)) {
      return new Response(
        JSON.stringify({ error: "Invalid event" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    if (!event) {
      return new Response(
        JSON.stringify({
          error: "Missing event",
        }),
        {
          status: 400,
          headers: {
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    const content =
      getNotificationContent(
        event,
        body.signal,
      );

    const devices =
      await getDevices(
        event,
        body.user_id,
      );

    if (devices.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message:
            "No eligible devices found",
          sent: 0,
        }),
        {
          status: 200,
          headers: {
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    const {
      projectId,
      accessToken,
    } =
      await getFirebaseAccessToken();

    const results = [];

    for (const device of devices) {
      try {
        const result =
          await sendFcmMessage(
            device.fcm_token,
            content.title,
            content.body,
            {
              type: event,
              signal_id:
                body.signal?.id ?? "",
              symbol:
                body.signal?.symbol ?? "",
              market:
                body.signal?.market ?? "MEME",
              tier:
                body.signal?.tier ?? "",
            },
            projectId,
            accessToken,
          );

        results.push({
          user_id: device.user_id,
          success: result.success,
          status: result.status,
        });
      } catch (error) {
        results.push({
          user_id: device.user_id,
          success: false,
          error: String(error),
        });
      }
    }

    const successful =
      results.filter(
        (result) => result.success,
      ).length;

    return new Response(
      JSON.stringify({
        success: true,
        event,
        title: content.title,
        body: content.body,
        devices: devices.length,
        sent: successful,
        results,
      }),
      {
        status: 200,
        headers: {
          "Content-Type":
            "application/json",
        },
      },
    );
  } catch (error) {
    console.error(
      "SEND PUSH ERROR:",
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
          "Content-Type":
            "application/json",
        },
      },
    );
  }
});