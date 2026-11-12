from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = ""
    database_path: str = "guardian.db"
    supabase_jwt_secret: str = ""
    supabase_jwt_issuer: str = ""
    supabase_jwt_audience: str = ""
    supabase_jwks_url: str = ""
    paypal_client_id: str = ""
    paypal_client_secret: str = ""
    paypal_webhook_id: str = ""
    paypal_base_url: str = "https://api-m.sandbox.paypal.com"
    api_public_url: str = "http://localhost:8000"
    web_origin: str = "http://localhost:5173"
    demo_mode: bool = True
    llm_api_key: str = ""
    llm_provider: str = "gemini"
    llm_base_url: str = "https://generativelanguage.googleapis.com/v1beta"
    llm_model: str = "gemini-3.5-flash-lite"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()
