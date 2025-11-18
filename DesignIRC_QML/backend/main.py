"""
Servidor WebSocket Simplificado (Sem JWT, com bcrypt)
"""
import asyncio
import websockets
from websockets.server import ServerProtocol
import json
from typing import Dict

from config import settings
from database import db
from cache import cache
from auth import auth

# Usuários conectados: {username: websocket}
connected_clients: Dict[str, ServerProtocol] = {}

# Canais que cada usuário está visualizando: {username: channel_name}
user_channels: Dict[str, str] = {}


class ChatServer:
    def __init__(self):
        """Inicializa servidor"""
        self.pubsub_task = None

    async def start(self):
        """Inicia o servidor"""
        await db.connect()
        await cache.connect()

        # Inicia listener Pub/Sub em background
        self.pubsub_task = asyncio.create_task(self.pubsub_listener())

        print(f"Servidor iniciando em ws://{settings.HOST}:{settings.PORT}")

        async with websockets.serve(self.handler, settings.HOST, settings.PORT):
            await asyncio.Future()

    async def pubsub_listener(self):
        """Escuta mensagens Pub/Sub do Valkey"""
        print("Pub/Sub listener iniciado")

        # Subscribe em todos os canais (pattern matching)
        pubsub = await cache.subscribe_to_channels()

        try:
            async for message in pubsub.listen():
                if message["type"] == "message":
                    channel_key = message["channel"]  # Ex: "channel:geral"
                    try:
                        # Garante que o split funcione
                        if ":" in channel_key:
                            channel_name = channel_key.split(":", 1)[1]
                        else:
                            continue

                        data = json.loads(message["data"])

                        # Broadcast para usuários conectados no canal
                        await self.broadcast_to_channel(channel_name, data)

                    except json.JSONDecodeError as e:
                        print(f"[Erro] Ao decodificar mensagem Pub/Sub: {e}")
                    except Exception as e:
                         print(f"[Erro] Processando mensagem Pub/Sub: {e}")

        except Exception as e:
            print(f"[Erro] Fatal no Pub/Sub listener: {e}")

    async def handler(self, websocket: ServerProtocol):
        """Handler principal de conexões WebSocket"""
        username = None
        user_id = None
        current_channel = None

        try:
            async for message in websocket:
                data = json.loads(message)
                msg_type = data.get("type")

                # Login simplificado (apenas username)
                if msg_type == "login":
                    username, user_id = await self.handle_login(websocket, data)
                    if username:
                        connected_clients[username] = websocket
                        await cache.set_user_status(username, "online")
                        print(f"[Auth] {username} conectado")
                    continue

                # Requer login para outras ações
                if not username:
                    await self.send_error(websocket, "Não autenticado")
                    continue

                # Roteamento de mensagens
                if msg_type == "send_message":
                    await self.handle_send_message(username, user_id, data)

                elif msg_type == "join_channel":
                    current_channel = await self.handle_join_channel(username, websocket, data)
                    user_channels[username] = current_channel

                elif msg_type == "leave_channel":
                    await self.handle_leave_channel(username, current_channel)
                    current_channel = None

                elif msg_type == "typing":
                    await self.handle_typing(username, data)

                elif msg_type == "status_update":
                    await self.handle_status_update(username, data)

                elif msg_type == "search":
                    await self.handle_search(websocket, data)

                elif msg_type == "get_online_users":
                    await self.handle_get_online_users(websocket)

                elif msg_type == "get_channels":
                    await self.handle_get_channels(websocket)

                else:
                    await self.send_error(websocket, f"Tipo desconhecido: {msg_type}")

        except websockets.exceptions.ConnectionClosed:
            print(f"[Conn] {username} desconectou")

        except Exception as e:
            print(f"[Erro] No handler principal: {e}")

        finally:
            # Cleanup ao desconectar
            if username:
                if username in connected_clients:
                    del connected_clients[username]
                if username in user_channels:
                    channel = user_channels[username]
                    await cache.remove_user_from_channel(channel, username)
                    del user_channels[username]
                await cache.set_user_status(username, "offline")
                print(f"[Conn] {username} saiu totalmente")

    # ==================== HANDLERS ====================

    async def handle_login(self, websocket, data) -> tuple[str | None, int | None]:
        """Login com username e senha"""
        username = data.get("username", "").strip()
        password = data.get("password", "")
        action = data.get("action", "login")  # login ou register

        # Validações
        valid, msg = auth.validate_username(username)
        if not valid:
            await self.send_error(websocket, msg)
            return None, None

        if action == "register":
            # Registro de novo usuário
            valid, msg = auth.validate_password(password)
            if not valid:
                await self.send_error(websocket, msg)
                return None, None

            try:
                # Verifica se username já existe
                existing_user = await db.get_user_by_username(username)
                if existing_user:
                    await self.send_error(websocket, "Username já existe")
                    return None, None

                # Cria usuário com senha criptografada
                password_hash = auth.hash_password(password)
                user = await db.create_user(username, password_hash)

                await websocket.send(json.dumps({
                    "type": "login_success",
                    "user": {
                        "id": user["id"],
                        "username": username
                    }
                }))
                return username, user["id"]

            except Exception as e:
                await self.send_error(websocket, f"Erro ao criar usuário: {str(e)}")
                return None, None

        else:
            # Login
            user = await db.get_user_by_username(username)

            if not user:
                await self.send_error(websocket, "Usuário não encontrado")
                return None, None

            # Verifica se usuário está ativo
            if not user.get("is_active", True):
                await self.send_error(websocket, "Usuário desativado. Contate o administrador.")
                return None, None

            # Verifica senha
            if not auth.verify_password(password, user["password_hash"]):
                await self.send_error(websocket, "Senha incorreta")
                return None, None

            # Login bem-sucedido - atualiza last_login
            await db.update_last_login(user["id"])

            await websocket.send(json.dumps({
                "type": "login_success",
                "user": {
                    "id": user["id"],
                    "username": username
                }
            }))
            return username, user["id"]

    async def handle_send_message(self, username: str, user_id, data: Dict):
        """Processa envio de mensagem"""

        # Verificação de segurança crítica
        if not user_id:
            print(f"[Security] Tentativa de envio sem user_id por {username}")
            return

        channel_name = data.get("channel")
        message = data.get("message")

        # Rate limiting
        if not await cache.check_rate_limit(username):
            ws = connected_clients.get(username)
            if ws:
                await self.send_error(ws, "Muitas mensagens. Aguarde.")
            return

        # Busca canal
        channel = await db.get_channel_by_name(channel_name)
        if not channel:
            return

        # Salva no banco
        saved_msg = await db.save_message(
            channel["id"],
            user_id,
            username,
            message
        )

        # Cacheia no Valkey
        await cache.cache_message(channel_name, saved_msg)

        # Publica via Pub/Sub
        await cache.publish_message(channel_name, {
            "type": "new_message",
            "channel_name": channel_name,
            **saved_msg
        })

    async def handle_join_channel(self, username: str, websocket, data: Dict) -> str:
        """Usuário entra em um canal"""
        channel_name = data.get("channel")

        if not channel_name:
            return "geral" # Fallback seguro

        await cache.add_user_to_channel(channel_name, username)

        # Envia histórico
        channel = await db.get_channel_by_name(channel_name)
        if channel:
            history = await db.get_channel_history(channel["id"], limit=100)
            await websocket.send(json.dumps({
                "type": "channel_history",
                "channel": channel_name,
                "messages": history
            }))

        # Notifica outros usuários
        await self.broadcast_to_channel(channel_name, {
            "type": "user_joined",
            "username": username,
            "channel": channel_name
        }, exclude=username)

        return channel_name

    async def handle_leave_channel(self, username: str, channel_name: str):
        """Usuário sai de um canal"""
        if not channel_name:
            return

        await cache.remove_user_from_channel(channel_name, username)

        await self.broadcast_to_channel(channel_name, {
            "type": "user_left",
            "username": username,
            "channel": channel_name
        }, exclude=username)

        # Remoção local de segurança
        if username in user_channels:
            del user_channels[username]

    async def handle_typing(self, username: str, data: Dict):
        """Indicador de digitação"""
        channel_name = data.get("channel")
        await cache.set_typing(channel_name, username)

        await self.broadcast_to_channel(channel_name, {
            "type": "user_typing",
            "username": username,
            "channel": channel_name
        }, exclude=username)

    async def handle_status_update(self, username: str, data: Dict):
        """Atualiza status do usuário"""
        status = data.get("status")
        await cache.set_user_status(username, status)

        # Broadcast manual para todos os conectados
        message = {
            "type": "user_status_changed",
            "username": username,
            "status": status
        }
        # Envia para todos (poderia ser otimizado, mas ok para agora)
        for client_user, ws in connected_clients.items():
            try:
                await ws.send(json.dumps(message))
            except:
                pass

    async def handle_search(self, websocket, data: Dict):
        """Busca mensagens por texto"""
        query = data.get("query")
        results = await db.search_messages(query)

        await websocket.send(json.dumps({
            "type": "search_results",
            "query": query,
            "results": results
        }))

    async def handle_get_online_users(self, websocket):
        """Envia lista de usuários online"""
        online_users = await cache.get_online_users()

        await websocket.send(json.dumps({
            "type": "users_list_updated",
            "users": online_users
        }))

    async def handle_get_channels(self, websocket):
        """Envia lista de canais"""
        channels = await db.get_all_channels()

        await websocket.send(json.dumps({
            "type": "channels_list",
            "channels": channels
        }))

    # ==================== HELPERS ====================

    async def broadcast_to_channel(self, channel_name: str, message: Dict, exclude: str = None):
        """Envia mensagem para todos os usuários em um canal de forma segura"""

        # Cria cópia da lista para evitar erro de iteração se o dicionário mudar
        users_to_check = list(user_channels.items())

        for username, current_channel in users_to_check:
            if current_channel == channel_name and username != exclude:
                ws = connected_clients.get(username)
                if ws:
                    try:
                        await ws.send(json.dumps(message))
                    except Exception as e:
                        # IMPORTANTE: Não use emojis aqui para evitar crash no Windows
                        print(f"[Aviso] Erro ao enviar para {username} no canal {channel_name}: {e}")
                        # Não fazemos 'raise', apenas ignoramos a falha de envio individual
                        pass

    async def send_error(self, websocket, error_message: str):
        """Envia mensagem de erro"""
        try:
            await websocket.send(json.dumps({
                "type": "error",
                "message": error_message
            }))
        except:
            pass


# ==================== MAIN ====================

async def main():
    server = ChatServer()
    await server.start()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServidor encerrado")
