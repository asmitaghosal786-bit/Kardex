 # Kardex

 Kardex is an Android subscription intelligence app that helps people understand recurring spending, compare subscription costs with real or manually entered usage, and review cancellation recommendations. PayPal Sandbox status and webhooks are used to verify subscription changes before the app reports them as complete.

## Integration overview

This repository contains an Android Flutter client, a FastAPI backend, and a React/TypeScript web explorer. The following services and libraries have distinct responsibilities:

- **Flutter Android app**: The app is Android-only. Supabase Auth handles user sign-in, while the Android `UsageStatsManager` integration collects foreground minutes, launch counts, and last-used timestamps only after the user grants Usage Access consent. The client sends its Supabase JWT to the backend and supports measured usage plus manual entry.
- **PayPal Sandbox**: The backend uses PayPal's REST Subscriptions and Billing Transactions APIs through `backend/app/paypal.py`. `scripts/seed_sandbox.py` creates six active USD monthly Sandbox plans (Spotify, JioHotstar, Netflix, Google Drive, YouTube, and ChatGPT) and stores their PayPal IDs plus Android package mappings in Supabase. Users approve subscriptions on PayPal's Sandbox page; the backend verifies the subscription, imports billing transactions, and verifies cancellation through a PayPal GET or webhook before reporting success. PayPal secrets stay in the backend.
- **Google AI Studio/Gemini**: Gemini is called server-side by FastAPI using `LLM_API_KEY`, `LLM_BASE_URL`, and `LLM_MODEL`. The browser and Flutter app never receive the Gemini key. Guardian computes findings and allowed data first; Gemini returns schema-validated explanations or read-only Spending Explorer actions. Invalid or unavailable model responses fall back to deterministic behavior.
- **AG Grid Community and AG Studio**: The web app always has an AG Grid Community + Recharts fallback. When `VITE_AG_STUDIO_ENABLED=true` and a valid `VITE_AG_LICENSE` are supplied, the Spending Explorer uses the installed `ag-studio` and `ag-studio-react` 3.1 packages with a custom theme, widgets, datasource, and agent harness. The Studio agent adapter sends questions to `POST /api/agent/chat`; it does not call Gemini directly and has no PayPal, payment, or cancellation tools. Transaction Explorer remains a Community grid.
- **Render and Supabase**: Render hosts the FastAPI service and the Vite static web build. Supabase provides authentication and production Postgres storage through `DATABASE_URL`; local SQLite remains available when that variable is blank. Render Free does not need a persistent disk because the production database is external.
- **APIMatic PayPal SDK**: The installed APIMatic PayPal Python SDK documentation/skills were used to verify PayPal SDK conventions and testing patterns. The current backend runtime intentionally uses direct `httpx` REST calls, so the APIMatic SDK is not a production dependency in `backend/requirements.txt`.

## Architecture

- `app/`: Android-only Flutter mobile client. Supabase supplies authentication; the client sends the Supabase JWT to the API.
- `backend/`: FastAPI service with user-scoped SQLite fallback and Supabase Postgres support.
- `web/`: Vite + React report surfaces at `/transactions` and `/spending`. A one-time code is exchanged for a short-lived web session; JWTs are never put in URLs. Spending Explorer uses AG Studio when enabled, otherwise it uses the explicit AG Grid Community + Recharts fallback.
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
| `PAYPAL_WEBHOOK_ID` | The ID of the PayPal Sandbox webhook configured for `https://<api-host>/api/webhooks/paypal`. |
| `PAYPAL_BASE_URL` | `https://api-m.sandbox.paypal.com` |
| `API_PUBLIC_URL` | Public Render URL of the backend, used for PayPal return and cancel URLs. |
| `DEMO_MODE` | `true` for the reliable labeled demo seed; `false` only after PayPal sandbox credentials and subscription mapping are ready. |
| `WEB_ORIGIN` | The exact web origin; use comma-separated origins for desktop and phone testing, for example `http://localhost:5173,http://10.97.76.65:5173`. |
| `LLM_API_KEY` | Google AI Studio/Gemini API key. Keep it backend-only. |
| `LLM_PROVIDER` | `gemini` |
| `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta` |
| `LLM_MODEL` | `gemini-3.5-flash-lite` |

The attached PayPal screenshot shows the correct **Sandbox REST API app** area. The visible Client ID belongs in `PAYPAL_CLIENT_ID`; reveal/copy the matching Secret into `PAYPAL_CLIENT_SECRET`. Do not use Live credentials, and do not put either PayPal value in Flutter or the web app.

For Render, set `DATABASE_URL` to the Supabase Postgres connection string. `DATABASE_PATH` is only a local SQLite fallback and is not required on Render. The API creates its tables on first connection, so no Render disk is required. Use the Supabase connection pooler string when the direct database connection is not reachable from the deployment environment.

For the static web service, set `VITE_API_URL` to the public backend URL, set `VITE_AG_STUDIO_ENABLED=true` to enable Studio, and set `VITE_AG_LICENSE` to the browser-safe AG Studio license/trial key. These Vite values are embedded in the web build; PayPal and Gemini secrets must never be placed in them.

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

`scripts/seed_sandbox.py` creates six idempotently mapped PayPal sandbox products and USD monthly plans when credentials are configured. It writes the PayPal IDs and Android package mappings to the configured database and never silently substitutes demo data. Run it locally from `backend` with `DATABASE_URL` pointing to Supabase when Render Shell is unavailable.

The real flow is `POST /api/paypal/plans` → `POST /api/paypal/subscribe` → Sandbox buyer approval → `/api/paypal/return` → `/api/sync`; transaction history uses each subscription's billing-transactions endpoint. Webhook events are signature-verified and de-duplicated. For a reliable demo without PayPal credentials, set `DEMO_MODE=true`; the API creates clearly labeled `demo_seed` rows for the authenticated user. Never present those rows as PayPal success.

## Tools used

PayPal Subscriptions and Billing Transactions APIs, PayPal webhook verification, Supabase Auth/Postgres, FastAPI, Flutter Android Usage Access, React/TypeScript, AG Grid Community, AG Studio 3.1, Recharts, Gemini, and Render. APIMatic is used as the PayPal SDK documentation/testing context; direct REST is the runtime implementation.

## LLM configuration

The default provider is Google Gemini `gemini-3.5-flash-lite`, selected for low-latency, low-cost structured JSON explanations. Guardian computes findings and savings deterministically first; the model only rewrites explanations or returns allowlisted read-only explorer actions. It cannot cancel subscriptions, make payments, or call PayPal tools. Every response is schema-validated, and missing/invalid LLM responses use the deterministic fallback.

Set `LLM_PROVIDER=gemini`, `LLM_API_KEY`, and `LLM_MODEL=gemini-3.5-flash-lite`. An OpenAI-compatible provider can be used by changing `LLM_PROVIDER`, `LLM_BASE_URL`, and `LLM_MODEL`.