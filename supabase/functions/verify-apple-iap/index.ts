import "npm:reflect-metadata@0.2.2";

import { createClient } from "npm:@supabase/supabase-js@2";
import { decodeProtectedHeader, importX509, jwtVerify } from "npm:jose@6.1.0";
import { X509Certificate } from "npm:@peculiar/x509@2.2.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get(
  "SUPABASE_SERVICE_ROLE_KEY",
)!;

const BUNDLE_ID = Deno.env.get("APPLE_BUNDLE_ID")!;

const ROOT_CA_CERTIFICATES = [
  {
    name: "Apple Root CA G1",
    base64: Deno.env.get("APPLE_ROOT_CA_CERT_BASE64"),
    fingerprint:
      "B0B1730ECBC7FF4505142C49F1295E6EDA6BCAED7E2C68C5BE91B5A11001F024",
  },
  {
    name: "Apple Root CA G3",
    base64: Deno.env.get("APPLE_ROOT_CA_G3_BASE64"),
    fingerprint:
      "63343ABFB89A6A03EBB57E9B3F5FA7BE7C4F5C756F3017B3A8C488C3653E9179",
  },
];

const LEAF_OID = "1.2.840.113635.100.6.11.1";
const WWDR_OID = "1.2.840.113635.100.6.2.1";

const ALLOWED_PRODUCTS = new Set([
  "analyx_pro_monthly",
  "analyx_pro_yearly",
]);

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

function base64ToBytes(
  value: string,
  label = "unknown",
): Uint8Array<ArrayBuffer> {
  const binary = atob(value);
  const bytes = new Uint8Array(new ArrayBuffer(binary.length));

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes;
}

function toPem(base64: string): string {
  const lines = base64.match(/.{1,64}/g)?.join("\n") ?? base64;
  return `-----BEGIN CERTIFICATE-----\n${lines}\n-----END CERTIFICATE-----`;
}

function hasExtension(cert: X509Certificate, oid: string): boolean {
  return cert.extensions.some((extension) => extension.type === oid);
}

function isCertificateCurrentlyValid(cert: X509Certificate): boolean {
  const now = Date.now();

  return (
    new Date(cert.notBefore).getTime() <= now &&
    new Date(cert.notAfter).getTime() >= now
  );
}

async function sha256Hex(
  data: Uint8Array<ArrayBuffer>,
): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", data);

  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("")
    .toUpperCase();
}

