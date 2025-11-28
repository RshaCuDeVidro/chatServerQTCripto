import socket
import threading
import json
import datetime
import struct
import os
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

HOST = '127.0.0.1'
PORT = 55555
BUFFER_SIZE = 4096

clients = {}  # {socket: {"username": str, "joined_channels": set(), "addr": tuple, "aes_key": bytes}}
channels = {
    "geral": [],
    "desenvolvimento": [],
    "design": [],
    "off-topic": []
}
server_logs = []

# ================= CRIPTOGRAFIA =================

server_private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048
)
server_public_key = server_private_key.public_key()

def get_public_key_pem():
    """Retorna a chave pública em formato PEM."""
    return server_public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

def decrypt_rsa(ciphertext):
    return server_private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

def encrypt_aes(key, plaintext):
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce + ciphertext

def decrypt_aes(key, data):
    nonce = data[:12]
    ciphertext = data[12:]
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, None)

# ================= FRAMING =================

def send_msg(sock, data):
    """Envia mensagem com prefixo de tamanho (4 bytes big-endian)."""
    length = len(data)
    sock.sendall(struct.pack('>I', length) + data)

def recv_msg(sock):
    """Recebe mensagem com prefixo de tamanho."""
    raw_len = recvall(sock, 4)
    if not raw_len:
        return None
    msg_len = struct.unpack('>I', raw_len)[0]
    return recvall(sock, msg_len)

def recvall(sock, n):
    """Helper para receber exatamente n bytes."""
    data = b''
    while len(data) < n:
        packet = sock.recv(n - len(data))
        if not packet:
            return None
        data += packet
    return data

# ================= SERVIDOR =================

def log_event(category, message):
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    log_entry = {
        "timestamp": timestamp,
        "category": category,
        "message": message
    }
    server_logs.append(log_entry)
    print(f"[{timestamp}] [{category}] {message}")
    # Broadcast removido para segurança. Logs agora são enviados pontualmente via send_log.

def send_log(sock, category, message):
    """Envia um log específico para um único cliente de forma segura."""
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    log_entry = {
        "timestamp": timestamp,
        "category": category,
        "message": message
    }
    notification = json.dumps({
        "type": "log_update",
        "data": log_entry
    }).encode('utf-8')
    
    if sock in clients and "aes_key" in clients[sock]:
        try:
            encrypted = encrypt_aes(clients[sock]["aes_key"], notification)
            send_msg(sock, encrypted)
        except:
            pass

def broadcast_message(channel, sender, message, is_system=False):
    timestamp = datetime.datetime.now().isoformat()
    display_time = datetime.datetime.now().strftime("%H:%M")
    
    payload = {
        "type": "message",
        "channel": channel,
        "messageType": "system" if is_system else "other",
        "sender": sender,
        "message": message,
        "timestamp": timestamp,
        "displayTime": display_time
    }
    
    if channel in channels:
        channels[channel].append(payload)
        
    data = json.dumps(payload).encode('utf-8')
    
    for sock, info in clients.items():
        # Verifica se o usuário está no canal (suporte a multi-canais)
        if channel in info.get("joined_channels", set()) and "aes_key" in info:
            try:
                encrypted = encrypt_aes(info["aes_key"], data)
                send_msg(sock, encrypted)
            except:
                pass

def broadcast_user_list(channel):
    """Envia a lista de usuários apenas para os clientes no canal especificado."""
    # Filtrar usuários que estão neste canal (verifica joined_channels)
    users_in_channel = [
        info["username"] for s, info in clients.items() 
        if info.get("username") and channel in info.get("joined_channels", set())
    ]
    
    data = json.dumps({
        "type": "user_list",
        "users": users_in_channel,
        "channel": channel # Importante para o cliente saber de qual canal é a lista
    }).encode('utf-8')
    
    # Enviar apenas para sockets neste canal
    for sock, info in clients.items():
        if channel in info.get("joined_channels", set()) and "aes_key" in info:
            try:
                encrypted = encrypt_aes(info["aes_key"], data)
                send_msg(sock, encrypted)
            except:
                pass

