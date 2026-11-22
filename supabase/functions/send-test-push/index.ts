import { createClient } from "npm:@supabase/supabase-js@2";
import { GoogleAuth } from "npm:google-auth-library@10.5.0";

Deno.serve(async (req) => {
  try {
    const authorization = req.headers.get("Authorization");

    if (!authorization) {
      return new Response(
        JSON.stringify({ error: "Missing authorization" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const firebaseServiceAccountRaw = Deno.env.get(
      "FIREBASE_SERVICE_ACCOUNT",
    );

    if (!firebaseServiceAccountRaw) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret is missing");
    }

    // Client acting as the authenticated user.
    const supabase = createClient(
      supabaseUrl,
      supabaseAnonKey,
      {
        global: {
          headers: {
            Authorization: authorization,
          },
        },
      },
    );

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "User is not authenticated" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Get the user's latest iOS device.
    const { data: device, error: deviceError } = await supabase
      .from("user_devices")
      .select("fcm_token, platform")
      .eq("user_id", user.id)
      .eq("platform", "ios")
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (deviceError) {
      throw new Error(
        `Could not read user_devices: ${deviceError.message}`,
      );
    }

    if (!device?.fcm_token) {
      return new Response(
        JSON.stringify({
          error: "No iOS FCM token found for this user",
        }),
        {
          status: 404,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const serviceAccount = JSON.parse(firebaseServiceAccountRaw);

    const projectId = serviceAccount.project_id;

    if (!projectId) {
      throw new Error(
        "Firebase service account does not contain project_id",
      );
    }

    // Authenticate to Firebase Cloud Messaging.
    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: [
        "https://www.googleapis.com/auth/firebase.messaging",
      ],
    });

    const client = await auth.getClient();
    const accessTokenResponse = await client.getAccessToken();

    const accessToken =
      typeof accessTokenResponse === "string"
        ? accessTokenResponse
        : accessTokenResponse?.token;

    if (!accessToken) {
      throw new Error("Could not obtain Firebase access token");
    }

    // Send notification through FCM HTTP v1.
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: device.fcm_token,

            notification: {
              title: "🔔 Avexa Test Notification",
              body: "Push notifications are working correctly!",
            },

            data: {
              type: "test",
              source: "avexa",
            },

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

    const fcmResult = await fcmResponse.text();

    if (!fcmResponse.ok) {
      console.error("FCM ERROR:", fcmResult);

      return new Response(
        JSON.stringify({
          error: "FCM request failed",
          details: fcmResult,
        }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    console.log("FCM SUCCESS:", fcmResult);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Test push sent successfully",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("SEND TEST PUSH ERROR:", error);

    return new Response(
      JSON.stringify({
        error: error instanceof Error
          ? error.message
          : String(error),
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});