async function verifyAppleJws(signedTransaction: string) {
  if (
    typeof signedTransaction !== "string" ||
    signedTransaction.length < 100 ||
    signedTransaction.length > 100_000
  ) {
    throw new Error("Invalid signed transaction");
  }

  const header = decodeProtectedHeader(signedTransaction);

  if (header.alg !== "ES256") {
    throw new Error("Unsupported JWS algorithm");
  }

  if (
    !Array.isArray(header.x5c) ||
    header.x5c.length !== 3 ||
    !header.x5c.every((item) => typeof item === "string")
  ) {
    throw new Error("Invalid Apple certificate chain");
  }

  const [leafBase64, intermediateBase64, rootBase64] = header.x5c;

  const leaf = new X509Certificate(base64ToBytes(leafBase64));

  const intermediate = new X509Certificate(
    base64ToBytes(intermediateBase64),
  );

  const presentedRoot = new X509Certificate(
    base64ToBytes(rootBase64),
  );

  // Fingerprint of the root certificate supplied by Apple.
  const presentedRootFingerprint = await sha256Hex(
    base64ToBytes(rootBase64),
  );

  // Only explicitly trusted Apple roots are accepted.
  const trustedRootConfig = ROOT_CA_CERTIFICATES.find(
    (certificate) => certificate.fingerprint === presentedRootFingerprint,
  );

  if (!trustedRootConfig) {
    console.error("Untrusted Apple root certificate:", {
      presentedRootSubject: presentedRoot.subject,
      presentedRootIssuer: presentedRoot.issuer,
      presentedRootFingerprint,
    });

    throw new Error("Untrusted Apple root certificate");
  }

  if (!trustedRootConfig.base64) {
    throw new Error("Trusted Apple root certificate is not configured");
  }

  const trustedRoot = new X509Certificate(
    base64ToBytes(trustedRootConfig.base64),
  );

  const trustedRootFingerprint = await sha256Hex(
    base64ToBytes(trustedRootConfig.base64),
  );

  if (trustedRootFingerprint !== trustedRootConfig.fingerprint) {
    console.error("APPLE ROOT FINGERPRINT MISMATCH:", {
      certificate: trustedRootConfig.name,
      calculated: trustedRootFingerprint,
      expected: trustedRootConfig.fingerprint,
      decodedBytes: base64ToBytes(
        trustedRootConfig.base64,
        trustedRootConfig.name,
      ).length,
    });

    throw new Error("Configured Apple root certificate mismatch");
  }

  if (
    presentedRoot.subject !== trustedRoot.subject ||
    presentedRoot.issuer !== trustedRoot.issuer
  ) {
    throw new Error("Apple root certificate mismatch");
  }

  console.log(
    "Trusted Apple root certificate:",
    trustedRootConfig.name,
  );

  // Check certificate validity periods.
  if (
    !isCertificateCurrentlyValid(leaf) ||
    !isCertificateCurrentlyValid(intermediate) ||
    !isCertificateCurrentlyValid(trustedRoot)
  ) {
    throw new Error("Apple certificate expired or not yet valid");
  }

  // Check certificate issuer relationships.
  if (
    intermediate.issuer !== trustedRoot.subject ||
    leaf.issuer !== intermediate.subject
  ) {
    throw new Error("Invalid certificate issuer chain");
  }

  // Check Apple certificate extensions.
  if (!hasExtension(leaf, LEAF_OID)) {
    throw new Error("Apple signing certificate extension missing");
  }

  if (!hasExtension(intermediate, WWDR_OID)) {
    throw new Error("Apple WWDR certificate extension missing");
  }

  // Verify certificate signatures.
  const rootSelfSigned = await trustedRoot.verify({
    publicKey: trustedRoot.publicKey,
  });

  const intermediateSigned = await intermediate.verify({
    publicKey: trustedRoot.publicKey,
  });

  const leafSigned = await leaf.verify({
    publicKey: intermediate.publicKey,
  });

  if (!rootSelfSigned || !intermediateSigned || !leafSigned) {
    throw new Error("Apple certificate signature verification failed");
  }

  // Verify the actual Apple JWS signature.
  const publicKey = await importX509(toPem(leafBase64), "ES256");

  const { payload } = await jwtVerify(
    signedTransaction,
    publicKey,
    {
      algorithms: ["ES256"],
    },
  );

  if (
    typeof payload !== "object" ||
    payload === null ||
    Array.isArray(payload)
  ) {
    throw new Error("Invalid transaction payload");
  }

  return payload as Record<string, unknown>;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");

    if (!authorization?.startsWith("Bearer ")) {
      return jsonResponse({ error: "Authentication required" }, 401);
    }

    const jwt = authorization.substring(7);

    const authClient = createClient(
      SUPABASE_URL,
      SUPABASE_ANON_KEY,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    const {
      data: { user },
      error: authError,
    } = await authClient.auth.getUser(jwt);

    if (authError || !user) {
      return jsonResponse({ error: "Invalid user session" }, 401);
    }

    const body = await req.json();
    const signedTransaction = body?.signedTransaction;

    if (typeof signedTransaction !== "string") {
      return jsonResponse({
        error: "Missing signedTransaction",
      }, 400);
    }

    const transaction = await verifyAppleJws(signedTransaction);

    if (transaction.bundleId !== BUNDLE_ID) {
      throw new Error("Bundle ID mismatch");
    }

    const productId = transaction.productId;
    const transactionId = transaction.transactionId;
    const originalTransactionId = transaction.originalTransactionId;
    const appAccountToken = transaction.appAccountToken;
    const environment = transaction.environment;
    const ownershipType = transaction.inAppOwnershipType;

    if (
      typeof productId !== "string" ||
      !ALLOWED_PRODUCTS.has(productId)
    ) {
      throw new Error("Unrecognized subscription product");
    }

    if (
      typeof transactionId !== "string" ||
      typeof originalTransactionId !== "string"
    ) {
      throw new Error("Missing transaction identifiers");
    }

    if (
      typeof appAccountToken !== "string" ||
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
        .test(appAccountToken)
    ) {
      throw new Error("Invalid app account token");
    }

    if (ownershipType !== "PURCHASED") {
      throw new Error("Family Sharing purchases are not supported");
    }

    if (environment !== "Sandbox") {
      throw new Error("Only Sandbox purchases are accepted during testing");
    }

    const purchaseDate = transaction.purchaseDate;
    const expiresDate = transaction.expiresDate;
    const revocationDate = transaction.revocationDate;

    if (
      typeof purchaseDate !== "number" ||
      typeof expiresDate !== "number"
    ) {
      throw new Error("Invalid transaction dates");
    }

    const serviceClient = createClient(
      SUPABASE_URL,
      SUPABASE_SERVICE_ROLE_KEY,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    const { data: account, error: accountError } = await serviceClient
      .from("user_iap_accounts")
      .select("app_account_token")
      .eq("user_id", user.id)
      .maybeSingle();

    if (accountError || !account) {
      throw new Error("IAP account not found");
    }

    if (
      account.app_account_token.toLowerCase() !==
      appAccountToken.toLowerCase()
    ) {
      console.log(
        "IAP: TRANSACTION TOKEN DOES NOT MATCH CURRENT USER",
      );

      // Find the Avexa account that owns this Apple appAccountToken.
      const { data: originalAccount, error: originalAccountError } =
        await serviceClient
          .from("user_iap_accounts")
          .select("user_id, app_account_token")
          .eq("app_account_token", appAccountToken)
          .maybeSingle();

      if (
        originalAccountError ||
        !originalAccount ||
        originalAccount.user_id === user.id
      ) {
        throw new Error("Transaction ownership could not be established");
      }

      // Confirm that this Apple transaction chain is already recorded
      // for that exact account, product and environment.
      const { data: previousTransaction, error: previousTransactionError } =
        await serviceClient
          .from("user_iap_transactions")
          .select(
            "id, user_id, original_transaction_id, product_id, environment, app_account_token",
          )
          .eq("user_id", originalAccount.user_id)
          .eq("original_transaction_id", originalTransactionId)
          .eq("product_id", productId)
          .eq("environment", environment)
          .eq("app_account_token", appAccountToken)
          .limit(1)
          .maybeSingle();

      if (
        previousTransactionError ||
        !previousTransaction ||
        previousTransaction.user_id !== originalAccount.user_id ||
        previousTransaction.original_transaction_id !== originalTransactionId
      ) {
        throw new Error(
          "Existing transaction ownership could not be confirmed",
        );
      }

      console.log(
        "IAP: VERIFIED TRANSACTION BELONGS TO ANOTHER AVEXA ACCOUNT",
        {
          currentUserId: user.id,
          originalOwnerId: originalAccount.user_id,
          productId,
          environment,
        },
      );

      // This is NOT a purchase approval for the current user.
      // It only confirms that the transaction belongs to another
      // already-established Avexa account.
      return jsonResponse({
        success: false,
        code: "TRANSACTION_BELONGS_TO_ANOTHER_ACCOUNT",
        completeTransaction: true,
      });
    }

    const { data: saved, error: saveError } = await serviceClient.rpc(
      "store_verified_apple_purchase",
      {
        p_user_id: user.id,
        p_transaction_id: transactionId,
        p_original_transaction_id: originalTransactionId,
        p_product_id: productId,
        p_environment: environment,
        p_app_account_token: appAccountToken,
        p_purchase_date: new Date(purchaseDate).toISOString(),
        p_expires_at: new Date(expiresDate).toISOString(),
        p_revocation_date: typeof revocationDate === "number"
          ? new Date(revocationDate).toISOString()
          : null,
        p_signed_transaction_info: signedTransaction,
      },
    );

    if (saveError) {
      console.error("Purchase persistence failed:", saveError.message);
      throw new Error("Could not save verified purchase");
    }

    return jsonResponse({
      success: true,
      subscription: saved,
    });
  } catch (error) {
    console.error(
      "Apple IAP verification failed:",
      error instanceof Error ? error.message : "Unknown error",
    );

    return jsonResponse({
      success: false,
      error: "Apple purchase verification failed",
    }, 400);
  }
});
