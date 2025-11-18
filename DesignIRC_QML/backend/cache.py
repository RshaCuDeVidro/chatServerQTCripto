"""
Valkey/Redis Cache Manager
"""
import json
from typing import Optional, List, Dict, Set
from valkey.asyncio import Valkey
from config import settings

class Cache:
    def __init__(self):
        self.client: Optional[Valkey] = None
        self.pubsub = None

    async def connect(self):
        """Conecta ao Valkey"""
        self.client = Valkey.from_url(
            settings.VALKEY_URL,
            decode_responses=True,
            encoding="utf-8"
        )
        await self.client.ping()
        print("Valkey conectado")

    async def disconnect(self):
        """Desconecta do Valkey"""
        if self.client:
            await self.client.close()
            print("Valkey desconectado")

    async def clear_all_online_users(self):
        """Limpa lista de usuários online ao iniciar o servidor"""
        await self.client.delete("users:online")
        # Opcional: Limpar chaves de status individuais se quiser um reset total
        # chaves = await self.client.keys("user:*:status")
        # if chaves: await self.client.delete(*chaves)
        print(" Cache: Lista de usuários online limpa")

    # ==================== USER STATUS ====================

    async def set_user_status(self, username: str, status: str):
        """Define status do usuário (online/away/offline)"""
        await self.client.setex(
            f"user:{username}:status",
            settings.USER_STATUS_TTL,
            status
        )
        if status in ["online", "away"]:
            await self.client.sadd("users:online", username)
        elif status == "offline":
            await self.client.srem("users:online", username)

    async def get_user_status(self, username: str) -> str:
        """Obtém status do usuário"""
        status = await self.client.get(f"user:{username}:status")
        return status or "offline"

    async def get_online_users(self) -> List[str]:
        """Lista todos os usuários online(otimizado com Set"""
        online_usernames = await self.client.smembers("users:online")
        if not online_usernames:
            return []

        # Busca o status exato (online/away) de cada um.
        pipe = self.client.pipeline()
        for username in online_usernames:
            pipe.get(f"user:{username}:status")

        statuses = await pipe.execute()

        users = []
        for i, username in enumerate(online_usernames):
            status = statuses[i] or "online" # Garante um status padrão
            users.append({"username": username, "status": status})

        return users

    # ==================== CHANNEL PRESENCE ====================

    async def add_user_to_channel(self, channel_name: str, username: str):
        """Adiciona usuário a um canal"""
        await self.client.sadd(f"channel:{channel_name}:users", username)

    async def remove_user_from_channel(self, channel_name: str, username: str):
        """Remove usuário de um canal"""
        await self.client.srem(f"channel:{channel_name}:users", username)

    async def get_channel_users(self, channel_name: str) -> Set[str]:
        """Lista usuários em um canal"""
        users = await self.client.smembers(f"channel:{channel_name}:users")
        return users or set()

    # ==================== TYPING INDICATOR ====================
    #vou tirar se pá?
    async def set_typing(self, channel_name: str, username: str):
        """Indica que usuário está digitando(otimizado com Set e TTl)"""
        # --- INÍCIO DA CORREÇÃO ---
        key = f"typing:{channel_name}"
        # Adiciona o usuário ao Set
        await self.client.sadd(key, username)
        # Define a expiração para o Set inteiro (3 segundos)
        # Se ninguém digitar, o Set expira e desaparece.
        await self.client.expire(key, 3)
        # --- FIM DA CORREÇÃO ---

    async def get_typing_users(self, channel_name: str) -> List[str]:
        """Lista quem está digitando no canal(otimi\ado"""
        # --- INÍCIO DA CORREÇÃO ---
        # Simplesmente lê os membros do Set
        users = await self.client.smembers(f"typing:{channel_name}")
        return list(users or [])
    # ==================== RATE LIMITING ====================

    async def check_rate_limit(self, username: str) -> bool:
        """Verifica se usuário excedeu rate limit"""
        key = f"rate:{username}:messages"
        count = await self.client.get(key)

        if count is None:
            # Primeira mensagem na janela
            await self.client.setex(
                key,
                settings.RATE_LIMIT_WINDOW,
                1
            )
            return True

        count = int(count)
        if count >= settings.RATE_LIMIT_MESSAGES:
            return False  # Excedeu limite

        # Incrementa contador
        await self.client.incr(key)
        return True

    # ==================== MESSAGE CACHE ====================

    async def cache_message(self, channel_name: str, message_data: Dict):
        """Cacheia mensagem recente"""
        await self.client.lpush(
            f"cache:{channel_name}:messages",
            json.dumps(message_data)
        )
        await self.client.ltrim(
            f"cache:{channel_name}:messages",
            0,
            settings.MESSAGE_CACHE_SIZE - 1
        )

    async def get_cached_messages(self, channel_name: str) -> List[Dict]:
        """Obtém mensagens cacheadas"""
        messages = await self.client.lrange(
            f"cache:{channel_name}:messages",
            0,
            -1
        )
        return [json.loads(msg) for msg in reversed(messages)]

    # ==================== PUB/SUB ====================

    async def publish_message(self, channel_name: str, message_data: Dict):
        """Publica mensagem via Pub/Sub"""
        await self.client.publish(
            f"channel:{channel_name}",
            json.dumps(message_data)
        )
        print(f" Pub/Sub: Publicado em channel:{channel_name}")

    async def subscribe_to_channels(self):
        """Inscreve-se em todos os canais usando pattern matching"""
        if not self.pubsub:
            self.pubsub = self.client.pubsub()

        # Pattern subscribe: escuta TODOS os canais (channel:*)
        await self.pubsub.psubscribe("channel:*")
        print(" Pub/Sub: Inscrito em todos os canais (channel:*)")

        return self.pubsub

    async def subscribe_to_channel(self, channel_name: str):
        """Inscreve-se em um canal específico"""
        if not self.pubsub:
            self.pubsub = self.client.pubsub()

        await self.pubsub.subscribe(f"channel:{channel_name}")
        print(f" Pub/Sub: Inscrito em channel:{channel_name}")
        return self.pubsub

    async def unsubscribe_from_channel(self, channel_name: str):
        """Cancela inscrição em canal"""
        if self.pubsub:
            await self.pubsub.unsubscribe(f"channel:{channel_name}")
            print(f" Pub/Sub: Desinscrito de channel:{channel_name}")

# Instância global
cache = Cache()
