# chatServerQTCripto

Cliente de chat estilo IRC com criptografia ponta-a-ponta, construido com PySide6 (QML) e Python.

O projeto contem duas arquiteturas de servidor:

- **Servidor TCP criptografado** (`server.py`) — RSA-2048 + AES-256-GCM, conexao raw via sockets
- **Servidor WebSocket** (`DesignIRC_QML/backend/`) — PostgreSQL + Valkey (Redis), auth com bcrypt, Pub/Sub

---

## Funcionalidades

- Handshake seguro RSA + AES-GCM (servidor TCP)
- Multi-canais com join/leave e troca em tempo real
- Historico de mensagens por canal (PostgreSQL + cache Valkey)
- Indicador de digitacao
- Mudanca de username em tempo real
- Registro e login com senha (bcrypt)
- Busca full-text de mensagens (PostgreSQL GIN index)
- Rate limiting por usuario
- Logs de seguranca na interface (eventos de criptografia, handshake, erros)
- Interface dark-theme estilo IRC com sidebar, chat e lista de usuarios

---

## Arquitetura

```
chatServerQTCripto/
├── main.py                              # Cliente PySide6 + Backend bridge
├── server.py                            # Servidor TCP (RSA+AES-GCM)
├── DesignIRC_QML/
│   ├── DesignIRC_QMLContent/
│   │   ├── main.qml                     # Tela principal (EventBus + StackView)
│   │   ├── Screen01.ui.qml              # Tela de design (Qt Design Studio)
│   │   └── components/
│   │       ├── ChannelList.qml          # Sidebar de canais
│   │       ├── ChatArea.qml             # Area de mensagens
│   │       ├── InputBar.qml             # Barra de input
│   │       ├── UserList.qml             # Lista de usuarios online
│   │       ├── LogView.qml              # Visualizador de logs
│   │       ├── StyledSidebar.qml        # Sidebar estilizada
│   │       ├── MessageDelegateSelf.qml  # Balao de msg propria
│   │       ├── MessageDelegateOther.qml # Balao de msg de outros
│   │       ├── MessageDelegateBase.qml  # Base para delegates de msg
│   │       └── SystemMessageDelegate.qml # Delegate de msg do sistema
│   ├── backend/
│   │   ├── main.py                      # Servidor WebSocket async
│   │   ├── database.py                  # PostgreSQL (asyncpg)
│   │   ├── cache.py                     # Valkey/Redis cache + Pub/Sub
│   │   ├── auth.py                      # bcrypt hash/verify
│   │   ├── models.py                    # SQL schema + queries
│   │   ├── config.py                    # Pydantic Settings
│   │   ├── requirements.txt             # Dependencias Python
│   │   └── Dockerfile
│   ├── docker-compose.yml               # PostgreSQL + Valkey + pgAdmin
│   └── Python/
│       ├── main.py                      # Bridge alternativo
│       └── backend_bridge.py             # Bridge Qt ↔ WebSocket
```

---

## Servidor TCP Criptografado (`server.py`)

Conexao raw via sockets com criptografia ponta-a-ponta:

1. Servidor envia chave publica RSA-2048
2. Cliente gera chave AES-256 efemera e envia encriptada com RSA-OAEP
3. Toda comunicacao passa por AES-256-GCM dali em diante

Canais padrao: `geral`, `desenvolvimento`, `design`, `off-topic`

### Rodar

```bash
python server.py
```

Escuta em `127.0.0.1:55555`.

---

## Servidor WebSocket (`DesignIRC_QML/backend/`)

Servidor assincrono com persistencia e cache:

- **PostgreSQL** — usuarios, canais, mensagens, busca full-text
- **Valkey** — cache de mensagens, status online, rate limiting, typing indicator, Pub/Sub
- **bcrypt** — hash e verificacao de senhas

### Rodar com Docker

```bash
cd DesignIRC_QML
docker compose up -d
```

Isso sobe PostgreSQL (porta 5432), Valkey (porta 6379), o backend (porta 8765) e pgAdmin (porta 5050).

### Rodar sem Docker

Requer PostgreSQL e Valkey/Redis rodando localmente.

```bash
cd DesignIRC_QML/backend
pip install -r requirements.txt
python main.py
```

Configuracao via variaveis de ambiente ou arquivo `.env`:

| Variavel | Default |
|---|---|
| `DATABASE_URL` | `postgresql://chat_user:chat_pass@localhost:5432/chat_db` |
| `VALKEY_URL` | `redis://localhost:6379` |
| `HOST` | `0.0.0.0` |
| `PORT` | `8765` |

---

## Cliente (`main.py`)

Interface QML com PySide6. Conecta ao servidor TCP por padrao.

### Requisitos

- Python 3.10+
- PySide6
- cryptography

### Rodar

```bash
pip install PySide6 cryptography
python main.py
```

### Comandos no chat

| Comando | Acao |
|---|---|
| `/join <canal>` | Entrar em um canal |
| `/leave <canal>` | Sair de um canal |
| `/username <nome>` | Alterar username |

---

## Stack Tecnologica

| Camada | Tecnologia |
|---|---|
| Frontend | PySide6 + QML |
| Servidor TCP | Python sockets + threading |
| Servidor WS | websockets + asyncio |
| Criptografia | RSA-2048-OAEP + AES-256-GCM |
| Banco | PostgreSQL (asyncpg) |
| Cache | Valkey/Redis |
| Auth | bcrypt |
| Containers | Docker Compose |

---

## Estrutura do Protocolo TCP

Todas as mensagens usam framing com prefixo de 4 bytes (big-endian) para o tamanho, seguido do payload criptografado AES-GCM (nonce 12 bytes + ciphertext).

**Handshake:**

```
Servidor → Cliente:  [4 bytes len] + PEM da chave publica RSA
Cliente → Servidor:  [4 bytes len] + chave AES encriptada com RSA
```

**Comunicacao (pos-handshake):**

```json
// Login
{"action": "login", "username": "alice"}

// Mensagem
{"action": "send_message", "channel": "geral", "message": "ola"}

// Entrar no canal
{"action": "join_channel", "channel": "dev"}

// Sair do canal
{"action": "leave_channel", "channel": "dev"}

// Trocar username
{"action": "change_username", "new_username": "bob"}
```

**Respostas do servidor:**

```json
// Mensagem de chat
{"type": "message", "channel": "geral", "sender": "alice", "message": "ola", "messageType": "other", "timestamp": "...", "displayTime": "14:30"}

// Lista de usuarios
{"type": "user_list", "channel": "geral", "users": ["alice", "bob"]}

// Log
{"type": "log_update", "data": {"timestamp": "14:30:05", "category": "SECURITY", "message": "Handshake completo"}}

// Canal entrou
{"type": "channel_joined", "channel": "dev", "messages": []}

// Username alterado
{"type": "username_changed", "old_username": "alice", "new_username": "bob"}
```
