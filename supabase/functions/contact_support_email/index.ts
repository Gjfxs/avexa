
import nodemailer from "npm:nodemailer@^7";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

const smtpHost = Deno.env.get("SMTP_HOSTNAME")!;
const smtpPort = Number(Deno.env.get("SMTP_PORT") || "465");
const smtpUser = Deno.env.get("SMTP_USERNAME")!;
const smtpPassword = Deno.env.get("SMTP_PASSWORD")!;
const smtpFrom = Deno.env.get("SMTP_FROM") || "avexa@nex-start.com";

const supabase = createClient(supabaseUrl, supabaseAnonKey);

const transporter = nodemailer.createTransport({
  host: smtpHost,
  port: smtpPort,
  secure: smtpPort === 465,
  auth: {
    user: smtpUser,
    pass: smtpPassword,
  },
});

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (char) => {
    const entities: Record<string, string> = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    };

    return entities[char];
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const json = (
    body: Record<string, unknown>,
    status = 200,
  ) =>
    new Response(JSON.stringify(body), {
      status,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });

  if (req.method !== "POST") {
    return json({ error: "Method not allowed." }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");

    if (!authorization?.startsWith("Bearer ")) {
      return json({ error: "Authentication required." }, 401);
    }

    const token = authorization.substring(7);

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return json({ error: "Invalid session." }, 401);
    }

    const body = await req.json();

    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return json({ error: "Invalid request body." }, 400);
    }

    const topic =
      typeof body.topic === "string"
        ? body.topic.trim()
        : "";

    const customTopic =
      typeof body.custom_topic === "string"
        ? body.custom_topic.trim()
        : "";

    const message =
      typeof body.message === "string"
        ? body.message.trim()
        : "";

    if (!topic || topic.length > 100) {
      return json({ error: "Invalid topic." }, 400);
    }

    if (
      (topic === "Other" || topic === "Bug Report") &&
      !customTopic
    ) {
      return json({ error: "Please select a category." }, 400);
    }

    if (customTopic.length > 150) {
      return json({ error: "Custom topic is too long." }, 400);
    }

    if (message.length < 10 || message.length > 1000) {
      return json({
        error: "Message must contain 10–1000 characters.",
      }, 400);
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("username")
      .eq("id", user.id)
      .maybeSingle();

    if (profileError) {
      console.error("Profile lookup failed:", profileError.message);
    }

    const username =
      profile?.username ||
      user.email?.split("@")[0] ||
      "Avexa user";

    let displayTopic = topic;

    if (topic === "Bug Report") {
      displayTopic = `Bug Report - ${customTopic}`;
    } else if (topic === "Other") {
      displayTopic = `Other - ${customTopic}`;
    }

    const safeUsername = escapeHtml(username);
    const safeEmail = escapeHtml(user.email || "Not available");
    const safeTopic = escapeHtml(displayTopic);
    const safeMessage = escapeHtml(message).replace(/\n/g, "<br>");

    await transporter.sendMail({
      from: {
        name: "Avexa Support",
        address: smtpFrom,
      },
      to: "avexa@nex-start.com",
      replyTo: user.email || undefined,
      subject: `[Avexa Support] ${displayTopic}`,
      text:
        `New Avexa support request\n\n` +
        `Username: ${username}\n` +
        `User email: ${user.email || "Not available"}\n` +
        `User ID: ${user.id}\n` +
        `Topic: ${displayTopic}\n\n` +
        `Message:\n${message}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:640px;margin:auto;color:#172033">
          <h2 style="color:#149BFF">Avexa Support</h2>
          <p>A new support request has been submitted.</p>
          <p><strong>Username:</strong> ${safeUsername}</p>
          <p><strong>User email:</strong> ${safeEmail}</p>
          <p><strong>User ID:</strong> ${escapeHtml(user.id)}</p>
          <p><strong>Category:</strong> ${safeTopic}</p>
          <hr style="border:0;border-top:1px solid #ddd">
          <h3>Message</h3>
          <p style="line-height:1.7">${safeMessage}</p>
        </div>
      `,
    });

    console.info("Support email sent successfully.");

    return json({ success: true });
  } catch (error) {
    console.error(
      "Contact support email failed:",
      error instanceof Error ? error.message : "Unknown error",
    );

    return json({
      success: false,
      error: "The support email could not be sent.",
    }, 500);
  }
});
