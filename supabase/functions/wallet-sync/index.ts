import { withSupabase } from "npm:@supabase/server@^1";

const HELIUS_API_KEY = Deno.env.get("HELIUS_API_KEY");
const MAX_TRANSACTIONS = 100;

const WSOL_MINT = "So11111111111111111111111111111111111111112";
const USDC_MINT = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v";

type TokenTransfer = {
  mint?: string;
  tokenAmount?: number;
  fromUserAccount?: string;
  toUserAccount?: string;
};

type EnhancedTransaction = {
  signature?: string;
  type?: string;
  timestamp?: number;
  tokenTransfers?: TokenTransfer[];
};

type Wallet = {
  id: string;
  name: string;
  address: string;
};

function jsonError(message: string, status: number) {
  return Response.json(
    { success: false, error: message },
    { status },
  );
}

function isQuoteToken(mint: string): boolean {
  return mint === WSOL_MINT || mint === USDC_MINT;
}

async function getTokenMetadata(mint: string) {
  if (!HELIUS_API_KEY) {
    return { symbol: null, name: null };
  }

  try {
    const response = await fetch(
      `https://mainnet.helius-rpc.com/?api-key=${HELIUS_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: "wallet-sync",
          method: "getAsset",
          params: { id: mint },
        }),
      },
    );

    if (!response.ok) {
      return { symbol: null, name: null };
    }

    const payload = await response.json();
    const asset = payload?.result;

    return {
      symbol:
        asset?.content?.metadata?.symbol ??
        asset?.token_info?.symbol ??
        null,
      name:
        asset?.content?.metadata?.name ??
        asset?.token_info?.name ??
        null,
    };
  } catch {
    return { symbol: null, name: null };
  }
}

export default {
  fetch: withSupabase(
    { auth: "user" },
    async (req, ctx) => {
      if (req.method !== "POST") {
        return new Response("Method Not Allowed", {
          status: 405,
        });
      }

      const userId = ctx.userClaims?.id;

      if (!userId) {
        return jsonError("Unauthorized", 401);
      }

      if (!HELIUS_API_KEY) {
        return jsonError(
          "HELIUS_API_KEY is not configured in Supabase",
          500,
        );
      }

      try {
        let requestedWalletId: string | null = null;

        try {
          const body = await req.json();

          if (body?.wallet_id !== undefined &&
              body?.wallet_id !== null) {
            if (typeof body.wallet_id !== "string" ||
                body.wallet_id.trim().length === 0) {
              return jsonError("Invalid wallet_id", 400);
            }

            requestedWalletId = body.wallet_id.trim();
          }
        } catch {
          return jsonError("Invalid JSON request body", 400);
        }

        let walletQuery = ctx.supabaseAdmin
          .from("tracked_wallets")
          .select("id, name, address")
          .eq("user_id", userId)
          .eq("network", "Solana")
          .eq("is_active", true);

        if (requestedWalletId !== null) {
          walletQuery = walletQuery.eq("id", requestedWalletId);
        }

        const { data: wallets, error: walletsError } =
          await walletQuery;

        if (walletsError) {
          console.error("Wallet lookup failed:", walletsError);
          return jsonError("Failed to load wallets", 500);
        }

        if (requestedWalletId !== null &&
            (!wallets || wallets.length === 0)) {
          return jsonError(
            "Wallet not found, inactive, or not accessible",
            404,
          );
        }

        let checked = 0;
        let swapsFound = 0;
        let inserted = 0;
        let skipped = 0;
        let failedWallets = 0;

        const metadataCache = new Map<
          string,
          { symbol: string | null; name: string | null }
        >();

        for (const wallet of (wallets ?? []) as Wallet[]) {
          try {
            const url = new URL(
              `https://api-mainnet.helius-rpc.com/v0/addresses/${encodeURIComponent(wallet.address)}/transactions`,
            );

            url.searchParams.set("api-key", HELIUS_API_KEY);
            url.searchParams.set("limit", String(MAX_TRANSACTIONS));
            url.searchParams.set("sort-order", "desc");
            url.searchParams.set("token-accounts", "balanceChanged");

            const response = await fetch(url.toString());

            if (!response.ok) {
              console.error(
                "Helius history request failed:",
                response.status,
                "wallet:",
                wallet.id,
              );

              failedWallets++;
              continue;
            }

            const payload = await response.json();

            if (!Array.isArray(payload)) {
              console.error(
                "Unexpected Helius response for wallet:",
                wallet.id,
              );

              failedWallets++;
              continue;
            }

            for (const tx of payload as EnhancedTransaction[]) {
              checked++;

              if (
                !tx.signature ||
                tx.type?.toUpperCase() !== "SWAP"
              ) {
                skipped++;
                continue;
              }

              swapsFound++;

              const transfers = tx.tokenTransfers ?? [];

              const received = transfers.filter(
                (transfer) =>
                  transfer.toUserAccount === wallet.address &&
                  transfer.mint &&
                  !isQuoteToken(transfer.mint),
              );

              const sent = transfers.filter(
                (transfer) =>
                  transfer.fromUserAccount === wallet.address &&
                  transfer.mint &&
                  !isQuoteToken(transfer.mint),
              );

              // Skip ambiguous swaps involving multiple token sides.
              if (
                (received.length > 0) === (sent.length > 0)
              ) {
                skipped++;
                continue;
              }

              const target = received.length > 0
                ? received[0]
                : sent[0];

              const mint = target.mint;

              if (
                !mint ||
                !Number.isFinite(Number(target.tokenAmount)) ||
                Number(target.tokenAmount) <= 0
              ) {
                skipped++;
                continue;
              }

              const action = received.length > 0 ? "BUY" : "SELL";

              let metadata = metadataCache.get(mint);

              if (!metadata) {
                metadata = await getTokenMetadata(mint);
                metadataCache.set(mint, metadata);
              }

              const { error: insertError } =
                await ctx.supabaseAdmin
                  .from("wallet_transactions")
                  .upsert(
                    {
                      wallet_id: wallet.id,
                      signature: tx.signature,
                      action,
                      token_address: mint,
                      token_symbol: metadata.symbol,
                      token_name: metadata.name,
                      amount: Number(target.tokenAmount),
                      value_usd: null,
                      occurred_at: tx.timestamp
                        ? new Date(
                            tx.timestamp * 1000,
                          ).toISOString()
                        : new Date().toISOString(),
                    },
                    {
                      onConflict: "wallet_id,signature",
                      ignoreDuplicates: true,
                    },
                  );

              if (insertError) {
                console.error(
                  "Transaction save failed:",
                  insertError,
                );
                skipped++;
                continue;
              }

              inserted++;
            }
          } catch (walletError) {
            console.error(
              "Wallet processing failed:",
              wallet.id,
              walletError,
            );
            failedWallets++;
          }
        }

        if (failedWallets > 0) {
          return Response.json(
            {
              success: false,
              error: "Some wallets could not be synchronized",
              wallets: wallets?.length ?? 0,
              checked,
              swapsFound,
              inserted,
              skipped,
              failedWallets,
            },
            { status: 502 },
          );
        }

        return Response.json({
          success: true,
          wallets: wallets?.length ?? 0,
          checked,
          swapsFound,
          inserted,
          skipped,
          failedWallets,
          scope: requestedWalletId ? "single_wallet" : "all_wallets",
        });
      } catch (error) {
        console.error("Wallet sync failed:", error);

        return jsonError(
          error instanceof Error
            ? error.message
            : "Wallet synchronization failed",
          500,
        );
      }
    },
  ),
};