import asyncio
import unittest

from app.llm import explain


class LlmFallbackTests(unittest.TestCase):
    def test_missing_key_returns_deterministic_explanation(self):
        finding = {
            "what_detected": "Only 12 minutes were measured.",
            "supporting_data": {"usage_minutes": 12},
            "why_it_matters": "The plan may be underused.",
            "estimated_savings": 99,
            "action": "Review the plan.",
        }

        result = asyncio.run(explain(finding))

        self.assertEqual(result["explanation_origin"], "deterministic_fallback")
        self.assertEqual(result["estimated_savings"], 99)


if __name__ == "__main__":
    unittest.main()
