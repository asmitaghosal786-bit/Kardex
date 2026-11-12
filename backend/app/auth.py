import logging
from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient

from .config import get_settings

logger = logging.getLogger(__name__)
bearer = HTTPBearer(auto_error=False)
jwks_clients: dict[str, PyJWKClient] = {}


def current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)],
) -> str:
    settings = get_settings()
    if not credentials:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Bearer token required")
    jwks_url = settings.supabase_jwks_url
    if not jwks_url and settings.supabase_jwt_issuer:
        jwks_url = f"{settings.supabase_jwt_issuer.rstrip('/')}/.well-known/jwks.json"
    if not settings.supabase_jwt_secret and not jwks_url:
        raise HTTPException(
            status_code=500,
            detail="Configure SUPABASE_JWT_SECRET or SUPABASE_JWKS_URL",
        )
    try:
        options = {"verify_aud": bool(settings.supabase_jwt_audience)}
        token = credentials.credentials
        algorithm = jwt.get_unverified_header(token).get("alg")
        if algorithm == "HS256":
            if not settings.supabase_jwt_secret:
                raise HTTPException(status_code=500, detail="SUPABASE_JWT_SECRET is not configured")
            key = settings.supabase_jwt_secret
            algorithms = ["HS256"]
        elif algorithm in {"ES256", "RS256"}:
            if not jwks_url:
                raise HTTPException(status_code=500, detail="SUPABASE_JWKS_URL is not configured")
            client = jwks_clients.setdefault(jwks_url, PyJWKClient(jwks_url))
            key = client.get_signing_key_from_jwt(token).key
            algorithms = [algorithm]
        else:
            raise jwt.InvalidAlgorithmError("Unsupported JWT algorithm")
        claims = jwt.decode(
            token,
            key,
            algorithms=algorithms,
            audience=settings.supabase_jwt_audience or None,
            issuer=settings.supabase_jwt_issuer or None,
            options=options,
        )
    except jwt.PyJWTError as exc:
        logger.warning("Supabase JWT validation failed: %s: %s", type(exc).__name__, exc)
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Supabase JWT") from exc
    user_id = claims.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="JWT subject is required")
    return str(user_id)
