"""
Backend Bridge (Sem JWT, com senha)
Cliente WebSocket para QML com qasync e estabilidade de conexão
"""

import asyncio
import websockets
import json
from typing import Optional
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer


class BackendBridge(QObject):
    """
    Ponte entre QML e servidor WebSocket
    """

    # ==================== SIGNALS ====================

    connectionStatusChanged = Signal(bool)
    loginSuccess = Signal(dict)
    loginFailed = Signal(str)
    messageReceived = Signal(str, dict)
    channelHistoryReceived = Signal(str, list)
    usersListUpdated = Signal(list)
    userStatusChanged = Signal(str, str)
    userJoinedChannel = Signal(str, str)
    userLeftChannel = Signal(str, str)
    channelsListReceived = Signal(list)
    userTyping = Signal(str, str)
    errorOccurred = Signal(str)

    def __init__(self, server_uri="ws://localhost:8765"):
        super().__init__()

        self.server_uri = server_uri
        self._connected = False
        self._logged_in = False
        self._current_user = None
        self._current_channel = None

        self.websocket: Optional[websockets.WebSocketClientProtocol] = None

        # Timer de reconexão
        self.reconnect_timer = QTimer()
        self.reconnect_timer.timeout.connect(self._attempt_reconnect)

        print(f"[Bridge] Inicializado. Servidor: {self.server_uri}")

    # ==================== CONEXÃO ====================

    async def connect_to_server(self):
        """Conecta ao servidor WebSocket"""
        try:
            print(f"[Bridge] Conectando a {self.server_uri}...")

            async with websockets.connect(
                self.server_uri,
                ping_interval=20,
                ping_timeout=10
            ) as ws:
                self.websocket = ws
                self.connected = True
                print("[Bridge] Conectado ao servidor")

                await self._message_loop()

        except Exception as e:
            print(f"[Bridge] Erro de conexão: {e}")
            self.connected = False
            if not self.reconnect_timer.isActive():
                self.reconnect_timer.start(5000)

    async def _message_loop(self):
        """Loop de recebimento de mensagens"""
        try:
            async for message in self.websocket:
                await self._handle_server_message(message)
        except websockets.exceptions.ConnectionClosed:
            print("[Bridge] Conexão fechada pelo servidor")
            self.connected = False
            self._logged_in = False

    async def _handle_server_message(self, message: str):
        """Processa mensagens do servidor"""
        try:
            data = json.loads(message)
            msg_type = data.get("type")

            # Logs reduzidos para não poluir
            if msg_type not in ["new_message", "user_typing"]:
                 print(f"[Bridge] <- {msg_type}")

            if msg_type == "login_success":
                self._logged_in = True
                self._current_user = data["user"]["username"]
                self.loginSuccess.emit(data["user"])

            elif msg_type == "login_failed":
                self.loginFailed.emit(data.get("message", "Falha no login"))

            elif msg_type == "new_message":
                channel = data.get("channel_name") or data.get("channel") or self._current_channel
                self.messageReceived.emit(channel, data)

            elif msg_type == "channel_history":
                self.channelHistoryReceived.emit(data["channel"], data["messages"])

            elif msg_type == "user_status_changed":
                self.userStatusChanged.emit(data["username"], data["status"])

            elif msg_type == "user_joined":
                self.userJoinedChannel.emit(data["username"], data["channel"])

            elif msg_type == "user_left":
                self.userLeftChannel.emit(data["username"], data["channel"])

            elif msg_type == "channels_list":
                self.channelsListReceived.emit(data["channels"])

            elif msg_type == "user_typing":
                self.userTyping.emit(data["username"], data["channel"])

            elif msg_type == "users_list_updated" or msg_type == "online_users":
                users = data.get("users", [])
                self.usersListUpdated.emit(users)

            elif msg_type == "error":
                print(f"[Bridge] Erro do servidor: {data['message']}")

        except Exception as e:
            print(f"[Bridge] Erro ao processar msg: {e}")

    async def _send(self, data: dict):
        """Envia dados ao servidor (BLINDADO CONTRA CRASH)"""
        if self.websocket and self.connected:
            try:
                await self.websocket.send(json.dumps(data))
            except websockets.exceptions.ConnectionClosed:
                # Apenas avisa, mas NÃO desconecta aqui. O loop principal fará isso.
                print("[Bridge] Aviso: Falha no envio (Socket fechado).")
                pass
            except Exception as e:
                print(f"[Bridge] Erro genérico no envio: {e}")
        else:
            print("[Bridge] Tentativa de envio sem conexão")

    def _attempt_reconnect(self):
        if not self.connected:
            asyncio.create_task(self.connect_to_server())

    # ==================== PROPERTIES ====================

    @Property(bool, notify=connectionStatusChanged)
    def connected(self):
        return self._connected

    @connected.setter
    def connected(self, value: bool):
        if self._connected != value:
            self._connected = value
            self.connectionStatusChanged.emit(value)

    # ==================== SLOTS ====================

    @Slot()
    def connectToServer(self):
        if not self.connected:
            asyncio.create_task(self.connect_to_server())

    @Slot()
    def disconnect(self):
        if self.websocket:
            asyncio.create_task(self.websocket.close())
            self.connected = False

    @Slot(str, str)
    def login(self, username: str, password: str):
        payload = {"type": "login", "username": username, "password": password}
        asyncio.create_task(self._send(payload))

    @Slot(str, str)
    def register(self, username: str, password: str):
        payload = {"type": "login", "action": "register", "username": username, "password": password}
        asyncio.create_task(self._send(payload))

    @Slot(str, str)
    def sendMessage(self, channel: str, message: str):
        if not self._logged_in: return
        # Envia channel e message
        payload = {"type": "send_message", "channel": channel, "message": message}
        asyncio.create_task(self._send(payload))

    # ===== A CORREÇÃO CRÍTICA PARA TROCA DE CANAL =====

    @Slot(str)
    def joinChannel(self, channel_name: str):
        """Chamado pelo QML para mudar de canal"""
        if not self._logged_in: return

        # Evita recarregar o mesmo canal
        if self._current_channel == channel_name: return

        old_channel = self._current_channel

        # Inicia a lógica sequencial protegida
        asyncio.create_task(self._do_channel_change(old_channel, channel_name))

    async def _do_channel_change(self, old_channel: str, new_channel: str):
        """Executa a mudança com PAUSA para estabilizar o socket"""
        try:
            # 1. Sair do antigo (se houver)
            if old_channel:
                await self._send({"type": "leave_channel", "channel": old_channel})

            # 2. PAUSA DE ESTABILIZAÇÃO (Essencial para evitar o erro "Connection Closed")
            await asyncio.sleep(0.1) # 100ms de respiro

            # 3. Entrar no novo
            await self._send({"type": "join_channel", "channel": new_channel})

            # Só atualiza o estado local depois de enviar os comandos
            self._current_channel = new_channel
            print(f"[Bridge] Canal alterado: {old_channel} -> {new_channel}")

        except Exception as e:
            print(f"[Bridge] Erro na troca de canal: {e}")

    @Slot()
    def requestOnlineUsers(self):
        asyncio.create_task(self._send({"type": "get_online_users"}))

    @Slot()
    def requestChannelsList(self):
        asyncio.create_task(self._send({"type": "get_channels"}))
