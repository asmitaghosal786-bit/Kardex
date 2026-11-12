export type Subscription = {
  id: string;
  merchant: string;
  category: string;
  amount: number;
  currency: string;
  interval: string;
  status: string;
  next_billing_at: string | null;
  data_origin: string;
  usage_minutes?: number;
};

export type Recommendation = {
  id: string;
  title: string;
  kind: string;
  status: string;
  why_it_matters: string;
  estimated_savings: number;
  action: string;
  data_origin: string;
};

const API_URL =
  import.meta.env.VITE_API_URL ??
  `${window.location.protocol}//${window.location.hostname}:8000`;

export function getApiUrl() {
  return API_URL;
}

export async function exchangeCode(code: string): Promise<string> {
  const response = await fetch(`${API_URL}/api/web-session/exchange`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ code }),
  });
  if (!response.ok) throw new Error("This web session is invalid or expired.");
  return (await response.json()).session_token;
}

export async function api<T>(path: string, token: string): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!response.ok) throw new Error((await response.json().catch(() => null))?.detail ?? "Request failed.");
  return response.json();
}

export async function chat(message: string, token: string): Promise<{ answer: string; actions: unknown[]; origin: string }> {
  const response = await fetch(`${API_URL}/api/agent/chat`, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify({ message }),
  });
  if (!response.ok) throw new Error("The agent could not answer right now.");
  return await response.json();
}
