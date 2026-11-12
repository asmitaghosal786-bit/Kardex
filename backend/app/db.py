import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone

from .config import get_settings


SCHEMA = """
CREATE TABLE IF NOT EXISTS subscriptions (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, provider_id TEXT,
  merchant TEXT NOT NULL, plan_name TEXT, category TEXT, amount REAL NOT NULL,
  currency TEXT NOT NULL, interval TEXT NOT NULL, next_billing_at TEXT,
  status TEXT NOT NULL, data_origin TEXT NOT NULL, created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, provider_id TEXT, merchant TEXT NOT NULL,
  amount REAL NOT NULL, currency TEXT NOT NULL, occurred_at TEXT NOT NULL,
  status TEXT NOT NULL, category TEXT, subscription_id TEXT, data_origin TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS usage_stats (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, subscription_id TEXT, merchant TEXT,
  usage_minutes REAL NOT NULL, period_start TEXT NOT NULL, period_end TEXT NOT NULL,
  source TEXT NOT NULL, data_origin TEXT NOT NULL, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS recommendations (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, subscription_id TEXT, kind TEXT NOT NULL,
  status TEXT NOT NULL, title TEXT NOT NULL, finding_json TEXT NOT NULL,
  data_origin TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS approvals (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, recommendation_id TEXT NOT NULL,
  status TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS action_log (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, action TEXT NOT NULL,
  entity_id TEXT, detail_json TEXT NOT NULL, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS webhook_events (
  id TEXT PRIMARY KEY, event_id TEXT UNIQUE NOT NULL, event_type TEXT NOT NULL,
  payload_json TEXT NOT NULL, processed_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS web_sessions (
  code_hash TEXT PRIMARY KEY, user_id TEXT NOT NULL, expires_at TEXT NOT NULL,
  used_at TEXT, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS plans (
  id TEXT PRIMARY KEY, product_id TEXT, name TEXT NOT NULL, amount REAL NOT NULL,
  currency TEXT NOT NULL, interval TEXT NOT NULL, android_package TEXT,
  status TEXT NOT NULL, data_origin TEXT NOT NULL, created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS pending_connections (
  state TEXT PRIMARY KEY, user_id TEXT NOT NULL, subscription_id TEXT,
  plan_id TEXT NOT NULL, created_at TEXT NOT NULL, expires_at TEXT NOT NULL
);
"""


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


@contextmanager
def connection():
    conn = sqlite3.connect(get_settings().database_path)
    conn.row_factory = sqlite3.Row
    try:
        conn.executescript(SCHEMA)
        yield conn
        conn.commit()
    finally:
        conn.close()