def handle_client(client_socket, addr):
    log_event("NETWORK", f"Nova conexão de {addr}")
    # Inicializa com set de canais
    clients[client_socket] = {"addr": addr, "username": None, "joined_channels": set()}
    
    try:
        pub_key_pem = get_public_key_pem()
        send_msg(client_socket, pub_key_pem)
        
        encrypted_aes_key = recv_msg(client_socket)
        if not encrypted_aes_key:
            return
            
        aes_key = decrypt_rsa(encrypted_aes_key)
        clients[client_socket]["aes_key"] = aes_key
        
        # Logs detalhados para a GUI do cliente
        send_log(client_socket, "SECURITY", f"Handshake: Chave AES recebida de {addr}")
        send_log(client_socket, "SECURITY", f"Handshake: Decriptação RSA da chave AES realizada com sucesso")
        send_log(client_socket, "SECURITY", f"Handshake: Chave AES-256 negociada: {aes_key.hex()[:10]}... (truncada)")
        send_log(client_socket, "SECURITY", f"Handshake: Sessão segura estabelecida. Algoritmo: AES-GCM")
        
        send_log(client_socket, "SECURITY", f"Handshake seguro completado com {addr}")
        
        while True:
            encrypted_data = recv_msg(client_socket)
            if not encrypted_data:
                break
            
            try:
                # Decriptar
                json_data = decrypt_aes(aes_key, encrypted_data)
                request = json.loads(json_data.decode('utf-8'))
                action = request.get("action")
                
                if action == "login":
                    username = request.get("username")
                    clients[client_socket]["username"] = username
                    clients[client_socket]["joined_channels"].add("geral") # Entra no geral automaticamente
                    log_event("CLIENT", f"Usuário logado: {username}")
                    
                    response = json.dumps({
                        "type": "login_success",
                        "username": username,
                        "channel": "geral"
                    }).encode('utf-8')
                    
                    send_msg(client_socket, encrypt_aes(aes_key, response))
                    
                    broadcast_user_list("geral")
                    broadcast_message("geral", "Sistema", f"{username} entrou no chat.", is_system=True)
                    
                elif action == "join_channel":
                    new_channel = request.get("channel")
                    username = clients[client_socket]["username"]
                    
                    # cria canal se não existir
                    if new_channel not in channels:
                        channels[new_channel] = []
                        log_event("SERVER", f"Canal #{new_channel} criado por {username}")

                    # Adiciona ao set de canais
                    clients[client_socket]["joined_channels"].add(new_channel)
                    log_event("CLIENT", f"{username} entrou no canal #{new_channel}")
                    
                    history = [] 
                    
                    response = json.dumps({
                        "type": "channel_joined",
                        "channel": new_channel,
                        "messages": history
                    }).encode('utf-8')
                    
                    send_msg(client_socket, encrypt_aes(aes_key, response))
                    
                    # Notifica outros no canal novo
                    broadcast_message(new_channel, "Sistema", f"{username} entrou no canal.", is_system=True)
                    broadcast_user_list(new_channel)

                elif action == "leave_channel":
                    channel_to_leave = request.get("channel")
                    username = clients[client_socket]["username"]
                    
                    if channel_to_leave == "geral":
                        # Opcional: impedir sair do geral
                        pass
                    
                    # Remove do set de canais
                    if channel_to_leave in clients[client_socket]["joined_channels"]:
                        clients[client_socket]["joined_channels"].remove(channel_to_leave)
                        
                        response = json.dumps({
                            "type": "channel_left",
                            "channel": channel_to_leave,
                            "fallback_channel": "geral" # Cliente decide se muda o foco
                        }).encode('utf-8')
                        send_msg(client_socket, encrypt_aes(aes_key, response))
                        
                        broadcast_message(channel_to_leave, "Sistema", f"{username} saiu do canal.", is_system=True)
                        broadcast_user_list(channel_to_leave)

                elif action == "send_message":
                    channel = request.get("channel")
                    content = request.get("message")
                    username = clients[client_socket]["username"]
                    
                    # Verifica se usuário está no canal antes de enviar
                    if channel and content and channel in clients[client_socket]["joined_channels"]:
                        log_event("SERVER", f"Msg em #{channel}: {content}")
                        broadcast_message(channel, username, content)
                
                elif action == "change_username":
                    new_username = request.get("new_username", "").strip()
                    old_username = clients[client_socket]["username"]
                    
                    # Validar novo username
                    if not new_username:
                        error_response = json.dumps({
                            "type": "username_error",
                            "message": "Username não pode ser vazio."
                        }).encode('utf-8')
                        send_msg(client_socket, encrypt_aes(aes_key, error_response))
                        continue
                    
                    # Verificar se username já está em uso
                    existing_usernames = [info["username"] for sock, info in clients.items() 
                                         if sock != client_socket and info.get("username")]
                    
                    if new_username in existing_usernames:
                        error_response = json.dumps({
                            "type": "username_error",
                            "message": f"Username '{new_username}' já está em uso."
                        }).encode('utf-8')
                        send_msg(client_socket, encrypt_aes(aes_key, error_response))
                        continue
                    
                    clients[client_socket]["username"] = new_username
                    log_event("CLIENT", f"Username alterado: {old_username} → {new_username}")
                    
                    # Enviar confirmação ao cliente
                    success_response = json.dumps({
                        "type": "username_changed",
                        "old_username": old_username,
                        "new_username": new_username
                    }).encode('utf-8')
                    send_msg(client_socket, encrypt_aes(aes_key, success_response))
                    
                    # Notificar todos nos canais que o usuário participa
                    for channel in clients[client_socket]["joined_channels"]:
                        broadcast_message(
                            channel, 
                            "Sistema", 
                            f"{old_username} agora é conhecido como {new_username}.", 
                            is_system=True
                        )
                        broadcast_user_list(channel)
                    
            except Exception as e:
                log_event("ERROR", f"Erro processando dados de {addr}: {e}")

    except Exception as e:
        log_event("NETWORK", f"Erro na conexão com {addr}: {e}")
    finally:
        username = clients[client_socket].get("username")
        joined_channels = list(clients[client_socket].get("joined_channels", [])) # Cópia para iterar
        
        if username:
            log_event("CLIENT", f"{username} desconectou.")
            for channel in joined_channels:
                broadcast_message(channel, "Sistema", f"{username} saiu do chat.", is_system=True)
                # Remove o cliente antes de fazer broadcast da lista
                if client_socket in clients and channel in clients[client_socket]["joined_channels"]:
                     # Já vai ser removido do dict global abaixo, mas para broadcast correto:
                     pass 
        
        if client_socket in clients:
            del clients[client_socket]
        client_socket.close()
        
        # Broadcast user list para os canais afetados
        for channel in joined_channels:
            broadcast_user_list(channel)

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server.bind((HOST, PORT))
        server.listen()
        log_event("SERVER", f"Servidor Seguro (RSA+AES) rodando em {HOST}:{PORT}")
        
        while True:
            client_sock, addr = server.accept()
            thread = threading.Thread(target=handle_client, args=(client_sock, addr))
            thread.daemon = True
            thread.start()
            
    except Exception as e:
        log_event("FATAL", f"Erro ao iniciar servidor: {e}")
    finally:
        server.close()

if __name__ == "__main__":
    print("--- Iniciando Chat Server ---")
    start_server()
