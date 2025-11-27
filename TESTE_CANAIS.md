# Teste de Canais Dinâmicos (/join e /leave)

O sistema agora suporta a criação e saída de canais dinamicamente, similar ao IRC.

## Comandos

### /join <nome_canal>
Entra em um canal. Se o canal não existir, ele é criado automaticamente.
- **Exemplo:** `/join #projetosecreto` ou `/join memes`
- **Comportamento:**
  - O canal aparece na sua lista lateral.
  - Você recebe o histórico (se houver).
  - Outros usuários no canal são notificados.

### /leave [nome_canal]
Sai de um canal.
- **Exemplo:** `/leave #projetosecreto`
- **Sem argumento:** `/leave` (sai do canal atual)
- **Comportamento:**
  - O canal é removido da sua lista lateral.
  - Você é movido automaticamente para o canal `#geral`.
  - Outros usuários são notificados da sua saída.

## Roteiro de Teste

1. **Iniciar Servidor e Cliente**
   ```bash
   python server.py
   # Em outro terminal
   python main.py
   ```

2. **Criar um Novo Canal**
   - Digite: `/join #teste1`
   - **Verifique:**
     - O canal `#teste1` aparece na lista lateral?
     - O chat muda para esse canal?
     - Mensagem do sistema: "Você entrou no canal #teste1"?

3. **Trocar de Canal**
   - Clique no canal `#geral` na lista.
   - Digite: `/join #teste1` novamente.
   - **Verifique:** Você volta para o canal criado.

4. **Sair do Canal**
   - Estando em `#teste1`, digite: `/leave`
   - **Verifique:**
     - O canal `#teste1` desaparece da lista lateral?
     - Você é movido para `#geral`?
     - Mensagem do sistema confirma a saída?

5. **Teste Multi-usuário (Opcional)**
   - Abra outro cliente.
   - Entre em `#teste1` com ambos.
   - Verifique se as mensagens são trocadas apenas nesse canal.
   - Saia com um usuário e veja a notificação no outro.
