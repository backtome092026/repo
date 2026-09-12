# Back2Me

**Lost & found, sorted.** Back2Me turns a school’s physical lost-and-found pile into a searchable, measurable recovery system.

## Included

- Public landing page, forgiving item search, item details, and private claims
- Supabase authentication, PostgreSQL, Storage, multi-school RLS, and collision-safe item numbering
- Student donations, private requests, kindness stories and reactions, innovation recruiting, and opt-in leaderboards
- Parent-linked student progress plus staff community moderation
- School self-registration, student enrollment approval, expiring staff invitations, and role-aware sign-in
- Member profiles, configurable timelines, confidential safety reports, content hiding/deletion, and student blocking
- Staff intake, claim review, QR labels, lifecycle data, analytics, settings, and CSV reports
- Responsive layouts and honest empty/setup states before Supabase is configured

## Project map

```text
app/          Next.js App Router pages and server endpoints
components/   Reusable product and UI components
lib/          Data access, impact calculations, and Supabase clients
public/items/ Neutral item fallback artwork
supabase/     Production migrations
types/        Shared strict TypeScript models
proxy.ts      Auth refresh and staff-route protection
```

## Run locally

Install [Node.js 22+](https://nodejs.org), then:

```bash
npm install
npm run dev
```

Open the address shown in the terminal. Without environment values, Back2Me shows empty states and never invents school records.

## Supabase setup

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor** and run `supabase/migrations/001_initial_schema.sql`.
3. Run `supabase/migrations/002_community_platform.sql`.
4. Run `supabase/migrations/003_workflows.sql`.
5. Run `supabase/migrations/004_accounts_moderation_profiles.sql`.
6. The migrations create both media buckets, account triggers, security policies, and school workflows.
7. Copy `.env.example` to `.env.local` and add values from **Project Settings → API**:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

Never expose the service-role key in client code.

## Account and enrollment flow

- A school administrator opens `/signup/school`. Supabase automatically creates the school, settings, and first approved administrator profile.
- A student opens `/signup/student`, chooses a registered school, and submits identifying enrollment information.
- The student remains pending and cannot use protected community features.
- School staff review the request under **People & access**, then approve or deny it.
- Administrators create email-restricted, seven-day staff invitation links from the same screen.
- Login automatically routes approved students, parents, and staff to the correct dashboard.

For production, keep Supabase email confirmation enabled and configure the Site URL and redirect URLs under **Authentication → URL Configuration**.

## Test

- School: `/signup/school` → confirm email → invite staff.
- Student: `/signup/student` → choose school → confirm email → wait for approval → use `/student/dashboard`.
- Staff: approve enrollment → add item → print QR label → review claim → moderate community → review safety reports.
- Profiles: update `/me`, visit `/people`, write on an enabled timeline, and submit a private report.
- Privacy: in an incognito window, staff routes should redirect to login. Public queries must not reveal `internal_notes`, exact storage, student names, contacts, or claim details.
- Run `npm run build` before every deployment.

## Add another school

```sql
insert into public.schools (name, slug) values ('New School', 'new-school');
insert into public.school_settings (school_id)
select id from public.schools where slug='new-school';
```

Point the new school’s staff profiles to that UUID. RLS scopes operational access to the signed-in user’s school.

## Modify the design

Brand tokens are in `app/globals.css`. Shared brand/navigation components are `components/brand.tsx`, `components/public-header.tsx`, and `components/staff-shell.tsx`. Each screen is in its matching `app/` folder.

## Deploy to Cloudflare Workers

Back2Me builds to a Cloudflare Worker with static assets. For a first deployment:

```bash
cp .env.cloudflare.example .env.cloudflare
openssl rand -hex 32
# Add that random value and the other required values to .env.cloudflare.
npx wrangler login
npm run deploy:cloudflare
```

The five application variables are:

- `NEXT_PUBLIC_SUPABASE_URL` — Supabase project URL; public and embedded into the browser build.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` — Supabase publishable/anon key; public, with access constrained by RLS.
- `RESEND_API_KEY` — server-only API key used to send signup verification codes.
- `RESEND_FROM_EMAIL` — sender on a domain verified in Resend; `onboarding@resend.dev` is for testing only.
- `OTP_SIGNING_SECRET` — server-only random signing key of at least 32 characters.

For non-interactive or GitHub deployment, also set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`. These authenticate Wrangler and must not be added to `.env.cloudflare`, because that file is uploaded as Worker runtime secrets.

Automatic deployment uses the repository's Cloudflare Git integration. Add the five application variables above under **Workers & Pages → repo → Settings → Variables and Secrets** and in the Cloudflare build environment. The generated Wrangler configuration declares every value as required, preserves dashboard values on later deploys, and consistently targets the `repo` Worker. `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are needed only for command-line or another CI deployment.

After deployment, add the production URL in **Supabase → Authentication → URL Configuration**, verify the sending domain in Resend, attach any custom domain in the Worker’s **Settings → Domains & Routes**, and test search, login, OTP signup, claims, uploads, QR links, and CSV export.

## Impact formulas

- Recovery rate = returned ÷ total found × 100
- Estimated replacement value recovered = returned × configured average value
- Estimated staff time saved = total items × configured handling minutes
- Estimated staff cost saved = estimated hours × configured hourly cost
- Diverted from disposal = returned + donated

Estimates are operational indicators, not guaranteed financial savings.
