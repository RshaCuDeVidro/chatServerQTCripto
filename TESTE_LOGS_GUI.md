# Teste de Logs na Interface Gráfica

O sistema foi atualizado para exibir logs detalhados de criptografia diretamente na interface do chat (aba de Logs), em vez de usar o terminal.

## Como Verificar

1. **Inicie o Servidor**
   ```bash
   python server.py
   ```

2. **Inicie o Cliente**
   ```bash
   python main.py
   ```

3. **Conecte-se**
   - Digite um username e clique em conectar.
   - Vá imediatamente para a aba/painel de **Logs** na interface.

4. **O que você verá na Interface**

   **Logs Locais (Cliente):**
   - `[NET] Conectando a 127.0.0.1:55555...`
   - `[HANDSHAKE] Aguardando chave pública...`
   - `[HANDSHAKE] Chave pública recebida (451 bytes)`
   - `[HANDSHAKE] Gerando chave AES-256 efêmera...`
   - `[HANDSHAKE] Chave AES gerada: a1b2c3...`
   - `[CRYPTO] RSA: Iniciando encriptação...`
   - `[HANDSHAKE] Enviando chave AES encriptada...`

   **Logs Remotos (Vindos do Servidor):**
   - `[SECURITY] Handshake: Chave AES recebida de ('127.0.0.1', ...)`
   - `[SECURITY] Handshake: Decriptação RSA da chave AES realizada com sucesso`
   - `[SECURITY] Handshake: Sessão segura estabelecida. Algoritmo: AES-GCM`

   **Logs de Mensagens (Tempo Real):**
   - Ao enviar uma mensagem:
     - `[CRYPTO] AES-GCM: Encriptando X bytes`
     - `[CRYPTO] AES-GCM: Nonce gerado: ...`
   - Ao receber uma mensagem:
     - `[CRYPTO] AES-GCM: Decriptando pacote de Y bytes`
     - `[CRYPTO] AES-GCM: Decriptação OK`

## Benefícios
- Debug visual sem precisar de acesso ao console.
- Transparência total do processo de criptografia para o usuário final.
- Confirmação visual de que a criptografia RSA e AES está ativa e funcionando.
