"""
Autenticação e Autorização
"""

import bcrypt

class Auth:
    @staticmethod
    def hash_password(password: str) -> str:
        """Gera hash bcrypt da senha"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

    @staticmethod
    def verify_password(password: str, password_hash: str) -> bool:
        """Verifica senha contra hash"""
        try:
            return bcrypt.checkpw(
                password.encode('utf-8'),
                password_hash.encode('utf-8')
            )
        except Exception as e:
            print(f" Erro ao verificar senha: {e}")
            return False

    @staticmethod
    def validate_username(username: str) -> tuple[bool, str]:
        """Valida username"""
        if len(username) < 3:
            return False, "Username deve ter pelo menos 3 caracteres"
        if len(username) > 50:
            return False, "Username deve ter no máximo 50 caracteres"
        if not all(c.isalnum() or c == "_" for c in username):
            return False, "Username deve conter apenas letras, números e _"
        return True, ""

    @staticmethod
    def validate_password(password: str) -> tuple[bool, str]:
        """Valida senha"""
        if len(password) < 6:
            return False, "Senha deve ter pelo menos 6 caracteres"
        if len(password) > 128:
            return False, "Senha muito longa"
        return True, ""

# Instância global
auth = Auth()
