import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

console.log("Wallet API started");

export default {
  fetch: withSupabase(
    { auth: "user" },
    async (req, ctx) => {
      try {
        // ============================================================
        // AUTH
        // ============================================================

        const userId = ctx.userClaims?.id;

        console.log("WALLET API AUTH:", {
          userId,
          email: ctx.userClaims?.email,
        });

        if (!userId) {
          return Response.json(
            {
              success: false,
              error: "Unauthorized",
            },
            { status: 401 },
          );
        }

        // ============================================================
        // GET
        // Pobiera portfele użytkownika + ich transakcje
        // ============================================================

        if (req.method === "GET") {
          const { data: wallets, error: walletsError } =
            await ctx.supabase
              .from("tracked_wallets")
              .select(
                `
                id,
                name,
                address,
                network,
                is_active,
                alerts_enabled,
                buy_alerts,
                sell_alerts,
                large_transaction_alerts,
                large_transaction_threshold,
                created_at,
                updated_at
                `,
              )
              .eq("user_id", userId)
              .order("created_at", {
                ascending: false,
              });

          if (walletsError) {
            console.error(
              "Failed to load wallets:",
              walletsError,
            );

            return Response.json(
              {
                success: false,
                error: "Failed to load wallets",
              },
              { status: 500 },
            );
          }

          const walletIds =
            wallets?.map((wallet) => wallet.id) ?? [];

          let transactions: unknown[] = [];

          if (walletIds.length > 0) {
            const {
              data,
              error: transactionsError,
            } = await ctx.supabase
              .from("wallet_transactions")
              .select(
                `
                id,
                wallet_id,
                signature,
                action,
                token_address,
                token_symbol,
                token_name,
                amount,
                value_usd,
                occurred_at,
                created_at
                `,
              )
              .in("wallet_id", walletIds)
              .order("occurred_at", {
                ascending: false,
              })
              .limit(100);

            if (transactionsError) {
              console.error(
                "Failed to load transactions:",
                transactionsError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to load transactions",
                },
                { status: 500 },
              );
            }

            transactions = data ?? [];
          }

          return Response.json({
            success: true,
            wallets: wallets ?? [],
            transactions,
          });
        }

        // ============================================================
        // POST
        // Add / Update / Delete
        // ============================================================

        if (req.method === "POST") {
          const body = await req.json();

          const action = body?.action;

          console.log("WALLET API ACTION:", action);

          // ==========================================================
          // ADD WALLET
          // ==========================================================

          if (action === "add") {
            const name =
              typeof body?.name === "string"
                ? body.name.trim()
                : "";

            const address =
              typeof body?.address === "string"
                ? body.address.trim()
                : "";

            const network =
              typeof body?.network === "string"
                ? body.network.trim()
                : "Solana";

            if (!name || !address) {
              return Response.json(
                {
                  success: false,
                  error: "Name and address are required",
                },
                { status: 400 },
              );
            }

            // Sprawdź czy użytkownik już posiada
            // ten portfel.

            const {
              data: existingWallet,
              error: existingError,
            } = await ctx.supabase
              .from("tracked_wallets")
              .select("id")
              .eq("user_id", userId)
              .eq("address", address)
              .maybeSingle();

            if (existingError) {
              console.error(
                "Failed checking existing wallet:",
                existingError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to check wallet",
                },
                { status: 500 },
              );
            }

            if (existingWallet) {
              return Response.json(
                {
                  success: false,
                  error: "This wallet is already tracked",
                },
                { status: 409 },
              );
            }

            const {
              data: wallet,
              error: insertError,
            } = await ctx.supabase
              .from("tracked_wallets")
              .insert({
                user_id: userId,
                name,
                address,
                network,
                is_active: true,
                alerts_enabled: true,
                buy_alerts: true,
                sell_alerts: true,
                large_transaction_alerts: true,
                large_transaction_threshold: 10000,
              })
              .select(
                `
                id,
                name,
                address,
                network,
                is_active,
                alerts_enabled,
                buy_alerts,
                sell_alerts,
                large_transaction_alerts,
                large_transaction_threshold,
                created_at,
                updated_at
                `,
              )
              .single();

            if (insertError) {
              console.error(
                "Failed to add wallet:",
                insertError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to add wallet",
                },
                { status: 500 },
              );
            }

            console.log(
              `Wallet added: ${name} (${address})`,
            );

            return Response.json({
              success: true,
              wallet,
            });
          }

          // ==========================================================
          // UPDATE WALLET
          // ==========================================================

          if (action === "update") {
            const walletId =
              typeof body?.wallet_id === "string"
                ? body.wallet_id
                : "";

            if (!walletId) {
              return Response.json(
                {
                  success: false,
                  error: "wallet_id is required",
                },
                { status: 400 },
              );
            }

            const updateData: Record<string, unknown> = {};

            if (typeof body?.name === "string") {
              const name = body.name.trim();

              if (name.length === 0) {
                return Response.json(
                  {
                    success: false,
                    error: "Wallet name cannot be empty",
                  },
                  { status: 400 },
                );
              }

              updateData.name = name;
            }

            if (typeof body?.alerts_enabled === "boolean") {
              updateData.alerts_enabled =
                body.alerts_enabled;
            }

            if (typeof body?.buy_alerts === "boolean") {
              updateData.buy_alerts =
                body.buy_alerts;
            }

            if (typeof body?.sell_alerts === "boolean") {
              updateData.sell_alerts =
                body.sell_alerts;
            }

            if (
              typeof body?.large_transaction_alerts ===
              "boolean"
            ) {
              updateData.large_transaction_alerts =
                body.large_transaction_alerts;
            }

            if (
              typeof body?.large_transaction_threshold ===
              "number"
            ) {
              updateData.large_transaction_threshold =
                body.large_transaction_threshold;
            }

            if (Object.keys(updateData).length === 0) {
              return Response.json(
                {
                  success: false,
                  error: "Nothing to update",
                },
                { status: 400 },
              );
            }

            updateData.updated_at =
              new Date().toISOString();

            const {
              data: wallet,
              error: updateError,
            } = await ctx.supabase
              .from("tracked_wallets")
              .update(updateData)
              .eq("id", walletId)
              .eq("user_id", userId)
              .select(
                `
                id,
                name,
                address,
                network,
                is_active,
                alerts_enabled,
                buy_alerts,
                sell_alerts,
                large_transaction_alerts,
                large_transaction_threshold,
                created_at,
                updated_at
                `,
              )
              .single();

            if (updateError) {
              console.error(
                "Failed to update wallet:",
                updateError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to update wallet",
                },
                { status: 500 },
              );
            }

            console.log(
              `Wallet updated: ${walletId}`,
            );

            return Response.json({
              success: true,
              wallet,
            });
          }


          // ==========================================================
          // DELETE WALLET
          // ==========================================================

          if (action === "delete") {
            const walletId =
              typeof body?.wallet_id === "string"
                ? body.wallet_id.trim()
                : "";

            if (!walletId) {
              return Response.json(
                {
                  success: false,
                  error: "wallet_id is required",
                },
                { status: 400 },
              );
            }

            // 1. Verify wallet ownership.

            const {
              data: wallet,
              error: walletCheckError,
            } = await ctx.supabase
              .from("tracked_wallets")
              .select("id")
              .eq("id", walletId)
              .eq("user_id", userId)
              .maybeSingle();

            if (walletCheckError) {
              console.error(
                "Failed to verify wallet ownership:",
                walletCheckError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to verify wallet ownership",
                },
                { status: 500 },
              );
            }

            if (!wallet) {
              return Response.json(
                {
                  success: false,
                  error: "Wallet not found",
                },
                { status: 404 },
              );
            }

            // 2. Delete the wallet.
            // Related transactions are automatically deleted
            // by the ON DELETE CASCADE foreign key.

            const {
              data: deletedWallet,
              error: walletDeleteError,
            } = await ctx.supabase
              .from("tracked_wallets")
              .delete()
              .eq("id", walletId)
              .eq("user_id", userId)
              .select("id")
              .maybeSingle();

            if (walletDeleteError) {
              console.error(
                "Failed to delete wallet:",
                walletDeleteError,
              );

              return Response.json(
                {
                  success: false,
                  error: "Failed to delete wallet",
                },
                { status: 500 },
              );
            }

            if (!deletedWallet) {
              return Response.json(
                {
                  success: false,
                  error: "Wallet could not be deleted",
                },
                { status: 409 },
              );
            }

            console.log("Wallet deleted successfully:", walletId);

            return Response.json({
              success: true,
              message: "Wallet deleted",
            });
          }


          // ==========================================================
          // UNKNOWN ACTION
          // ==========================================================

          return Response.json(
            {
              success: false,
              error: "Unknown action",
            },
            { status: 400 },
          );
        }

        // ============================================================
        // METHOD NOT ALLOWED
        // ============================================================

        return new Response(
          "Method Not Allowed",
          {
            status: 405,
          },
        );
      } catch (error) {
        console.error(
          "Wallet API error:",
          error,
        );

        return Response.json(
          {
            success: false,
            error: "Internal server error",
          },
          { status: 500 },
        );
      }
    },
  ),
};