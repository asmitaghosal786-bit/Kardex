"""Walk the real PayPal sandbox flow without printing credentials."""

import asyncio
import os
import sys

import httpx


async def main() -> None:
    base = os.environ.get("GUARDIAN_API_URL", "http://localhost:8000")
    token = os.environ.get("SMOKE_JWT")
    if not token:
        raise SystemExit("Set SMOKE_JWT to a sandbox test user's JWT.")
    headers = {"Authorization": f"Bearer {token}"}
    async with httpx.AsyncClient(base_url=base, timeout=30) as client:
        plans_response = await client.post("/api/paypal/plans", headers=headers)
        plans_response.raise_for_status()
        plans = plans_response.json()
        if not plans:
            raise SystemExit("No sandbox plans found; run scripts/seed_sandbox.py first.")
        created = await client.post("/api/paypal/subscribe", headers=headers,
                                    json={"plan_id": plans[0]["id"]})
        created.raise_for_status()
        print(f"Approve URL: {created.json()['approve_url']}")
        print("Open the URL in a sandbox buyer browser, then press Enter to sync.")
        input()
        sync = await client.post("/api/sync", headers=headers)
        sync.raise_for_status()
        recommendations = await client.get("/api/recommendations", headers=headers)
        recommendations.raise_for_status()
        print(f"Sync: {sync.json()['imported_transactions']} transactions; "
              f"recommendations: {len(recommendations.json())}")


if __name__ == "__main__":
    asyncio.run(main())
