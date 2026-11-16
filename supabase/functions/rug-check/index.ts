const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const RUGCHECK_BASE_URL = "https://api.rugcheck.xyz/v1";

Deno.serve(async (req: Request) => {
  // ------------------------------------------------------------
  // CORS
  // ------------------------------------------------------------

  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  try {
    // ----------------------------------------------------------
    // REQUEST
    // ----------------------------------------------------------

    const body = await req.json();

    const mint = String(body?.mint ?? "").trim();

    if (!mint) {
      return jsonResponse(
        {
          success: false,
          error: "Token address is required.",
        },
        400,
      );
    }

    // Basic Solana address format check.
    const solanaAddressRegex =
      /^[1-9A-HJ-NP-Za-km-z]{32,44}$/;

    if (!solanaAddressRegex.test(mint)) {
      return jsonResponse(
        {
          success: false,
          error: "Invalid Solana token address.",
        },
        400,
      );
    }

    // ----------------------------------------------------------
    // FETCH RUGCHECK REPORT
    // ----------------------------------------------------------

    const controller = new AbortController();

    const timeout = setTimeout(() => {
      controller.abort();
    }, 15000);

    let response: Response;

    try {
      response = await fetch(
        `${RUGCHECK_BASE_URL}/tokens/${mint}/report`,
        {
          method: "GET",
          headers: {
            Accept: "application/json",
          },
          signal: controller.signal,
        },
      );
    } finally {
      clearTimeout(timeout);
    }

    // ----------------------------------------------------------
    // RUGCHECK ERROR
    // ----------------------------------------------------------

    if (!response.ok) {
      let message =
        `RugCheck returned HTTP ${response.status}.`;

      try {
        const errorBody = await response.json();

        if (
          errorBody &&
          typeof errorBody.message === "string"
        ) {
          message = errorBody.message;
        }
      } catch (_) {
        // Ignore invalid error response.
      }

      return jsonResponse(
        {
          success: false,
          error: message,
        },
        502,
      );
    }

    const report = await response.json();

    console.log("RUGCHECK REQUESTED MINT:", mint);
    console.log("RUGCHECK RESPONSE MINT:", report?.token?.mint);
    console.log("RUGCHECK REPORT KEYS:", Object.keys(report ?? {}));
    console.log("RUGCHECK SCORE:", report?.score_normalised);
    console.log("RUGCHECK TOKEN META:", report?.tokenMeta);
    console.log("RUGCHECK RISKS:", report?.risks);

    // ----------------------------------------------------------
    // TOKEN
    // ----------------------------------------------------------

    const token =
      report?.token ?? {};

    const tokenMeta =
      report?.tokenMeta ??
      report?.fileMeta ??
      {};

    const tokenName =
      String(
        tokenMeta?.name ??
          "Unknown Token",
      );

    const tokenSymbol =
      String(
        tokenMeta?.symbol ??
          "",
      );

    const tokenImage =
      tokenMeta?.image ??
      null;

    // ----------------------------------------------------------
    // SCORE
    // ----------------------------------------------------------

    const rugRisk =
      toNumber(
        report?.score_normalised,
      );

    const safetyScore =
      clamp(
        100 - rugRisk,
        0,
        100,
      );

    const riskLevel =
      getRiskLevel(rugRisk);

    // ----------------------------------------------------------
    // AUTHORITIES
    // ----------------------------------------------------------

    const mintAuthority =
      token?.mintAuthority ??
      report?.mintAuthority ??
      null;

    const freezeAuthority =
      token?.freezeAuthority ??
      report?.freezeAuthority ??
      null;

    const mintEnabled =
      mintAuthority !== null &&
      mintAuthority !== "";

    const freezeEnabled =
      freezeAuthority !== null &&
      freezeAuthority !== "";

    // ----------------------------------------------------------
    // LIQUIDITY
    // ----------------------------------------------------------

    const totalLiquidity =
      toNumber(
        report?.totalMarketLiquidity,
      );

    const totalLPProviders =
      report?.totalLPProviders == null
        ? null
        : toNumber(
            report.totalLPProviders,
          );

    // ----------------------------------------------------------
    // HOLDERS
    // ----------------------------------------------------------

    const rawTopHolders =
      Array.isArray(
        report?.topHolders,
      )
        ? report.topHolders
        : [];

    const topHolders =
      rawTopHolders as Array<
        Record<string, unknown>
      >;

    let topHolderPct:
      number | null = null;

    let top10Pct:
      number | null = null;

    if (topHolders.length > 0) {
      topHolderPct =
        toNumber(
          topHolders[0]?.pct,
        );

      top10Pct =
        topHolders
          .slice(0, 10)
          .reduce(
            (
              total: number,
              holder: Record<string, unknown>,
            ) => {
              return (
                total +
                toNumber(
                  holder.pct,
                )
              );
            },
            0,
          );
    }

    const totalHolders =
      report?.totalHolders == null
        ? null
        : toNumber(
            report.totalHolders,
          );

    // ----------------------------------------------------------
    // CREATOR
    // ----------------------------------------------------------

    const creator =
      report?.creator ??
      null;

    const creatorBalance =
      report?.creatorBalance;

    const supply =
      toNumber(
        token?.supply,
      );

    let creatorExposurePct:
      number | null = null;

    if (
      creatorBalance != null &&
      supply > 0
    ) {
      creatorExposurePct =
        (
          toNumber(
            creatorBalance,
          ) /
          supply
        ) *
        100;
    }

    // ----------------------------------------------------------
    // LP LOCK
    // ----------------------------------------------------------

    let lpLockedPct:
      number | null = null;

    const markets =
      Array.isArray(
        report?.markets,
      )
        ? report.markets
        : [];

    for (const market of markets) {
      const value =
        market?.lp?.lpLockedPct;

      if (value == null) {
        continue;
      }

      const current =
        toNumber(value);

      if (
        lpLockedPct === null ||
        current > lpLockedPct
      ) {
        lpLockedPct = current;
      }
    }

    // ----------------------------------------------------------
    // RISKS
    // ----------------------------------------------------------

    const rawRisks =
      Array.isArray(
        report?.risks,
      )
        ? report.risks
        : [];

    const risks =
      rawRisks.map(
        (
          risk: Record<string, unknown>,
        ) => {
          return {
            name:
              String(
                risk.name ??
                  "Unknown Risk",
              ),

            value:
              String(
                risk.value ??
                  "",
              ),

            description:
              String(
                risk.description ??
                  "",
              ),

            score:
              toNumber(
                risk.score,
              ),

            level:
              String(
                risk.level ??
                  "warn",
              ),
          };
        },
      );

    // ----------------------------------------------------------
    // SORT RISKS
    // ----------------------------------------------------------

    risks.sort(
      (
        a: {
          level: string;
        },
        b: {
          level: string;
        },
      ) => {
        const severity: Record<
          string,
          number
        > = {
          danger: 0,
          warn: 1,
          info: 2,
        };

        return (
          (severity[a.level] ?? 2) -
          (severity[b.level] ?? 2)
        );
      },
    );

    // ----------------------------------------------------------
    // INSIDER DATA
    // ----------------------------------------------------------

    const insiderNetworks =
      Array.isArray(
        report?.insiderNetworks,
      )
        ? report.insiderNetworks
        : [];

    const graphInsidersDetected =
      report?.graphInsidersDetected == null
        ? 0
        : toNumber(
            report.graphInsidersDetected,
          );

    // ----------------------------------------------------------
    // TOKEN EXTENSIONS
    // ----------------------------------------------------------

    const extensions =
      report?.token_extensions ??
      {};

    const transferFeeEnabled =
      extensions?.transferFeeConfig !=
      null;

    const permanentDelegateEnabled =
      extensions?.permanentDelegate !=
      null;

    const nonTransferable =
      extensions?.nonTransferable === true;

    const defaultAccountState =
      extensions?.defaultAccountState !=
      null;

    // ----------------------------------------------------------
    // FINAL AVEXA RESPONSE
    // ----------------------------------------------------------

    return jsonResponse(
      {
        success: true,

        mint,

        token: {
          name: tokenName,
          symbol: tokenSymbol,
          image: tokenImage,
          creator,
        },

        score: {
          safety: Math.round(
            safetyScore,
          ),
          rugRisk: Math.round(
            rugRisk,
          ),
          level: riskLevel,
        },

        authorities: {
          mintEnabled,
          freezeEnabled,
        },

        liquidity: {
          totalUsd:
            totalLiquidity,
          lpLockedPct,
          lpProviders:
            totalLPProviders,
        },

        holders: {
          total:
            totalHolders,
          topHolderPct,
          top10Pct,
        },

        creator: {
          address:
            creator,
          tokenExposurePct:
            creatorExposurePct,
        },

        insiders: {
          networkCount:
            insiderNetworks.length,
          detectedAccounts:
            graphInsidersDetected,
        },

        extensions: {
          transferFee:
            transferFeeEnabled,
          permanentDelegate:
            permanentDelegateEnabled,
          nonTransferable,
          defaultAccountState,
        },

        risks,
      },
      200,
    );
  } catch (error) {
    console.error(
      "Rug Check error:",
      error,
    );

    const message =
      error instanceof Error &&
      error.name === "AbortError"
        ? "RugCheck request timed out."
        : "Failed to analyze token.";

    return jsonResponse(
      {
        success: false,
        error: message,
      },
      500,
    );
  }
});

// ============================================================
// HELPERS
// ============================================================

function jsonResponse(
  body: unknown,
  status: number,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        ...corsHeaders,
        "Content-Type":
          "application/json",
      },
    },
  );
}

function toNumber(
  value: unknown,
): number {
  if (
    typeof value === "number" &&
    Number.isFinite(value)
  ) {
    return value;
  }

  const parsed =
    Number.parseFloat(
      String(value ?? ""),
    );

  return Number.isFinite(parsed)
    ? parsed
    : 0;
}

function clamp(
  value: number,
  min: number,
  max: number,
): number {
  return Math.min(
    max,
    Math.max(
      min,
      value,
    ),
  );
}

function getRiskLevel(
  rugRisk: number,
): string {
  if (rugRisk <= 20) {
    return "LOW RISK";
  }

  if (rugRisk <= 40) {
    return "MODERATE RISK";
  }

  if (rugRisk <= 70) {
    return "HIGH RISK";
  }

  return "CRITICAL RISK";
}