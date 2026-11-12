import hashlib
import json
import secrets
import sqlite3
from urllib.parse import urlencode
from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from psycopg.errors import UniqueViolation
from fastapi import Depends, FastAPI, Header, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .auth import current_user
from .config import get_settings
from .db import connection, now
from .guardian import analyze, health_score
from .llm import agent_answer, explain
from .paypal import PayPalClient

app = FastAPI(title="Kardex API", version="0.1.0")
settings = get_settings()
web_origins = [origin.strip() for origin in settings.web_origin.split(",") if origin.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=web_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class UsageInput(BaseModel):
    subscription_id: str | None = None
    merchant: str | None = None
    android_package: str | None = None
    usage_minutes: float = Field(ge=0)
    period_start: str
    period_end: str
    source: str = "manual"


class ChatInput(BaseModel):
    message: str = Field(min_length=1, max_length=1000)


class WebSessionCode(BaseModel):
    code: str = Field(min_length=16, max_length=256)


class SubscribeInput(BaseModel):
    plan_id: str = Field(min_length=1, max_length=128)


def rows(conn: Any, query: str, args: tuple[Any, ...]) -> list[dict[str, Any]]:
    return [dict(row) for row in conn.execute(query, args).fetchall()]


def seed_if_needed(user_id: str) -> None:
    if not settings.demo_mode:
        return
    with connection() as conn:
        if conn.execute("SELECT 1 FROM subscriptions WHERE user_id = ? LIMIT 1", (user_id,)).fetchone():
            return
        stamp = now()
        user_seed = hashlib.sha256(user_id.encode()).hexdigest()[:12]
        seed = [
            (f"demo-{user_seed}-dropbox", "Dropbox Plus", "Cloud storage", 9.99, "USD", "MONTH", "Needs review"),
            (f"demo-{user_seed}-spotify", "Spotify", "Music", 11.99, "USD", "MONTH", "Active"),
            (f"demo-{user_seed}-youtube", "YouTube Premium", "Streaming", 14.99, "USD", "MONTH", "Active"),
        ]
        for sid, merchant, category, amount, currency, interval, status in seed:
            conn.execute(
                """INSERT INTO subscriptions
                (id,user_id,provider_id,merchant,plan_name,category,amount,currency,interval,
                 next_billing_at,status,data_origin,created_at,updated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (sid, user_id, None, merchant, merchant, category, amount, currency, interval,
                 (datetime.now(timezone.utc) + timedelta(days=5)).isoformat(), status,
                 "demo_seed", stamp, stamp),
            )
            conn.execute(
                """INSERT INTO transactions
                (id,user_id,provider_id,merchant,amount,currency,occurred_at,status,category,subscription_id,data_origin)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
                (f"txn-{sid}", user_id, None, merchant, amount, currency, stamp[:10], "COMPLETED",
                 category, sid, "demo_seed"),
            )
        conn.execute(
            """INSERT INTO usage_stats
            (id,user_id,subscription_id,merchant,usage_minutes,period_start,period_end,source,data_origin,created_at)
            VALUES (?,?,?,?,?,?,?,?,?,?)""",
            (f"usage-{user_seed}-dropbox", user_id, f"demo-{user_seed}-dropbox", "Dropbox Plus", 12, "2026-11-01", "2026-11-10",
             "measured", "demo_seed", stamp),
        )


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/subscriptions")
async def subscriptions(user_id: str = Depends(current_user)) -> list[dict[str, Any]]:
    seed_if_needed(user_id)
    with connection() as conn:
        return rows(conn, "SELECT * FROM subscriptions WHERE user_id = ? ORDER BY next_billing_at", (user_id,))


@app.get("/api/recommendations")
async def recommendations(user_id: str = Depends(current_user)) -> list[dict[str, Any]]:
    seed_if_needed(user_id)
    with connection() as conn:
        subs = rows(conn, "SELECT * FROM subscriptions WHERE user_id = ?", (user_id,))
        usage = rows(conn, "SELECT * FROM usage_stats WHERE user_id = ?", (user_id,))
        findings = analyze(subs, usage)
        result = []
        for finding in findings:
            rid = f"rec-{finding['subscription_id']}-{finding['kind']}"
            conn.execute(
                """INSERT INTO recommendations
                (id,user_id,subscription_id,kind,status,title,finding_json,data_origin,created_at,updated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?)
                ON CONFLICT(id) DO NOTHING""",
                (rid, user_id, finding["subscription_id"], finding["kind"], "open", finding["title"],
                 json.dumps(finding), "demo_seed" if settings.demo_mode else "measured", now(), now()),
            )
            stored = conn.execute(
                "SELECT status, finding_json, data_origin FROM recommendations WHERE id = ?",
                (rid,),
            ).fetchone()
            explanation = json.loads(stored["finding_json"]) if stored else finding
            if "explanation_origin" not in explanation:
                explanation = {**finding, **await explain(finding)}
                conn.execute(
                    "UPDATE recommendations SET finding_json = ?, updated_at = ? WHERE id = ?",
                    (json.dumps(explanation), now(), rid),
                )
            result.append({**explanation, "id": rid, "status": stored["status"] if stored else "open",
                           "data_origin": stored["data_origin"] if stored else "measured"})
        return result


@app.get("/api/dashboard")
async def dashboard(user_id: str = Depends(current_user)) -> dict[str, Any]:
    subs = await subscriptions(user_id)
    recs = await recommendations(user_id)
    monthly = sum(s["amount"] / 12 if s["interval"] == "YEAR" else s["amount"] for s in subs)
    savings = sum(r["estimated_savings"] for r in recs if r["kind"] == "underuse")
    return {"monthly_cost": monthly, "annual_cost": monthly * 12, "projected_savings": savings,
            "health": health_score(subs, recs), "subscriptions": subs, "recommendations": recs}


@app.get("/api/reports/transactions")
async def report_transactions(
    search: str = "",
    provider: str | None = None,
    status: str | None = None,
    sort: str = "occurred_at",
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    user_id: str = Depends(current_user),
) -> dict[str, Any]:
    allowed_sort = {"occurred_at", "merchant", "amount", "status"}
    order = sort if sort in allowed_sort else "occurred_at"
    with connection() as conn:
        where = ["user_id = ?", "merchant LIKE ?"]
        args: list[Any] = [user_id, f"%{search}%"]
        if provider:
            where.append("provider_id = ?")
            args.append(provider)
        if status:
            where.append("status = ?")
            args.append(status)
        clause = " AND ".join(where)
        total = conn.execute(f"SELECT COUNT(*) AS count FROM transactions WHERE {clause}", tuple(args)).fetchone()["count"]
        args.extend([(page - 1) * page_size, page_size])
        items = rows(conn, f"SELECT * FROM transactions WHERE {clause} ORDER BY {order} DESC LIMIT ? OFFSET ?", tuple(args))
        return {"items": items, "page": page, "page_size": page_size, "total": total}


@app.get("/api/reports/spending-rows")
async def spending_rows(user_id: str = Depends(current_user)) -> list[dict[str, Any]]:
    with connection() as conn:
        return rows(conn, """SELECT s.id, s.merchant, s.category, s.amount, s.currency, s.interval,
          s.status, s.next_billing_at, s.data_origin,
          COALESCE(u.usage_minutes, 0) AS usage_minutes
          FROM subscriptions s LEFT JOIN usage_stats u ON u.subscription_id = s.id
          WHERE s.user_id = ? ORDER BY s.amount DESC""", (user_id,))


@app.post("/api/usage")
async def add_usage(payload: UsageInput, user_id: str = Depends(current_user)) -> dict[str, Any]:
    usage_id = f"usage-{secrets.token_urlsafe(12)}"
    origin = "measured" if payload.source == "measured" else "manual"
    with connection() as conn:
        subscription_id = payload.subscription_id
        merchant = payload.merchant
        if payload.android_package:
            mapped = conn.execute(
                """SELECT s.id, s.merchant FROM subscriptions s JOIN plans p ON p.name = s.plan_name
                   WHERE s.user_id = ? AND p.android_package = ? LIMIT 1""",
                (user_id, payload.android_package),
            ).fetchone()
            if mapped:
                subscription_id, merchant = mapped["id"], mapped["merchant"]
        conn.execute("""INSERT INTO usage_stats
          (id,user_id,subscription_id,merchant,usage_minutes,period_start,period_end,source,data_origin,created_at)
          VALUES (?,?,?,?,?,?,?,?,?,?)""",
                     (usage_id, user_id, subscription_id, merchant, payload.usage_minutes,
                      payload.period_start, payload.period_end, payload.source, origin, now()))
    return {"id": usage_id, **payload.model_dump(), "data_origin": origin}


@app.post("/api/sync")
async def sync(user_id: str = Depends(current_user)) -> dict[str, Any]:
    if settings.demo_mode:
        seed_if_needed(user_id)
        return {"status": "completed", "data_origin": "demo_seed", "message": "Demo seed is enabled; no PayPal call was made."}
    if not settings.paypal_client_id or not settings.paypal_client_secret:
        raise HTTPException(status_code=503, detail="PayPal sandbox credentials are not configured")
    client = PayPalClient()
    with connection() as conn:
        mapped = [row["provider_id"] for row in conn.execute(
            "SELECT provider_id FROM subscriptions WHERE user_id = ? AND provider_id IS NOT NULL", (user_id,)
        ).fetchall()]
    for provider_id in mapped:
        remote = await client.get_subscription(provider_id)
        with connection() as conn:
            conn.execute("UPDATE subscriptions SET status = ?, next_billing_at = ?, updated_at = ? WHERE provider_id = ? AND user_id = ?",
                         (remote.get("status", "UNKNOWN"), remote.get("billing_info", {}).get("next_billing_time"),
                          now(), provider_id, user_id))
    imported = await client.sync_transactions(user_id)
    return {"status": "completed", "imported_transactions": imported, "data_origin": "paypal_sandbox"}


@app.post("/api/paypal/plans")
async def paypal_plans(user_id: str = Depends(current_user)) -> list[dict[str, Any]]:
    del user_id
    if settings.demo_mode:
        return []
    plans = await PayPalClient().list_plans()
    with connection() as conn:
        local = {row["id"]: dict(row) for row in conn.execute("SELECT * FROM plans WHERE status = 'ACTIVE'")}
    result = []
    for plan in plans:
        local_plan = local.get(plan.get("id"))
        if local_plan:
            result.append({**plan, "android_package": local_plan["android_package"], "data_origin": "paypal_sandbox"})
    return result


@app.post("/api/paypal/subscribe")
async def paypal_subscribe(payload: SubscribeInput, user_id: str = Depends(current_user)) -> dict[str, str]:
    if settings.demo_mode:
        raise HTTPException(status_code=409, detail="Demo data is enabled; real PayPal is not connected")
    with connection() as conn:
        plan = conn.execute("SELECT id FROM plans WHERE id = ? AND status = 'ACTIVE'", (payload.plan_id,)).fetchone()
    if not plan:
        raise HTTPException(status_code=404, detail="Sandbox plan is not available")
    state = secrets.token_urlsafe(32)
    query = urlencode({"state": state})
    created = await PayPalClient().create_subscription(
        payload.plan_id, f"{settings.api_public_url}/api/paypal/return?{query}",
        f"{settings.api_public_url}/api/paypal/return?{query}&cancelled=1",
    )
    subscription_id = created.get("id")
    if not subscription_id:
        raise HTTPException(status_code=502, detail="PayPal did not return a subscription id")
    with connection() as conn:
        conn.execute(
            "INSERT INTO pending_connections VALUES (?,?,?,?,?,?)",
            (state, user_id, subscription_id, payload.plan_id, now(),
             (datetime.now(timezone.utc) + timedelta(minutes=30)).isoformat()),
        )
    approve = next((link["href"] for link in created.get("links", []) if link.get("rel") == "approve"), None)
    if not approve:
        raise HTTPException(status_code=502, detail="PayPal did not return an approval link")
    return {"approve_url": approve, "subscription_id": subscription_id, "status": "pending"}


@app.get("/api/paypal/return")
async def paypal_return(state: str = Query(...), subscription_id: str | None = Query(None),
                        cancelled: int = Query(0)) -> dict[str, Any]:
    with connection() as conn:
        pending = conn.execute(
            "SELECT * FROM pending_connections WHERE state = ? AND expires_at > ?",
            (state, now()),
        ).fetchone()
    if not pending or (subscription_id and subscription_id != pending["subscription_id"]):
        raise HTTPException(status_code=400, detail="PayPal connection state is invalid or expired")
    if cancelled:
        return {"status": "cancelled", "data_origin": "paypal_sandbox"}
    remote = await PayPalClient().get_subscription(pending["subscription_id"])
    if remote.get("status") not in {"ACTIVE", "APPROVED"}:
        raise HTTPException(status_code=409, detail="PayPal approval is not active yet")
    with connection() as conn:
        plan = conn.execute("SELECT * FROM plans WHERE id = ?", (pending["plan_id"],)).fetchone()
        if not plan:
            raise HTTPException(status_code=404, detail="Sandbox plan mapping is missing")
        stamp = now()
        conn.execute(
            """INSERT INTO subscriptions
            (id,user_id,provider_id,merchant,plan_name,category,amount,currency,interval,next_billing_at,status,data_origin,created_at,updated_at)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ON CONFLICT(id) DO UPDATE SET status=excluded.status, next_billing_at=excluded.next_billing_at, updated_at=excluded.updated_at""",
            (f"paypal-{pending['subscription_id']}", pending["user_id"], pending["subscription_id"],
             plan["name"], plan["name"], "Subscription", plan["amount"], plan["currency"],
             plan["interval"], remote.get("billing_info", {}).get("next_billing_time"),
             remote.get("status"), "paypal_sandbox", stamp, stamp),
        )
        conn.execute("DELETE FROM pending_connections WHERE state = ?", (state,))
    return {"status": remote["status"], "subscription_id": pending["subscription_id"], "data_origin": "paypal_sandbox"}


@app.get("/api/recommendations/{recommendation_id}")
async def recommendation_status(recommendation_id: str, user_id: str = Depends(current_user)) -> dict[str, Any]:
    with connection() as conn:
        recommendation = conn.execute(
            "SELECT * FROM recommendations WHERE id = ? AND user_id = ?",
            (recommendation_id, user_id),
        ).fetchone()
        if not recommendation:
            raise HTTPException(status_code=404, detail="Recommendation not found")
        status = recommendation["status"]
        if status == "pending_verification":
            subscription = conn.execute(
                "SELECT provider_id FROM subscriptions WHERE id = ? AND user_id = ?",
                (recommendation["subscription_id"], user_id),
            ).fetchone()
            if subscription and subscription["provider_id"] and settings.paypal_client_id:
                remote = await PayPalClient().get_subscription(subscription["provider_id"])
                if remote.get("status") == "CANCELLED":
                    conn.execute(
                        "UPDATE recommendations SET status = 'verified', updated_at = ? WHERE id = ?",
                        (now(), recommendation_id),
                    )
                    status = "verified"
        result = dict(recommendation)
        result["status"] = status
        result["finding"] = json.loads(result.pop("finding_json"))
        return result


@app.post("/api/recommendations/{recommendation_id}/approve")
async def approve(recommendation_id: str, user_id: str = Depends(current_user)) -> dict[str, str]:
    with connection() as conn:
        rec = conn.execute("SELECT * FROM recommendations WHERE id = ? AND user_id = ?", (recommendation_id, user_id)).fetchone()
        if not rec:
            raise HTTPException(status_code=404, detail="Recommendation not found")
        sub = conn.execute("SELECT * FROM subscriptions WHERE id = ?", (rec["subscription_id"],)).fetchone()
        if not sub or not sub["provider_id"]:
            raise HTTPException(status_code=409, detail="No PayPal subscription id is available for this recommendation")
    try:
        await PayPalClient().cancel_subscription(sub["provider_id"], "Cancelled from Kardex after user approval")
    except Exception as exc:
        raise HTTPException(status_code=502, detail="PayPal cancellation request failed") from exc
    with connection() as conn:
        conn.execute("UPDATE recommendations SET status = 'pending_verification', updated_at = ? WHERE id = ?", (now(), recommendation_id))
        conn.execute("INSERT INTO action_log VALUES (?,?,?,?,?,?)",
                     (secrets.token_urlsafe(12), user_id, "approve_cancel", recommendation_id, "{}", now()))
    return {"id": recommendation_id, "status": "pending_verification"}


@app.post("/api/recommendations/{recommendation_id}/reject")
async def reject(recommendation_id: str, user_id: str = Depends(current_user)) -> dict[str, str]:
    with connection() as conn:
        updated = conn.execute("UPDATE recommendations SET status = 'rejected', updated_at = ? WHERE id = ? AND user_id = ?",
                               (now(), recommendation_id, user_id)).rowcount
        if not updated:
            raise HTTPException(status_code=404, detail="Recommendation not found")
        conn.execute("INSERT INTO action_log VALUES (?,?,?,?,?,?)",
                     (secrets.token_urlsafe(12), user_id, "reject_recommendation", recommendation_id, "{}", now()))
    return {"id": recommendation_id, "status": "rejected"}


@app.post("/api/agent/chat")
async def agent_chat(payload: ChatInput, user_id: str = Depends(current_user)) -> dict[str, Any]:
    with connection() as conn:
        data = rows(conn, """SELECT s.merchant, s.amount, s.currency, s.category, s.interval, s.status,
          COALESCE(u.usage_minutes, 0) AS usage_minutes FROM subscriptions s
          LEFT JOIN usage_stats u ON u.subscription_id = s.id WHERE s.user_id = ?""", (user_id,))
    result = await agent_answer(payload.message, data)
    return {**result, "read_only": True, "data_origin": "measured" if not settings.demo_mode else "demo_seed"}


@app.post("/api/web-session")
async def create_web_session(user_id: str = Depends(current_user)) -> dict[str, Any]:
    raw_code = secrets.token_urlsafe(32)
    with connection() as conn:
        conn.execute("INSERT INTO web_sessions VALUES (?,?,?,?,?)",
                     (hashlib.sha256(raw_code.encode()).hexdigest(), user_id,
                      (datetime.now(timezone.utc) + timedelta(minutes=5)).isoformat(), None, now()))
    return {"code": raw_code, "expires_in_seconds": 300}


@app.post("/api/web-session/exchange")
async def exchange_web_session(payload: WebSessionCode) -> dict[str, Any]:
    code_hash = hashlib.sha256(payload.code.encode()).hexdigest()
    with connection() as conn:
        session = conn.execute("SELECT * FROM web_sessions WHERE code_hash = ?", (code_hash,)).fetchone()
        if not session or session["used_at"] or datetime.fromisoformat(session["expires_at"]) <= datetime.now(timezone.utc):
            raise HTTPException(status_code=401, detail="Web session code is invalid or expired")
        conn.execute("UPDATE web_sessions SET used_at = ? WHERE code_hash = ?", (now(), code_hash))
    session_secret = settings.web_session_secret or settings.supabase_jwt_secret
    if not session_secret:
        raise HTTPException(status_code=500, detail="WEB_SESSION_SECRET is not configured")
    claims = {
        "sub": session["user_id"],
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + timedelta(minutes=15),
    }
    if settings.supabase_jwt_issuer:
        claims["iss"] = settings.supabase_jwt_issuer
    if settings.supabase_jwt_audience:
        claims["aud"] = settings.supabase_jwt_audience
    session_token = jwt.encode(
        claims,
        session_secret,
        algorithm="HS256",
    )
    return {"session_token": session_token, "user_id": session["user_id"], "expires_in_seconds": 900}


@app.post("/api/webhooks/paypal")
async def paypal_webhook(request: Request, paypal_auth_algo: str | None = Header(None),
                         paypal_cert_url: str | None = Header(None),
                         paypal_transmission_id: str | None = Header(None),
                         paypal_transmission_sig: str | None = Header(None),
                         paypal_transmission_time: str | None = Header(None),
                         paypal_webhook_id: str | None = Header(None)) -> dict[str, str]:
    event = await request.json()
    event_id = event.get("id")
    if not event_id:
        raise HTTPException(status_code=400, detail="Webhook event id is required")
    if not settings.demo_mode:
        verified = await PayPalClient().verify_webhook(
            {"paypal-auth-algo": paypal_auth_algo or "", "paypal-cert-url": paypal_cert_url or "",
             "paypal-transmission-id": paypal_transmission_id or "", "paypal-transmission-sig": paypal_transmission_sig or "",
             "paypal-transmission-time": paypal_transmission_time or "", "paypal-webhook-id": paypal_webhook_id or ""}, event)
        if not verified:
            raise HTTPException(status_code=400, detail="Webhook signature verification failed")
    with connection() as conn:
        try:
            conn.execute("INSERT INTO webhook_events VALUES (?,?,?,?,?)",
                         (secrets.token_urlsafe(12), event_id, event.get("event_type", ""), json.dumps(event), now()))
        except (sqlite3.IntegrityError, UniqueViolation):
            return {"status": "already_processed"}
        resource = event.get("resource", {})
        event_type = event.get("event_type")
        provider_id = resource.get("billing_agreement_id") or resource.get("id")
        status_by_event = {
            "BILLING.SUBSCRIPTION.ACTIVATED": "ACTIVE",
            "BILLING.SUBSCRIPTION.CANCELLED": "CANCELLED",
            "BILLING.SUBSCRIPTION.SUSPENDED": "SUSPENDED",
            "PAYMENT.SALE.COMPLETED": "ACTIVE",
            "PAYMENT.SALE.DENIED": "PAYMENT_FAILED",
            "BILLING.SUBSCRIPTION.PAYMENT.FAILED": "PAYMENT_FAILED",
        }
        if provider_id and event_type in status_by_event:
            conn.execute("UPDATE subscriptions SET status = ?, updated_at = ? WHERE provider_id = ?",
                         (status_by_event[event_type], now(), provider_id))
        if provider_id and event_type == "BILLING.SUBSCRIPTION.CANCELLED":
            conn.execute(
                """UPDATE recommendations SET status = 'verified', updated_at = ?
                   WHERE subscription_id IN (SELECT id FROM subscriptions WHERE provider_id = ?)""",
                (now(), provider_id),
            )
        if event_type == "PAYMENT.SALE.COMPLETED" and provider_id:
            amount = resource.get("amount", {})
            sub = conn.execute("SELECT * FROM subscriptions WHERE provider_id = ?", (provider_id,)).fetchone()
            if sub:
                transaction_id = resource.get("sale_id") or event_id
                conn.execute(
                    """INSERT INTO transactions
                    (id,user_id,provider_id,merchant,amount,currency,occurred_at,status,category,subscription_id,data_origin)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?)
                    ON CONFLICT(id) DO UPDATE SET
                      user_id=excluded.user_id, provider_id=excluded.provider_id,
                      merchant=excluded.merchant, amount=excluded.amount,
                      currency=excluded.currency, occurred_at=excluded.occurred_at,
                      status=excluded.status, category=excluded.category,
                      subscription_id=excluded.subscription_id, data_origin=excluded.data_origin""",
                    (f"paypal-{transaction_id}", sub["user_id"], provider_id, sub["merchant"],
                     float(amount.get("total", amount.get("value", 0))), amount.get("currency", "USD"),
                     resource.get("update_time", now()), "COMPLETED", sub["category"], sub["id"], "paypal_sandbox"),
                )
    return {"status": "processed"}
