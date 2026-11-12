"""Create a small PayPal sandbox fixture when credentials are available.

With DEMO_MODE=true the application uses clearly labeled demo_seed rows instead.
This script intentionally does not silently fall back to demo data.
"""

import asyncio
import os
import sys
import json
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.paypal import PayPalClient
from app.db import connection, now


async def main() -> None:
    client = PayPalClient()
    mapping = json.loads((Path(__file__).parent.parent / "config" / "plan_packages.json").read_text())
    with connection() as conn:
        existing = {row["name"]: row["id"] for row in conn.execute("SELECT id, name FROM plans")}
    for item in mapping:
        if item["name"] in existing:
            print(f"Existing sandbox plan {existing[item['name']]}")
            continue
        product = await client.request("POST", "/v1/catalogs/products",
            json={"name": item["name"], "type": "SERVICE", "category": "SOFTWARE"})
        plan = await client.request("POST", "/v1/billing/plans", json={
            "product_id": product["id"], "name": item["name"],
            "billing_cycles": [{"frequency": {"interval_unit": "MONTH", "interval_count": 1},
                "tenure_type": "REGULAR", "sequence": 1, "total_cycles": 0,
                "pricing_scheme": {"fixed_price": {"value": str(item["amount"]), "currency_code": "USD"}}}],
            "payment_preferences": {"auto_bill_outstanding": True, "payment_failure_threshold": 1},
        })
        plan_status = str(plan.get("status", "")).upper()
        if plan_status in {"CREATED", "INACTIVE"}:
            await client.request("POST", f"/v1/billing/plans/{plan['id']}/activate")
        elif plan_status != "ACTIVE":
            raise RuntimeError(f"PayPal returned an unexpected plan status: {plan_status or 'missing'}")
        with connection() as conn:
            conn.execute("""INSERT INTO plans
                (id,product_id,name,amount,currency,interval,android_package,status,data_origin,created_at,updated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
                         (plan["id"], product["id"], item["name"], item["amount"], "USD", "MONTH",
                          item["android_package"], "ACTIVE", "paypal_sandbox", now(), now()))
        print(f"Created sandbox product {product['id']} and plan {plan['id']}")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as exc:
        print(f"Sandbox seeding failed: {exc}", file=sys.stderr)
        print("No demo fallback was performed. Set PAYPAL_CLIENT_ID/SECRET first.", file=sys.stderr)
        raise

