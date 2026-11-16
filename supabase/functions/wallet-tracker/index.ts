import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

console.log("Wallet Tracker webhook started");

const HELIUS_API_KEY = Deno.env.get("HELIUS_API_KEY");
const MAX_TRANSACTIONS_PER_WALLET = 500;

type TrackedWallet = {
  id: string;
  user_id: string;
  name: string;
  address: string;
  network: string;
};

type TokenBalance = {
  accountIndex?: number;
  mint?: string;
  owner?: string;
  uiTokenAmount?: {
    amount?: string;
    decimals?: number;
    uiAmount?: number | null;
    uiAmountString?: string;
  };
};

type HeliusEvent = {
  signature?: string;
  type?: string;
  source?: string;
  timestamp?: number;
  feePayer?: string;
  accountData?: Array<{
    account?: string;
    nativeBalanceChange?: number;
  }>;
  tokenTransfers?: Array<{
    fromUserAccount?: string;
    toUserAccount?: string;
    mint?: string;
    tokenAmount?: number;
  }>;
};

type TokenMetadata = {
  symbol: string | null;
  name: string | null;
  priceUsd: number | null;
};

type TokenDelta = {
  mint: string;
  delta: number;
};

const SOL_MINT = "So11111111111111111111111111111111111111112";

async function getTokenMetadata(
  mint: string,
): Promise<TokenMetadata> {
  if (!HELIUS_API_KEY) {
    console.error("HELIUS_API_KEY is not configured.");
    return { symbol: null, name: null, priceUsd: null };
  }

  try {
    const response = await fetch(
      `https://mainnet.helius-rpc.com/?api-key=${HELIUS_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: "wallet-tracker",
          method: "getAsset",
          params: {
            id: mint,
            displayOptions: { showFungible: true },
          },
        }),
      },
    );

    if (!response.ok) {
      console.error(`Helius getAsset failed: ${response.status}`);
      return { symbol: null, name: null, priceUsd: null };
    }

    const data = await response.json();
    const asset = data?.result;

    const symbol =
      asset?.content?.metadata?.symbol ??
      asset?.token_info?.symbol ??
      null;

    const name =
      asset?.content?.metadata?.name ??
      asset?.token_info?.name ??
      null;

    const priceRaw =
      asset?.token_info?.price_info?.price_per_token ??
      asset?.token_info?.price_info?.pricePerToken ??
      null;

    const price = priceRaw === null ? null : Number(priceRaw);

    return {
      symbol,
      name,
      priceUsd:
        price !== null && Number.isFinite(price) && price > 0
          ? price
          : null,
    };
  } catch (error) {
    console.error(`Metadata lookup failed for ${mint}:`, error);
    return { symbol: null, name: null, priceUsd: null };
  }
}

async function getTransactionTokenDeltas(
  signature: string,
  walletAddress: string,
): Promise<TokenDelta[]> {
  if (!HELIUS_API_KEY) {
    throw new Error("HELIUS_API_KEY is not configured");
  }

  const response = await fetch(
    `https://mainnet.helius-rpc.com/?api-key=${HELIUS_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: signature,
        method: "getTransaction",
        params: [
          signature,
          {
            encoding: "json",
            commitment: "confirmed",
            maxSupportedTransactionVersion: 1,
          },
        ],
      }),
    },
  );

  if (!response.ok) {
    throw new Error(`Helius getTransaction HTTP ${response.status}`);
  }

  const payload = await response.json();

  if (payload?.error) {
    throw new Error(
      `Helius RPC error: ${JSON.stringify(payload.error)}`,
    );
  }

  const tx = payload?.result;

  if (!tx?.meta || tx.meta.err) {
    return [];
  }

  const message = tx.transaction?.message;
  const staticKeys: string[] = (message?.accountKeys ?? []).map(
    (key: any) => typeof key === "string" ? key : key.pubkey,
  );

  const loaded = tx.meta.loadedAddresses;
  const allKeys = [
    ...staticKeys,
    ...(loaded?.writable ?? []),
    ...(loaded?.readonly ?? []),
  ];

  const pre: TokenBalance[] = tx.meta.preTokenBalances ?? [];
  const post: TokenBalance[] = tx.meta.postTokenBalances ?? [];

  const amounts = new Map<string, number>();

  function addBalances(
    balances: TokenBalance[],
    sign: number,
  ) {
    for (const balance of balances) {
      let owner = balance.owner;

      if (!owner && typeof balance.accountIndex === "number") {
        owner = allKeys[balance.accountIndex];
      }

      if (owner !== walletAddress || !balance.mint) continue;

      const raw = balance.uiTokenAmount?.uiAmount;
      const amount = raw === null || raw === undefined
        ? Number(balance.uiTokenAmount?.uiAmountString ?? 0)
        : Number(raw);

      if (!Number.isFinite(amount)) continue;

      amounts.set(
        balance.mint,
        (amounts.get(balance.mint) ?? 0) + sign * amount,
      );
    }
  }

  addBalances(pre, -1);
  addBalances(post, 1);

  return [...amounts.entries()]
    .map(([mint, delta]) => ({ mint, delta }))
    .filter((item) => item.mint !== SOL_MINT && Math.abs(item.delta) > 0);
}

