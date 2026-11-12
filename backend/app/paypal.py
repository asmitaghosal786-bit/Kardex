from datetime import datetime, timedelta, timezone
from typing import Any

import httpx

from .config import get_settings

_cached_token: str | None = None
_cached_token_expires_at: datetime | None = None


class PayPalClient:
    async def _token(self) -> str:
        global _cached_token, _cached_token_expires_at
        settings = get_settings()
        if not settings.paypal_client_id or not settings.paypal_client_secret:
            raise RuntimeError("PayPal sandbox credentials are not configured")
        current_time = datetime.now(timezone.utc)
        if (
            _cached_token
            and _cached_token_expires_at
            and current_time < _cached_token_expires_at
        ):
            return _cached_token
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.post(
                f"{settings.paypal_base_url}/v1/oauth2/token",
                auth=(settings.paypal_client_id, settings.paypal_client_secret),
                data={"grant_type": "client_credentials"},
                headers={"Accept": "application/json", "Accept-Language": "en_US"},
            )
            response.raise_for_status()
            payload = response.json()
        _cached_token = payload["access_token"]
        expires_in = int(payload.get("expires_in", 300))
        _cached_token_expires_at = current_time + timedelta(seconds=max(expires_in - 60, 30))
        return _cached_token

    async def request(self, method: str, path: str, **kwargs: Any) -> dict[str, Any]:
        token = await self._token()
        settings = get_settings()
        headers = kwargs.pop("headers", {})
        headers["Authorization"] = f"Bearer {token}"
        headers["Content-Type"] = "application/json"
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.request(method, f"{settings.paypal_base_url}{path}", headers=headers, **kwargs)
            if response.is_error:
                detail = response.text[:1000]
                raise RuntimeError(f"PayPal API request failed ({response.status_code}): {detail}")
            return response.json() if response.content else {}

    async def get_subscription(self, provider_id: str) -> dict[str, Any]:
        return await self.request("GET", f"/v1/billing/subscriptions/{provider_id}")

    async def list_plans(self) -> list[dict[str, Any]]:
        payload = await self.request("GET", "/v1/billing/plans", params={"page_size": 20})
        return payload.get("plans", [])

    async def create_subscription(self, plan_id: str, return_url: str, cancel_url: str) -> dict[str, Any]:
        start_time = datetime.now(timezone.utc) + timedelta(minutes=1)
        return await self.request(
            "POST", "/v1/billing/subscriptions",
            json={
                "plan_id": plan_id,
                "start_time": start_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "quantity": "1",
                "application_context": {
                    "brand_name": "Kardex",
                    "shipping_preference": "NO_SHIPPING",
                    "user_action": "SUBSCRIBE_NOW",
                    "payment_method": {
                        "payer_selected": "PAYPAL",
                        "payee_preferred": "IMMEDIATE_PAYMENT_REQUIRED",
                    },
                    "return_url": return_url,
                    "cancel_url": cancel_url,
                },
            },
        )

    async def subscription_transactions(self, provider_id: str) -> list[dict[str, Any]]:
        end = datetime.now(timezone.utc)
        start = end - timedelta(days=365)
        payload = await self.request(
            "GET", f"/v1/billing/subscriptions/{provider_id}/transactions",
            params={
                "start_time": start.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "end_time": end.strftime("%Y-%m-%dT%H:%M:%SZ"),
            },
        )
        return payload.get("transactions", [])

    async def sync_transactions(self, user_id: str) -> int:
        """Import each mapped subscription's required billing transaction history."""
        from .db import connection, now

        imported = 0
        with connection() as conn:
            subscriptions = conn.execute(
                "SELECT id, provider_id, merchant, category FROM subscriptions WHERE user_id = ? AND provider_id IS NOT NULL",
                (user_id,),
            ).fetchall()
        for subscription in subscriptions:
            for item in await self.subscription_transactions(subscription["provider_id"]):
                transaction_id = item.get("id") or item.get("transaction_id")
                if not transaction_id:
                    continue
                amount = item.get("amount_with_breakdown", {}).get("gross_amount", item.get("amount", {}))
                with connection() as conn:
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
                        (f"paypal-{transaction_id}", user_id, subscription["provider_id"],
                         subscription["merchant"], float(amount.get("value", 0)),
                         amount.get("currency_code", "USD"), item.get("time", now()),
                         item.get("status", "COMPLETED"), subscription["category"],
                         subscription["id"], "paypal_sandbox"),
                    )
                imported += 1
        return imported

    async def cancel_subscription(self, provider_id: str, reason: str) -> None:
        await self.request("POST", f"/v1/billing/subscriptions/{provider_id}/cancel", json={"reason": reason})

    async def verify_webhook(self, headers: dict[str, str], event: dict[str, Any]) -> bool:
        settings = get_settings()
        payload = {
            "auth_algo": headers.get("paypal-auth-algo"),
            "cert_url": headers.get("paypal-cert-url"),
            "transmission_id": headers.get("paypal-transmission-id"),
            "transmission_sig": headers.get("paypal-transmission-sig"),
            "transmission_time": headers.get("paypal-transmission-time"),
            "webhook_id": settings.paypal_webhook_id,
            "webhook_event": event,
        }
        result = await self.request("POST", "/v1/notifications/verify-webhook-signature", json=payload)
        return result.get("verification_status") == "SUCCESS"
