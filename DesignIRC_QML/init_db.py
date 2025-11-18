"""
Script de Inicialização do Banco de Dados
Cria database, usuário e tabelas
"""

import asyncio
import asyncpg
import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_path = os.path.join(current_dir, 'backend')
if backend_path not in sys.path:
    sys.path.append(backend_path)


from getpass import getpass


async def create_database():
    """Cria database e usuário PostgreSQL"""
    
    print("🗄️  Inicialização do Banco de Dados")
    print("=" * 50)
    
    # Credenciais do superusuário PostgreSQL
    print("\n📋 Informe as credenciais do superusuário PostgreSQL:")
    pg_user = input("Usuário (padrão: postgres): ") or "postgres"
    pg_password = getpass("Senha: ")
    pg_host = input("Host (padrão: localhost): ") or "localhost"
    pg_port = input("Porta (padrão: 5432): ") or "5432"
    
    # Credenciais da aplicação
    print("\n📋 Informe as credenciais para a aplicação:")
    app_user = input("Usuário da aplicação (padrão: chat_user): ") or "chat_user"
    app_password = getpass("Senha da aplicação: ")
    app_db = input("Nome do database (padrão: chat_db): ") or "chat_db"
    
    try:
        # Conecta como superusuário
        print(f"\n🔌 Conectando ao PostgreSQL em {pg_host}:{pg_port}...")
        conn = await asyncpg.connect(
            user=pg_user,
            password=pg_password,
            host=pg_host,
            port=pg_port,
            database='postgres'
        )
        
        # Verifica se database já existe
        db_exists = await conn.fetchval(
            "SELECT 1 FROM pg_database WHERE datname = $1",
            app_db
        )
        
        if db_exists:
            print(f"⚠️  Database '{app_db}' já existe!")
            recreate = input("Deseja recriá-lo? Isso apagará TODOS os dados! (s/N): ")
            
            if recreate.lower() == 's':
                print(f"🗑️  Removendo database '{app_db}'...")
                await conn.execute(f'DROP DATABASE "{app_db}"')
            else:
                print("❌ Operação cancelada")
                await conn.close()
                return
        
        # Cria database
        print(f"📦 Criando database '{app_db}'...")
        await conn.execute(f'CREATE DATABASE "{app_db}"')
        
        # Verifica se usuário existe
        user_exists = await conn.fetchval(
            "SELECT 1 FROM pg_user WHERE usename = $1",
            app_user
        )
        
        if not user_exists:
            print(f"👤 Criando usuário '{app_user}'...")
            await conn.execute(f"CREATE USER {app_user} WITH PASSWORD '{app_password}'")
        else:
            print(f"👤 Usuário '{app_user}' já existe, atualizando senha...")
            await conn.execute(f"ALTER USER {app_user} WITH PASSWORD '{app_password}'")
        
        # Concede permissões
        print(f"🔑 Concedendo permissões...")
        await conn.execute(f'GRANT ALL PRIVILEGES ON DATABASE "{app_db}" TO {app_user}')
        
        await conn.close()
        
        # Conecta ao novo database para criar tabelas
        print(f"\n🔌 Conectando ao database '{app_db}'...")
        app_conn = await asyncpg.connect(
            user=app_user,
            password=app_password,
            host=pg_host,
            port=pg_port,
            database=app_db
        )
        
        # Cria extensões e tabelas
        print("📊 Criando tabelas...")
        from models import SQL_CREATE_TABLES
        await app_conn.execute(SQL_CREATE_TABLES)
        
        # Conta tabelas criadas
        tables = await app_conn.fetch("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
        """)
        
        print(f"✅ {len(tables)} tabelas criadas:")
        for table in tables:
            print(f"   - {table['tablename']}")
        
        await app_conn.close()
        
        # Mostra string de conexão
        print("\n" + "=" * 50)
        print("✅ Banco de dados configurado com sucesso!")
        print("\n📝 String de conexão:")
        print(f"   postgresql://{app_user}:{app_password}@{pg_host}:{pg_port}/{app_db}")
        print("\n💡 Copie esta string para o arquivo .env:")
        print(f'   DATABASE_URL=postgresql://{app_user}:{app_password}@{pg_host}:{pg_port}/{app_db}')
        print("=" * 50)
        
    except asyncpg.exceptions.InvalidPasswordError:
        print("❌ Erro: Senha incorreta")
        sys.exit(1)
    except asyncpg.exceptions.PostgresConnectionError as e:
        print(f"❌ Erro de conexão: {e}")
        print("\n💡 Dicas:")
        print("   - PostgreSQL está rodando?")
        print("   - As credenciais estão corretas?")
        print("   - O firewall permite a conexão?")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


async def create_test_user():
    """Cria usuário de teste"""
    from database import db
    from auth import auth
    
    print("\n" + "=" * 50)
    print("👤 Criar Usuário de Teste")
    print("=" * 50)
    
    create = input("\nDeseja criar um usuário de teste? (s/N): ")
    if create.lower() != 's':
        return
    
    username = input("Username (padrão: alice): ") or "alice"
    password = input("Senha (padrão: password123): ") or "password123"
    email = input("Email (padrão: alice@example.com): ") or "alice@example.com"
    
    try:
        await db.connect()
        
        # Verifica se usuário já existe
        existing = await db.get_user_by_username(username)
        if existing:
            print(f"⚠️  Usuário '{username}' já existe!")
            return
        
        # Cria usuário
        password_hash = auth.hash_password(password)
        user = await db.create_user(username, email, password_hash)
        
        print(f"\n✅ Usuário criado com sucesso!")
        print(f"   Username: {username}")
        print(f"   Email: {email}")
        print(f"   ID: {user['id']}")
        
        await db.disconnect()
        
    except Exception as e:
        print(f"❌ Erro ao criar usuário: {e}")


async def verify_installation():
    """Verifica se tudo está funcionando"""
    from database import db
    from cache import cache
    
    print("\n" + "=" * 50)
    print("🔍 Verificando Instalação")
    print("=" * 50)
    
    # Testa PostgreSQL
    print("\n📊 Testando PostgreSQL...")
    try:
        await db.connect()
        
        tables = await db.pool.fetch("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
        """)
        print(f"   ✅ Conectado! {len(tables)} tabelas encontradas")
        
        await db.disconnect()
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return False
    
    # Testa Valkey/Redis
    print("\n🔴 Testando Valkey/Redis...")
    try:
        await cache.connect()
        await cache.client.set("test_key", "test_value")
        value = await cache.client.get("test_key")
        
        if value == "test_value":
            print("   ✅ Conectado e funcionando!")
        else:
            print("   ⚠️  Conectado mas com problema nos dados")
        
        await cache.disconnect()
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        print("   💡 Valkey/Redis está rodando?")
        return False
    
    print("\n" + "=" * 50)
    print("✅ Todos os testes passaram!")
    print("=" * 50)
    return True


async def main():
    """Função principal"""
    print("\n🚀 Setup do Chat Server")
    print("=" * 50)
    print("\nEste script irá:")
    print("  1. Criar database PostgreSQL")
    print("  2. Criar usuário da aplicação")
    print("  3. Criar todas as tabelas")
    print("  4. (Opcional) Criar usuário de teste")
    print("  5. Verificar instalação")
    print("\n" + "=" * 50)
    
    continuar = input("\nContinuar? (S/n): ")
    if continuar.lower() == 'n':
        print("❌ Operação cancelada")
        return
    
    # Passo 1-3: Criar database
    await create_database()
    
    # Passo 4: Usuário de teste
    await create_test_user()
    
    # Passo 5: Verificação
    await verify_installation()
    
    print("\n🎉 Setup concluído!")
    print("\n📝 Próximos passos:")
    print("   1. Configure o .env com a string de conexão")
    print("   2. Inicie o Valkey/Redis: redis-server")
    print("   3. Inicie o servidor: python main.py")
    print("   4. Inicie o cliente QML: python main.py (PySide)")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n❌ Operação cancelada pelo usuário")
        sys.exit(0)
