from datetime import datetime, timedelta, timezone
from typing import Any


def _money(amount: float, currency: str) -> str:
    return f"{currency} {amount:,.2f}"


def analyze(subscriptions: list[dict[str, Any]], usage: list[dict[str, Any]]) -> list[dict[str, Any]]:
    usage_by_subscription = {row["subscription_id"]: row for row in usage}
    findings: list[dict[str, Any]] = []
    now = datetime.now(timezone.utc)
    for sub in subscriptions:
        monthly = sub["amount"]
        if sub["interval"] == "YEAR":
            monthly = sub["amount"] / 12
        row = usage_by_subscription.get(sub["id"])
        if row and row["usage_minutes"] < 60:
            findings.append({
                "kind": "underuse",
                "subscription_id": sub["id"],
                "title": f"Review {sub['merchant']} usage",
                "what_detected": f"{sub['merchant']} has {row['usage_minutes']:.0f} measured minutes in the latest period.",
                "supporting_data": {"usage_minutes": row["usage_minutes"], "period": row["period_end"]},
                "why_it_matters": "The plan may be costing more than its recent observed use justifies.",
                "estimated_savings": monthly,
                "action": "Review the plan and cancel only if it no longer meets your needs.",
            })
        if sub.get("next_billing_at"):
            try:
                renewal = datetime.fromisoformat(sub["next_billing_at"])
                if renewal - now <= timedelta(days=7):
                    findings.append({
                        "kind": "upcoming_renewal",
                        "subscription_id": sub["id"],
                        "title": f"{sub['merchant']} renews soon",
                        "what_detected": f"Renewal is scheduled for {sub['next_billing_at']}.",
                        "supporting_data": {"next_billing_at": sub["next_billing_at"], "monthly_cost": monthly},
                        "why_it_matters": "You have a short window to review the charge before the next billing event.",
                        "estimated_savings": 0,
                        "action": "Review the subscription before renewal.",
                    })
            except ValueError:
                pass
    return findings


def health_score(subscriptions: list[dict[str, Any]], findings: list[dict[str, Any]]) -> dict[str, Any]:
    underuse_count = sum(f["kind"] == "underuse" for f in findings)
    score = max(0, min(100, 100 - underuse_count * 12))
    return {
        "score": score,
        "factors": [
            {"name": "Active subscriptions", "value": len(subscriptions), "impact": "context"},
            {"name": "Underuse findings", "value": underuse_count, "impact": "negative" if underuse_count else "none"},
        ],
    }

