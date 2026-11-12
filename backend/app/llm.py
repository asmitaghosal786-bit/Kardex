import json
import logging
from typing import Any

import httpx
from pydantic import BaseModel, ConfigDict, Field

from .config import get_settings

logger = logging.getLogger(__name__)


class Explanation(BaseModel):
    model_config = ConfigDict(extra="forbid")

    what_detected: str = Field(min_length=1, max_length=500)
    supporting_data: dict[str, Any]
    why_it_matters: str = Field(min_length=1, max_length=500)
    estimated_savings: float = Field(ge=0)
    action: str = Field(min_length=1, max_length=500)


class AgentAction(BaseModel):
    model_config = ConfigDict(extra="forbid")
    action: str
    field: str | None = None
    value: str | float | None = None
    direction: str | None = None


class AgentResult(BaseModel):
    model_config = ConfigDict(extra="forbid")
    answer: str = Field(min_length=1, max_length=1000)
    actions: list[AgentAction] = Field(default_factory=list, max_length=8)


async def explain(finding: dict[str, Any]) -> dict[str, Any]:
    """Ask the configured model to explain a finding; deterministic input remains authoritative."""
    settings = get_settings()
    fallback = Explanation(
        what_detected=finding["what_detected"],
        supporting_data=finding["supporting_data"],
        why_it_matters=finding["why_it_matters"],
        estimated_savings=finding["estimated_savings"],
        action=finding["action"],
    ).model_dump()
    if not settings.llm_api_key or not settings.llm_model:
        return {**fallback, "explanation_origin": "deterministic_fallback"}

    try:
        if settings.llm_provider.lower() == "gemini":
            result = await _gemini(finding)
        else:
            result = await _openai_compatible(finding)
        validated = Explanation.model_validate(result)
        validated.estimated_savings = fallback["estimated_savings"]
        validated.supporting_data = fallback["supporting_data"]
        return {**validated.model_dump(), "explanation_origin": "llm"}
    except Exception:
        logger.warning("LLM explanation failed; using deterministic explanation", exc_info=False)
        return {**fallback, "explanation_origin": "deterministic_fallback"}


async def _gemini(finding: dict[str, Any]) -> dict[str, Any]:
    settings = get_settings()
    schema = Explanation.model_json_schema()
    body = {
        "systemInstruction": {"parts": [{"text": (
            "Explain a subscription finding clearly and cautiously. "
            "Do not claim certainty, do not perform actions, and do not invent evidence."
        )}]},
        "contents": [{"role": "user", "parts": [{"text": json.dumps(finding)}]}],
        "generationConfig": {
            "temperature": 0.1,
            "responseMimeType": "application/json",
            "responseSchema": schema,
        },
    }
    async with httpx.AsyncClient(timeout=15) as client:
        response = await client.post(
            f"{settings.llm_base_url}/models/{settings.llm_model}:generateContent",
            params={"key": settings.llm_api_key},
            json=body,
        )
        response.raise_for_status()
        payload = response.json()
    text = payload["candidates"][0]["content"]["parts"][0]["text"]
    return json.loads(text)


async def _openai_compatible(finding: dict[str, Any]) -> dict[str, Any]:
    settings = get_settings()
    body = {
        "model": settings.llm_model,
        "temperature": 0.1,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": "Return only a cautious JSON explanation. Never perform actions or invent evidence."},
            {"role": "user", "content": json.dumps(finding)},
        ],
    }
    async with httpx.AsyncClient(timeout=15) as client:
        response = await client.post(
            f"{settings.llm_base_url.rstrip('/')}/chat/completions",
            headers={"Authorization": f"Bearer {settings.llm_api_key}"},
            json=body,
        )
        response.raise_for_status()
        payload = response.json()
    return json.loads(payload["choices"][0]["message"]["content"])


async def agent_answer(message: str, data: list[dict[str, Any]]) -> dict[str, Any]:
    """Return read-only, schema-validated explorer actions over the caller's rows."""
    fallback = _deterministic_agent(message, data)
    settings = get_settings()
    if not settings.llm_api_key or settings.llm_provider.lower() != "gemini":
        return {**fallback, "origin": "deterministic_fallback"}
    try:
        schema = AgentResult.model_json_schema()
        body = {
            "systemInstruction": {"parts": [{"text": (
                "You are a read-only spending explorer. Return only JSON matching the schema. "
                "Allowed actions: filter, sort, group, create_widget, modify_widget. "
                "Fields may only be merchant, category, amount, currency, interval, status, usage_minutes. "
                "Never return payment, cancellation, PayPal, network, or arbitrary code actions."
            )}]},
            "contents": [{"role": "user", "parts": [{"text": json.dumps({"question": message, "rows": data})}]}],
            "generationConfig": {"temperature": 0, "responseMimeType": "application/json", "responseSchema": schema},
        }
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(
                f"{settings.llm_base_url}/models/{settings.llm_model}:generateContent",
                params={"key": settings.llm_api_key}, json=body,
            )
            response.raise_for_status()
            text = response.json()["candidates"][0]["content"]["parts"][0]["text"]
        result = AgentResult.model_validate_json(text)
        allowed_fields = {"merchant", "category", "amount", "currency", "interval", "status", "usage_minutes"}
        allowed_actions = {"filter", "sort", "group", "create_widget", "modify_widget"}
        if any(action.action not in allowed_actions or
               (action.field is not None and action.field not in allowed_fields)
               for action in result.actions):
            raise ValueError("agent action is not allowlisted")
        return {**result.model_dump(), "origin": "gemini"}
    except Exception:
        logger.warning("Agent response failed; using deterministic explorer", exc_info=False)
        return {**fallback, "origin": "deterministic_fallback"}


def _deterministic_agent(message: str, data: list[dict[str, Any]]) -> dict[str, Any]:
    lowered = message.lower()
    if not data:
        return {"answer": "No subscriptions found.", "actions": []}
    if "decline" in lowered:
        answer = "Usage decline requires at least two measured periods; the current data is too short."
        return {"answer": answer, "actions": [{"action": "sort", "field": "usage_minutes", "direction": "asc"}]}
    if "category" in lowered:
        return {"answer": "Grouped the subscription rows by category.", "actions": [{"action": "group", "field": "category"}]}
    if "saving" in lowered:
        row = max(data, key=lambda item: item.get("amount", 0))
        return {"answer": f"{row['merchant']} has the highest estimated savings opportunity in the current rows.",
                "actions": [{"action": "sort", "field": "amount", "direction": "desc"}]}
    if "3 month" in lowered or "three month" in lowered:
        return {"answer": "Three-month spending needs at least three periods; the current data is too short.",
                "actions": [{"action": "group", "field": "interval"}]}
    row = max(data, key=lambda item: item.get("amount", 0))
    return {"answer": f"{row['merchant']} is currently the highest charge at {row['currency']} {row['amount']:.2f}.",
            "actions": [{"action": "sort", "field": "amount", "direction": "desc"}]}
