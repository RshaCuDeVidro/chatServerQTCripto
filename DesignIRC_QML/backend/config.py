"""
Configurações do Backend
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://chat_user:chat_pass@localhost:5432/chat_db"
    )

    # Valkey/Redis
    VALKEY_URL: str = os.getenv(
        "VALKEY_URL",
        "redis://localhost:6379"
    )

    # Server
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8765"))

    # Security(tá certo isso?)
    PASSWORD_MIN_LENGTH: int = 6
    PASSWORD_MAX_LENGTH: int = 128

    # SSL (para produção)
    SSL_CERT_PATH: Optional[str] = os.getenv("SSL_CERT_PATH")
    SSL_KEY_PATH: Optional[str] = os.getenv("SSL_KEY_PATH")

    # Rate Limiting
    RATE_LIMIT_MESSAGES: int = 20  # mensagens
    RATE_LIMIT_WINDOW: int = 60  # segundos

    # Cache
    MESSAGE_CACHE_SIZE: int = 100  # últimas N mensagens em cache
    USER_STATUS_TTL: int = 300  # 5 minutos

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
