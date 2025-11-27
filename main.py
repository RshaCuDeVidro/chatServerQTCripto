import struct
import os
import sys
import socket
import threading
import json
import time
import datetime

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# Configurar estilo para evitar erros de customização
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

# Configurações de Conexão
SERVER_HOST = '127.0.0.1'
SERVER_PORT = 55555
BUFFER_SIZE = 4096

# ================= FRAMING =================

def send_msg(sock, data):
    """envia mensagem com prefixo de tamanho (4 bytes big-endian)"""
    length = len(data)
    sock.sendall(struct.pack('>I', length) + data)

def recv_msg(sock):
    """recebe mensagem com prefixo de tamanho"""
    raw_len = recvall(sock, 4)
    if not raw_len:
        return None
    msg_len = struct.unpack('>I', raw_len)[0]
    return recvall(sock, msg_len)

def recvall(sock, n):
    """receber exatamente n bytes"""
    data = b''
    while len(data) < n:
        packet = sock.recv(n - len(data))
        if not packet:
            return None
        data += packet
    return data

# ================= BACKEND =================

class Backend(QObject):
    messageReceived = Signal(str, str, str, str, str) # channel, sender, msg, timestamp, type
    userListUpdated = Signal(list)
    logReceived = Signal(str, str, str) # timestamp, category, message
    channelHistoryLoaded = Signal(str, list) # channel, messages list
    channelJoined = Signal(str) # channel name
    channelLeft = Signal(str) # channel name
    connectionStatusChanged = Signal(bool)

    def __init__(self):
        super().__init__()
        self.socket = None
        self.connected = False
        self.username = ""
        self.running = False
        self.recv_thread = None
        self.aes_key = None
        
        # Gerenciamento de múltiplos canais
        self.joined_channels = set()
        self.channel_store = {} # { "channel_name": [msg_objects] }

    def log_gui(self, category, message):
        """Emite um log para a interface gráfica"""
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        self.logReceived.emit(timestamp, category, message)

    # ... (métodos de criptografia mantidos) ...
    # ================= CRIPTOGRAFIA (RSA + AES-GCM) =================
    # Todos os dados enviados e recebidos passam por estes métodos.

    def encrypt_rsa(self, public_key_pem, plaintext):
        """encripta dados usando a chave publica do servidor"""
        self.log_gui("CRYPTO", f"RSA: Iniciando encriptação de {len(plaintext)} bytes")
        public_key = serialization.load_pem_public_key(public_key_pem)
        ciphertext = public_key.encrypt(
            plaintext,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        self.log_gui("CRYPTO", f"RSA: Sucesso. Texto cifrado: {len(ciphertext)} bytes")
        return ciphertext

    def encrypt_aes(self, key, plaintext):
        """Encripta dados usando AES-GCM."""
        self.log_gui("CRYPTO", f"AES-GCM: Encriptando {len(plaintext)} bytes")
        aesgcm = AESGCM(key)
        nonce = os.urandom(12)
        self.log_gui("CRYPTO", f"AES-GCM: Nonce gerado: {nonce.hex()}")
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        self.log_gui("CRYPTO", f"AES-GCM: Texto cifrado final: {len(nonce + ciphertext)} bytes")
        return nonce + ciphertext

    def decrypt_aes(self, key, data):
        """Decripta dados usando AES-GCM."""
        self.log_gui("CRYPTO", f"AES-GCM: Decriptando pacote de {len(data)} bytes")
        nonce = data[:12]
        ciphertext = data[12:]
        self.log_gui("CRYPTO", f"AES-GCM: Nonce extraído: {nonce.hex()}")
        aesgcm = AESGCM(key)
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        self.log_gui("CRYPTO", f"AES-GCM: Decriptação OK. Texto plano: {len(plaintext)} bytes")
        return plaintext

    @Slot(str)
    def connectToServer(self, username):
        """Conecta ao servidor e realiza handshake seguro."""
        if self.connected:
            return

        self.username = username
        try:
            self.log_gui("NET", f"Conectando a {SERVER_HOST}:{SERVER_PORT}...")
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((SERVER_HOST, SERVER_PORT))
            
            # 1. Handshake: Receber Chave Pública do Servidor
            self.log_gui("HANDSHAKE", "Aguardando chave pública do servidor...")
            server_pub_key_pem = recv_msg(self.socket)
            if not server_pub_key_pem:
                raise Exception("falha ao receber chave publica")
            self.log_gui("HANDSHAKE", f"Chave pública recebida ({len(server_pub_key_pem)} bytes)")
            
            # 2. Handshake: Gerar Chave AES e Enviar Encriptada com RSA
            self.log_gui("HANDSHAKE", "Gerando chave AES-256 efêmera...")
            self.aes_key = AESGCM.generate_key(bit_length=256)
            self.log_gui("HANDSHAKE", f"Chave AES gerada: {self.aes_key.hex()}")
            
            self.log_gui("HANDSHAKE", "Encriptando chave AES com RSA...")
            encrypted_aes_key = self.encrypt_rsa(server_pub_key_pem, self.aes_key)
            
            self.log_gui("HANDSHAKE", "Enviando chave AES encriptada...")
            send_msg(self.socket, encrypted_aes_key)
            
            self.log_gui("HANDSHAKE", "Handshake concluído!")
            print("Handshake concluIdo")
            
            self.connected = True
            self.running = True
            self.connectionStatusChanged.emit(True)

            # Iniciar thread de recebimento
            self.recv_thread = threading.Thread(target=self.receive_loop)
            self.recv_thread.daemon = True
            self.recv_thread.start()

            # Enviar request de login (AES mas criptografado com aes)
            self.send_request({
                "action": "login",
                "username": self.username
            })

        except Exception as e:
            self.log_gui("ERROR", f"Erro de conexão: {e}")
            print(f"Erro de conexão: {e}")
            self.connectionStatusChanged.emit(False)

    @Slot(str, str)
    def sendMessage(self, channel, message):
        if not self.connected:
            return
        
        # verificar se é um comando /username
        if message.startswith("/username "):
            new_username = message[10:].strip()
            if new_username:
                self.changeUsername(new_username)
                return
            else:
                self.log_gui("SYSTEM", "Uso: /username <novo_nome>")
                return

        # verificar se é um comando /join
        if message.startswith("/join "):
            target_channel = message[6:].strip()
            if target_channel:
                # Remove # se o usuário digitou
                if target_channel.startswith("#"):
                    target_channel = target_channel[1:]
                self.joinChannel(target_channel)
                return
            else:
                self.log_gui("SYSTEM", "Uso: /join <nome_canal>")
                return

        # verificar se é um comando /leave
        if message.startswith("/leave "):
            target_channel = message[7:].strip()
            if not target_channel:
                target_channel = channel # se nao especificar, sai do atual
            
            if target_channel.startswith("#"):
                target_channel = target_channel[1:]
                
            self.leaveChannel(target_channel)
            return
        
        self.send_request({
            "action": "send_message",
            "channel": channel,
            "message": message
        })
    
    @Slot(str)
    def leaveChannel(self, channel):
        """Solicita saída de um canal."""
        if not self.connected:
            return
        
        self.send_request({
            "action": "leave_channel",
            "channel": channel
        })
        
        # remove localmente 
        if channel in self.joined_channels:
            self.joined_channels.remove(channel)
    
    @Slot(str)
    def changeUsername(self, new_username):
        """Solicita mudança de username ao servidor."""
        if not self.connected:
            return
        
        self.send_request({
            "action": "change_username",
            "new_username": new_username
        })

    @Slot(str)
    def joinChannel(self, channel):
        if not self.connected:
            return

        # se ja ta no krai do historico, nao faz buceta de nada
        if channel in self.joined_channels:
            print(f"Já conectado em {channel}, carregando histórico local.")
            msgs = self.channel_store.get(channel, [])
            self.channelHistoryLoaded.emit(channel, msgs)
            self.channelJoined.emit(channel)
            return

        self.send_request({
            "action": "join_channel",
            "channel": channel
        })

    def send_request(self, payload):
        try:
            json_str = json.dumps(payload).encode('utf-8')
            # Usar método da classe para logar
            encrypted_data = self.encrypt_aes(self.aes_key, json_str)
            send_msg(self.socket, encrypted_data)
        except Exception as e:
            self.log_gui("ERROR", f"Erro ao enviar: {e}")
            print(f"Erro ao enviar: {e}")
            self.connected = False
            self.connectionStatusChanged.emit(False)

    def receive_loop(self):
        """loop principal de recebimento de mensagens encriptadas"""
        while self.running and self.connected:
            try:
                encrypted_data = recv_msg(self.socket)
                if not encrypted_data:
                    break
                
                try:
                    # Decriptar usando método da classe
                    json_data = self.decrypt_aes(self.aes_key, encrypted_data)
                    message = json.loads(json_data.decode('utf-8'))
                    self.process_message(message)
                except Exception as e:
                    self.log_gui("ERROR", f"Erro ao processar msg: {e}")
                    print(f"Erro ao processar mensagem recebida: {e}")

            except Exception as e:
                self.log_gui("ERROR", f"Erro no loop: {e}")
                print(f"Erro no loop de recebimento: {e}")
                break
        
        self.connected = False
        self.connectionStatusChanged.emit(False)

    def process_message(self, msg):
        """processa mensagens vindas do servidor"""
        msg_type = msg.get("type")

        if msg_type == "message":
            channel = msg.get("channel")
            
            # Armazenar mensagem localmente
            if channel:
                if channel not in self.channel_store:
                    self.channel_store[channel] = []
                self.channel_store[channel].append(msg)
            
            self.messageReceived.emit(
                msg.get("channel"),
                msg.get("sender"),
                msg.get("message"),
                msg.get("displayTime"),
                msg.get("messageType")
            )
        
        elif msg_type == "user_list":
            self.userListUpdated.emit(msg.get("users", []))
        
        elif msg_type == "log_update":
            log_data = msg.get("data", {})
            self.logReceived.emit(
                log_data.get("timestamp"),
                log_data.get("category"),
                log_data.get("message")
            )
        
        elif msg_type == "channel_history":
            channel = msg.get("channel")
            messages = msg.get("messages", [])
            
            # Atualizar store local
            self.channel_store[channel] = messages
            
            self.channelHistoryLoaded.emit(channel, messages)
        
        elif msg_type == "channel_joined":
            channel = msg.get("channel")
            history = msg.get("messages", [])
            
            self.joined_channels.add(channel)
            if channel not in self.channel_store:
                self.channel_store[channel] = []
            
            self.channelJoined.emit(channel)
            self.channelHistoryLoaded.emit(channel, self.channel_store[channel])
            
        elif msg_type == "channel_left":
            channel = msg.get("channel")
            if channel in self.joined_channels:
                self.joined_channels.remove(channel)
            self.channelLeft.emit(channel)
        
        elif msg_type == "username_changed":
            # Atualizar username local
            old_username = self.username
            self.username = msg.get("new_username")
            print(f"Username alterado de {old_username} para {self.username}")
        
        elif msg_type == "username_error":
            error_msg = msg.get("message", "Erro ao alterar username")
            print(f"Erro ao alterar username: {error_msg}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    
    engine.rootContext().setContextProperty("backend", backend)

    engine.load(QUrl.fromLocalFile("./DesignIRC_QMLContent/main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
