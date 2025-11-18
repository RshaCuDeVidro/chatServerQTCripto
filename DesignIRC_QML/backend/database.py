"""
PostgreSQL Database Manager (Simplificado)
"""
import asyncpg
from typing import Optional, List, Dict, Any
from config import settings
from models import SQL_CREATE_TABLES, SQL_QUERIES


class Database:
    def __init__(self):
        self.pool: Optional[asyncpg.Pool] = None

    async def connect(self):
        """Conecta ao PostgreSQL"""
        self.pool = await asyncpg.create_pool(
            settings.DATABASE_URL,
            min_size=5,
            max_size=20,
            command_timeout=60
        )
        print(" PostgreSQL conectado")
        await self.init_tables()

    async def disconnect(self):
        """Desconecta do PostgreSQL"""
        if self.pool:
            await self.pool.close()
            print(" PostgreSQL desconectado")

    async def init_tables(self):
        """Cria tabelas se não existirem"""
        async with self.pool.acquire() as conn:
            await conn.execute(SQL_CREATE_TABLES)
            print(" Tabelas inicializadas")

    # ==================== USERS ====================

    async def create_user(self, username: str, password_hash: str) -> Dict[str, Any]:
        """Cria novo usuário"""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                SQL_QUERIES["create_user"],
                username, password_hash
            )
            return dict(row)

    async def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Busca usuário por username"""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                SQL_QUERIES["get_user_by_username"],
                username
            )
            return dict(row) if row else None

    async def update_last_login(self, user_id: int):
        """Atualiza timestamp de último login"""
        async with self.pool.acquire() as conn:
            await conn.execute(SQL_QUERIES["update_last_login"], user_id)

    # ==================== CHANNELS ====================

    async def get_all_channels(self) -> List[Dict[str, Any]]:
        """Lista todos os canais"""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(SQL_QUERIES["get_all_channels"])
            return [dict(row) for row in rows]

    async def get_channel_by_name(self, channel_name: str) -> Optional[Dict[str, Any]]:
        """Busca canal por nome"""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT id, name, description FROM channels WHERE name = $1",
                channel_name
            )
            return dict(row) if row else None

    # ==================== MESSAGES ====================

    async def save_message(
        self,
        channel_id: int,
        user_id: int,
        username: str,
        message: str
    ) -> Dict[str, Any]:
        """Salva mensagem no banco"""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                SQL_QUERIES["save_message"],
                channel_id, user_id, username, message
            )

            return {
                "id": row["id"],
                "channel_id": channel_id,
                "user_id": user_id,
                "username": username,
                "message": message,
                "timestamp": row["timestamp"].isoformat()
            }

    async def get_channel_history(
        self,
        channel_id: int,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Busca histórico de mensagens"""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                SQL_QUERIES["get_channel_history"],
                channel_id, limit
            )

            messages = []
            for row in rows:
                messages.append({
                    "id": row["id"],
                    "user_id": row["user_id"],
                    "username": row["username"],
                    "message": row["message"],
                    "timestamp": row["timestamp"].isoformat(),
                    "edited": row["edited"]
                })

            return list(reversed(messages))

    async def search_messages(self, query: str) -> List[Dict[str, Any]]:
        """Busca mensagens por texto"""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(SQL_QUERIES["search_messages"], query)
            return [dict(row) for row in rows]


# Instância global
db = Database()
