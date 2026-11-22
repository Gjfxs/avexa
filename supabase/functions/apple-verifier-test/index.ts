
import "npm:reflect-metadata@0.2.2";
import { X509Certificate } from "npm:@peculiar/x509@2.2.0";

function base64ToBytes(value: string): Uint8Array<ArrayBuffer> {
  const binary = atob(value);
  const bytes = new Uint8Array(new ArrayBuffer(binary.length));

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes;
}

Deno.serve(async () => {
  const results: Record<string, unknown> = {};

  try {
    const g5Base64 = Deno.env.get("APPLE_WWDR_G5_BASE64");
    const rootBase64 = Deno.env.get("APPLE_ROOT_CA_CERT_BASE64");

    if (!g5Base64 || !rootBase64) {
      throw new Error("Apple certificate secret missing");
    }

    const g5 = new X509Certificate(base64ToBytes(g5Base64));
    const root = new X509Certificate(base64ToBytes(rootBase64));

    results.g5Subject = g5.subject;
    results.g5Issuer = g5.issuer;
    results.rootSubject = root.subject;

    results.g5ValidFrom = g5.notBefore;
    results.g5ValidTo = g5.notAfter;

    results.g5SignatureValid = await g5.verify({
      publicKey: root.publicKey,
    });

    results.rootSelfSignatureValid = await root.verify({
      publicKey: root.publicKey,
    });
  } catch (error) {
    results.testError = error instanceof Error
      ? error.message
      : String(error);
  }

  return Response.json({
    runtime: Deno.version.deno,
    results,
  });
});