async function enforceTransactionLimit(
  supabaseAdmin: any,
  walletId: string,
): Promise<void> {
  try {
    const { data, error } = await supabaseAdmin
      .from("wallet_transactions")
      .select("id")
      .eq("wallet_id", walletId)
      .order("occurred_at", { ascending: false, nullsFirst: false })
      .order("created_at", { ascending: false })
      .range(MAX_TRANSACTIONS_PER_WALLET, MAX_TRANSACTIONS_PER_WALLET + 999);

    if (error) {
      console.error("Transaction cleanup query failed:", error);
      return;
    }

    const ids = (data ?? [])
      .map((row: { id: string }) => row.id)
      .filter(Boolean);

    if (ids.length === 0) return;

    const { error: deleteError } = await supabaseAdmin
      .from("wallet_transactions")
      .delete()
      .in("id", ids);

    if (deleteError) {
      console.error("Transaction cleanup delete failed:", deleteError);
    } else {
      console.log(`Removed ${ids.length} old transactions for wallet ${walletId}`);
    }
  } catch (error) {
    console.error("Transaction cleanup failed:", error);
  }
}

export default {
  fetch: withSupabase(
    { auth: "none" },
    async (req, ctx) => {
      if (req.method !== "POST") {
        return new Response("Method Not Allowed", { status: 405 });
      }

      try {
        const body = await req.json();
        const events: HeliusEvent[] = Array.isArray(body) ? body : [body];

        console.log(`HELIUS WEBHOOK RECEIVED: ${events.length} event(s)`);

        const { data: wallets, error: walletsError } = await ctx.supabaseAdmin
          .from("tracked_wallets")
          .select("id, user_id, name, address, network")
          .eq("is_active", true)
          .eq("network", "Solana");

        if (walletsError) {
          console.error("Failed to load tracked wallets:", walletsError);
          return Response.json(
            { success: false, error: "Failed to load tracked wallets" },
            { status: 500 },
          );
        }

        const trackedWallets: TrackedWallet[] = wallets ?? [];
        let processed = 0;
        let inserted = 0;
        let skipped = 0;

        for (const event of events) {
          console.log("HELIUS EVENT DEBUG:", JSON.stringify({
            signature: event.signature,
            type: event.type,
            source: event.source,
            feePayer: event.feePayer,
            tokenTransfersCount: event.tokenTransfers?.length ?? 0,
            trackedWalletMatch: trackedWallets
              .filter((wallet) =>
                wallet.address === event.feePayer ||
                (event.tokenTransfers ?? []).some((transfer) =>
                  transfer.fromUserAccount === wallet.address ||
                  transfer.toUserAccount === wallet.address
                )
              )
              .map((wallet) => wallet.name),
          }));

          if (!event.signature || event.type !== "SWAP") {
            console.log(
              "EVENT SKIPPED: invalid signature or type",
              event.signature,
              event.type,
            );
            skipped++;
            continue;
          }

          // A single swap can involve more than one tracked wallet.
          const participatingWallets = trackedWallets.filter((wallet) => {
            if (event.feePayer === wallet.address) return true;

            return (event.tokenTransfers ?? []).some((transfer) =>
              transfer.fromUserAccount === wallet.address ||
              transfer.toUserAccount === wallet.address
            );
          });

          if (participatingWallets.length === 0) {
            skipped++;
            continue;
          }

          for (const wallet of participatingWallets) {
            processed++;

            // Check duplicates for this wallet + signature.
            const { data: existing, error: existingError } =
              await ctx.supabaseAdmin
                .from("wallet_transactions")
                .select("id")
                .eq("wallet_id", wallet.id)
                .eq("signature", event.signature)
                .maybeSingle();

            if (existingError) {
              console.error("Duplicate check failed:", existingError);
              skipped++;
              continue;
            }

            if (existing) {
              skipped++;
              continue;
            }

            let deltas: TokenDelta[];

            try {
              deltas = await getTransactionTokenDeltas(
                event.signature,
                wallet.address,
              );
            } catch (error) {
              console.error(
                `Could not analyze ${event.signature} for ${wallet.name}:`,
                error,
              );
              skipped++;
              continue;
            }

            // Choose the largest non-wrapped-SOL token balance change.
            // Do not guess if no token balance change can be established.
            deltas.sort((a, b) => Math.abs(b.delta) - Math.abs(a.delta));
            const tokenDelta = deltas[0];

            if (!tokenDelta || !tokenDelta.mint) {
              console.log(
                `No identifiable token delta: wallet=${wallet.name}, signature=${event.signature}`,
              );
              skipped++;
              continue;
            }

            const action: "BUY" | "SELL" =
              tokenDelta.delta > 0 ? "BUY" : "SELL";

            const amount = Math.abs(tokenDelta.delta);

            if (!Number.isFinite(amount) || amount <= 0) {
              skipped++;
              continue;
            }

            const metadata = await getTokenMetadata(tokenDelta.mint);
            const valueUsd = metadata.priceUsd !== null
              ? amount * metadata.priceUsd
              : null;

            const occurredAt = event.timestamp
              ? new Date(event.timestamp * 1000).toISOString()
              : new Date().toISOString();

            const { error: insertError } = await ctx.supabaseAdmin
              .from("wallet_transactions")
              .insert({
                wallet_id: wallet.id,
                signature: event.signature,
                action,
                token_address: tokenDelta.mint,
                token_symbol: metadata.symbol,
                token_name: metadata.name,
                amount,
                value_usd: valueUsd,
                occurred_at: occurredAt,
              });

            if (insertError) {
              // A concurrent webhook may have inserted it first.
              if (insertError.code !== "23505") {
                console.error("Transaction insert failed:", insertError);
              }
              skipped++;
              continue;
            }

            inserted++;

            console.log(
              [
                "WALLET TRANSACTION SAVED",
                `wallet=${wallet.name}`,
                `action=${action}`,
                `token=${metadata.symbol ?? tokenDelta.mint}`,
                `amount=${amount}`,
                `signature=${event.signature}`,
              ].join(" | "),
            );

            await enforceTransactionLimit(ctx.supabaseAdmin, wallet.id);
          }
        }

        return Response.json({
          success: true,
          processed,
          inserted,
          skipped,
        });
      } catch (error) {
        console.error("Wallet Tracker webhook error:", error);
        return Response.json(
          { success: false, error: "Invalid webhook payload" },
          { status: 400 },
        );
      }
    },
  ),
};
