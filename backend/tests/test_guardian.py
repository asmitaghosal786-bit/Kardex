import unittest

from app.guardian import analyze, health_score


class GuardianAnalysisTests(unittest.TestCase):
    def test_underuse_finding_contains_evidence_and_estimate(self):
        subscriptions = [{
            "id": "sub-1",
            "merchant": "Cloud Box",
            "amount": 100,
            "currency": "USD",
            "interval": "MONTH",
            "next_billing_at": None,
        }]
        usage = [{"subscription_id": "sub-1", "usage_minutes": 12, "period_end": "2026-11-10"}]

        findings = analyze(subscriptions, usage)

        self.assertEqual(findings[0]["kind"], "underuse")
        self.assertEqual(findings[0]["supporting_data"]["usage_minutes"], 12)
        self.assertEqual(findings[0]["estimated_savings"], 100)

    def test_health_score_exposes_factors(self):
        score = health_score([{"id": "sub-1"}], [{"kind": "underuse"}])

        self.assertEqual(score["score"], 88)
        self.assertTrue(score["factors"])


if __name__ == "__main__":
    unittest.main()
