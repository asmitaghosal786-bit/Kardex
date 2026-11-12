 # Subscription Guardian

Subscription Guardian is a PayPal AI Hackathon demo that helps people review recurring spending, measured/manual usage, and cancellation recommendations without claiming a cancellation before PayPal verifies it.

## Architecture

- `app/`: Flutter mobile client. Supabase supplies authentication; the client sends the Supabase JWT to the API.
- `backend/`: FastAPI service with user-scoped SQLite for the demo. Production can point the same contract at Supabase Postgres.
- `web/`: Vite + React report surfaces at `/transactions` and `/spending`. A one-time code is exchanged for a short-lived web session; JWTs are never put in URLs. AG Grid Community is the explicit fallback unless `VITE_AG_STUDIO_ENABLED=true` is configured with the installed licensed Studio package.
- PayPal sandbox calls live behind `backend/app/paypal.py`. Demo seed rows are explicitly returned with `data_origin: demo_seed`.

## Run locally

1. Copy `backend/.env.example` to `backend/.env` and set `SUPABASE_JWT_SECRET`, `WEB_ORIGIN`, and sandbox credentials when using real PayPal data.
2. Start the API:

   ```powershell
   cd backend
   pip install -r requirements.txt
   uvicorn app.main:app --reload
   ```

3. Start the web app:

   ```powershell
   cd web
   npm install
   npm run dev
   ```

4. Run Flutter with Supabase and API values:

   ```powershell
   cd app
   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=GUARDIAN_API_URL=http://10.0.2.2:8000 --dart-define=GUARDIAN_WEB_URL=http://10.0.2.2:5173
   ```

## Environment setup

Create `backend/.env` locally from `backend/.env.example`. Never commit this file or paste secret values into chat.

| Variable | Value |
|---|---|
| `DATABASE_URL` | Supabase Postgres connection string from **Project Settings → Database → Connection string**. Keep it backend-only; when set, it takes precedence over local SQLite. |
| `DATABASE_PATH` | Local SQLite fallback path used only when `DATABASE_URL` is blank. |
| `SUPABASE_JWT_SECRET` | Legacy HS256 projects only: Supabase Dashboard → Project Settings → API → JWT Secret. Do not use the anon/publishable key. |
| `SUPABASE_JWT_ISSUER` | Usually `https://<project-ref>.supabase.co/auth/v1`; leave blank if your Supabase JWT setup does not require issuer validation. |
| `SUPABASE_JWT_AUDIENCE` | Usually `authenticated`; leave blank only if your project does not include an audience claim. |
| `SUPABASE_JWKS_URL` | For ES256/RS256 projects: `https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json`. The backend derives this from the issuer when left blank. |
| `PAYPAL_CLIENT_ID` | PayPal Developer Dashboard in **Sandbox** → Apps & Credentials → REST API apps → your app → Client ID. |
| `PAYPAL_CLIENT_SECRET` | The matching **Sandbox** secret from the same PayPal REST API app. Keep it backend-only. |
| `PAYPAL_BASE_URL` | `https://api-m.sandbox.paypal.com` |
| `DEMO_MODE` | `true` for the reliable labeled demo seed; `false` only after PayPal sandbox credentials and subscription mapping are ready. |
| `WEB_ORIGIN` | The exact web origin; use comma-separated origins for desktop and phone testing, for example `http://localhost:5173,http://10.97.76.65:5173`. |
| `LLM_API_KEY` | Google AI Studio/Gemini API key. Keep it backend-only. |
| `LLM_PROVIDER` | `gemini` |
| `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta` |
| `LLM_MODEL` | `gemini-3.5-flash-lite` |

The attached PayPal screenshot shows the correct **Sandbox REST API app** area. The visible Client ID belongs in `PAYPAL_CLIENT_ID`; reveal/copy the matching Secret into `PAYPAL_CLIENT_SECRET`. Do not use Live credentials, and do not put either PayPal value in Flutter or the web app.

For Render, set `DATABASE_URL` to the Supabase Postgres connection string and leave `DATABASE_PATH` as `guardian.db`. The API creates its tables on first connection, so no Render disk is required. Use the Supabase connection pooler string when the direct database connection is not reachable from the deployment environment.

For Flutter, pass only public Supabase configuration and local URLs:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key> `
  --dart-define=GUARDIAN_API_URL=http://10.0.2.2:8000 `
  --dart-define=GUARDIAN_WEB_URL=http://10.0.2.2:5173
```

If the app displays “Supabase is not configured”, stop the current Flutter run and launch it with those `--dart-define` values. Flutter compile-time defines are not loaded from `backend/.env`.

For a physical Android device, replace `10.0.2.2` with the computer's LAN IP and make sure the phone and computer are on the same network. The Supabase publishable/anon key is intended for the client; the JWT secret, PayPal secret, and Gemini key are not.

## Sandbox and demo data

`scripts/seed_sandbox.py` creates five idempotently mapped PayPal sandbox products and monthly plans when credentials are configured. The real flow is `POST /api/paypal/plans` → `POST /api/paypal/subscribe` → sandbox approval → `/api/paypal/return` → `/api/sync`; transaction history uses each subscription's billing-transactions endpoint. It never silently substitutes demo data. For a reliable demo without PayPal credentials, set `DEMO_MODE=true`; the API creates clearly labeled `demo_seed` rows for the authenticated user. Never present those rows as PayPal success.

## Tools used

PayPal Subscriptions and Transaction APIs, PayPal webhook verification, the APIMatic PayPal Server SDK context/plugin where available, Supabase JWT authentication, FastAPI, Flutter, React/TypeScript, AG Grid Community, Recharts, and Render.

## LLM configuration

The default provider is Google Gemini `gemini-3.5-flash-lite`, selected for low-latency, low-cost structured JSON explanations. Guardian computes findings and savings deterministically first; the model only rewrites the explanation and cannot cancel or make payment calls. Every response is schema-validated, and missing/invalid LLM responses use the deterministic explanation.

Set `LLM_PROVIDER=gemini`, `LLM_API_KEY`, and `LLM_MODEL=gemini-3.5-flash-lite`. An OpenAI-compatible provider can be used by changing `LLM_PROVIDER`, `LLM_BASE_URL`, and `LLM_MODEL`.