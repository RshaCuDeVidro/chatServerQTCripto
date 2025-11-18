"""
Database Models (SQL Schema) - Sem JWT
"""

SQL_CREATE_TABLES = """
-- Tabela de usuários (com senha, sem JWT)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- Tabela de canais
CREATE TABLE IF NOT EXISTS channels (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de mensagens
CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    username VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_messages_channel_time
    ON messages(channel_id, timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_messages_user
    ON messages(user_id);

CREATE INDEX IF NOT EXISTS idx_messages_fulltext
    ON messages USING GIN(to_tsvector('portuguese', message));

-- Canais padrão
INSERT INTO channels (name, description)
VALUES
    ('geral', 'Canal geral'),
    ('dev', 'Desenvolvimento'),
    ('design', 'Design e UI/UX'),
    ('aleatorio', 'Conversas aleatórias')
ON CONFLICT (name) DO NOTHING;
"""

SQL_QUERIES = {
    # Users
    "create_user": """
        INSERT INTO users (username, password_hash)
        VALUES ($1, $2)
        RETURNING id, username, created_at
    """,

    "get_user_by_username": """
        SELECT id, username, password_hash, created_at, is_active, last_login
        FROM users
        WHERE username = $1
    """,

    "update_last_login": """
        UPDATE users
        SET last_login = NOW()
        WHERE id = $1
    """,

    # Channels
    "get_all_channels": """
        SELECT id, name, description
        FROM channels
        ORDER BY name
    """,

    # Messages
    "save_message": """
        INSERT INTO messages (channel_id, user_id, username, message)
        VALUES ($1, $2, $3, $4)
        RETURNING id, timestamp
    """,

    "get_channel_history": """
        SELECT
            id, user_id, username, message,
            timestamp
        FROM messages
        WHERE channel_id = $1
        ORDER BY timestamp DESC
        LIMIT $2
    """,

    # Search
    "search_messages": """
        SELECT
            m.id, m.username, m.message, m.timestamp, c.name as channel_name
        FROM messages m
        JOIN channels c ON m.channel_id = c.id
        WHERE to_tsvector('portuguese', m.message) @@ plainto_tsquery('portuguese', $1)
        ORDER BY m.timestamp DESC
        LIMIT 50
    """
}
