const required = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_ANON_KEY",
  "RESEND_API_KEY",
  "RESEND_FROM_EMAIL",
  "OTP_SIGNING_SECRET",
];

const missing = required.filter((name) => !process.env[name]?.trim());

if (missing.length) {
  console.error(`Missing Cloudflare environment variables: ${missing.join(", ")}`);
  console.error("Copy .env.cloudflare.example to .env.cloudflare and fill in every value.");
  process.exit(1);
}

if ((process.env.OTP_SIGNING_SECRET?.length ?? 0) < 32) {
  console.error("OTP_SIGNING_SECRET must be at least 32 characters. Generate one with: openssl rand -hex 32");
  process.exit(1);
}

console.log("Cloudflare environment is complete.");
