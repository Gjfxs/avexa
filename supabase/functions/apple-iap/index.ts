import "npm:reflect-metadata@0.2.2";

import {
  X509Certificate,
} from "npm:@peculiar/x509@2.2.0";

const ROOT_URL =
  "https://www.apple.com/appleca/AppleIncRootCertificate.cer";

const WWDR_URL =
  "https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer";

const WWDR_OID = "1.2.840.113635.100.6.2.1";

async function fetchCertificate(url: string) {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Certificate download failed: HTTP ${response.status}`);
  }

  return new X509Certificate(
    new Uint8Array(await response.arrayBuffer()),
  );
}

Deno.serve(async () => {
  try {
    const [root, intermediate] = await Promise.all([
      fetchCertificate(ROOT_URL),
      fetchCertificate(WWDR_URL),
    ]);

    const now = new Date();

    const rootDateValid =
      now >= root.notBefore && now <= root.notAfter;

    const intermediateDateValid =
      now >= intermediate.notBefore &&
      now <= intermediate.notAfter;

    const rootSelfSigned = await root.verify({
      publicKey: root.publicKey,
    });

    const intermediateSignatureValid =
      await intermediate.verify({
        publicKey: root.publicKey,
      });

    const issuerMatches =
      intermediate.issuer === root.subject;

    const rootSelfIssued =
      root.issuer === root.subject;

    const wwdrOidPresent =
      intermediate.extensions.some(
        (extension) => extension.type === WWDR_OID,
      );

    const checks = {
      rootDateValid,
      intermediateDateValid,
      rootSelfSigned,
      intermediateSignatureValid,
      issuerMatches,
      rootSelfIssued,
      wwdrOidPresent,
    };

    const success = Object.values(checks).every(Boolean);

    return Response.json({
      success,
      runtime: Deno.version.deno,
      checks,
      root: {
        subject: root.subject,
        issuer: root.issuer,
        serialNumber: root.serialNumber,
        notBefore: root.notBefore.toISOString(),
        notAfter: root.notAfter.toISOString(),
      },
      intermediate: {
        subject: intermediate.subject,
        issuer: intermediate.issuer,
        serialNumber: intermediate.serialNumber,
        notBefore: intermediate.notBefore.toISOString(),
        notAfter: intermediate.notAfter.toISOString(),
      },
    });
  } catch (error) {
    return Response.json(
      {
        success: false,
        error: String(error),
      },
      { status: 500 },
    );
  }
});