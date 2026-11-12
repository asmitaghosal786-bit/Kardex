import re
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone

import psycopg
from psycopg.rows import dict_row

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


class DatabaseConnection:
    def __init__(self, conn, postgres: bool):
        self._conn = conn
        self._postgres = postgres

    def execute(self, query: str, args=()):
        if self._postgres:
            query = re.sub(r"\?", "%s", query)
        return self._conn.execute(query, args)

    def executescript(self, script: str) -> None:
        for statement in script.split(";"):
            statement = statement.strip()
            if statement:
                self.execute(statement)

    def commit(self) -> None:
        self._conn.commit()

    def rollback(self) -> None:
        self._conn.rollback()

    def close(self) -> None:
        self._conn.close()


@contextmanager
def connection():
    settings = get_settings()
    postgres = bool(settings.database_url)
    if postgres:
        conn = psycopg.connect(settings.database_url, row_factory=dict_row, connect_timeout=10)
    else:
        sqlite_conn = sqlite3.connect(settings.database_path)
        sqlite_conn.row_factory = sqlite3.Row
        conn = sqlite_conn
    database = DatabaseConnection(conn, postgres)
    try:
        database.executescript(SCHEMA)
        yield database
        database.commit()
    except Exception:
        database.rollback()
        raise
    finally:
        database.close()

