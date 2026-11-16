import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      { success: false, error: "Method not allowed" },
      405,
    );
  }

  try {
    // 1. Verify the user's access token.

    const authorization = req.headers.get("Authorization");

    if (!authorization?.startsWith("Bearer ")) {
      return jsonResponse(
        { success: false, error: "Unauthorized" },
        401,
      );
    }

    const token = authorization.substring(7).trim();

    if (!token) {
      return jsonResponse(
        { success: false, error: "Unauthorized" },
        401,
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get(
      "SUPABASE_SERVICE_ROLE_KEY",
    );

    if (!supabaseUrl || !serviceRoleKey) {
      console.error("Missing Supabase environment variables");

      return jsonResponse(
        { success: false, error: "Server configuration error" },
        500,
      );
    }

    // Admin client exists only on the server.

    const admin = createClient(
      supabaseUrl,
      serviceRoleKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );

    // Authenticate the actual user.

    const {
      data: { user },
      error: authError,
    } = await admin.auth.getUser(token);

    if (authError || !user) {
      return jsonResponse(
        { success: false, error: "Invalid session" },
        401,
      );
    }

    const userId = user.id;

    console.log("Starting account deletion:", userId);

    // 2. Remove custom avatar files FIRST.

    const avatarBucket = admin.storage.from("avatars");
    const avatarPaths = new Set<string>();

    async function collectAvatarFiles(
      folder: string,
      depth = 0,
    ): Promise<void> {
      if (depth > 5) {
        throw new Error("Avatar folder nesting limit exceeded");
      }

      let offset = 0;
      const limit = 1000;

      while (true) {
        const { data, error } = await avatarBucket.list(folder, {
          limit,
          offset,
        });

        if (error) {
          throw new Error("Could not list avatar files");
        }

        const files = data ?? [];

        for (const item of files) {
          const path = `${folder}/${item.name}`;

          if (item.id) {
            avatarPaths.add(path);
          } else {
            await collectAvatarFiles(path, depth + 1);
          }
        }

        if (files.length < limit) {
          break;
        }

        offset += limit;
      }
    }

    // UUID folder containing custom avatars.

    await collectAvatarFiles(userId);

    // Older format: UUID.jpg in the bucket root.

    const { data: rootFiles, error: rootError } =
      await avatarBucket.list("", {
        search: `${userId}.jpg`,
        limit: 100,
        offset: 0,
      });

    if (rootError) {
      throw new Error("Could not inspect avatar root");
    }

    for (const file of rootFiles ?? []) {
      if (file.id && file.name === `${userId}.jpg`) {
        avatarPaths.add(file.name);
      }
    }

    const paths = Array.from(avatarPaths);

    for (let i = 0; i < paths.length; i += 100) {
      const batch = paths.slice(i, i + 100);

      const { error } = await avatarBucket.remove(batch);

      if (error) {
        console.error("Avatar removal failed:", error);
        throw new Error("Could not remove avatar files");
      }
    }

    console.log("Avatar files removed:", paths.length);

    // 3. Delete database records in one SQL transaction.

    const { error: databaseError } = await admin.rpc(
      "delete_user_data",
      {
        p_user_id: userId,
      },
    );

    if (databaseError) {
      console.error("Database deletion failed:", databaseError);
      throw new Error("Database deletion failed");
    }

    console.log("Database records deleted:", userId);

    // 4. Delete the Auth account LAST.

    const { error: authDeleteError } =
      await admin.auth.admin.deleteUser(userId);

    if (authDeleteError) {
      console.error(
        "Auth account deletion failed:",
        authDeleteError,
      );

      throw new Error("Could not delete authentication account");
    }

    console.log("Account successfully deleted:", userId);

    return jsonResponse({
      success: true,
      message: "Account successfully deleted",
    });
  } catch (error) {
    console.error("DELETE ACCOUNT ERROR:", error);

    return jsonResponse(
      {
        success: false,
        error: "Account deletion failed. Please contact support.",
      },
      500,
    );
  }
});