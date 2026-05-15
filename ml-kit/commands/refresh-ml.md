---
description: Forca refresh do access_token ML disparando o webhook do workflow n8n de refresh
---

Executa um refresh manual dos tokens ML (pre-venda + pos-venda) chamando o webhook do workflow n8n `[TOKEN ML] Refresh via Cron Externo - a cada 3h`. Use quando o token estiver perto de expirar ou apos uma falha do cron-job.org.

NAO chame o script `hooks/refresh-ml-token.ps1` — desde a v1.4 ele apenas loga status, nao renova token. Quem renova de fato e o workflow n8n.

Passos:

1. **Ler `N8N_URL` do `.env`** do projeto (`$CLAUDE_PROJECT_DIR/.env`). Se ausente, parar e avisar.

2. **Buscar config do webhook via MCP n8n.** Workflow ID padrao: `KOblYJST7loNVAqP`. Use `mcp__n8n__n8n_get_workflow` com mode=`full` e extraia:
   - Path do webhook do node `Webhook: Cron Externo Refresh` (`parameters.path`)
   - Secret do node `IF: Secret Valido?` (`parameters.conditions.conditions[0].rightValue`)

3. **Disparar webhook via PowerShell:**
   ```powershell
   Invoke-WebRequest -Uri "$N8N_URL/webhook/$path" -Method Post -Headers @{ "x-secret" = "$secret" } -UseBasicParsing -TimeoutSec 30
   ```
   Esperar `StatusCode: 200` e body `{"message":"Workflow was started"}`.

4. **Confirmar execucao:** chame `mcp__n8n__n8n_executions` action=`list` workflowId=`KOblYJST7loNVAqP` limit=`3` e verifique a execucao mais recente. Status deve ser `success`. Se `error`, abrir `action=get` mode=`error` para diagnosticar.

5. **Validar token no Supabase:** consultar `public."access_token_ML"` filtrando por `app_name`. O `expires_at` das duas linhas deve estar ~6h no futuro (BRT = UTC-3). Reportar ao usuario os novos timestamps de expiracao.

6. **Sem necessidade de reconectar MCP.** O `headersHelper` em `bin/get-ml-headers.ps1` le o token fresco a cada conexao — nao precisa rodar `/mcp` reconnect.
