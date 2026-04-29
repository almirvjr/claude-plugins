# ml-kit

Plugin local Claude Code para automacao Mercado Libre.

## O que faz

Mantem o servidor MCP do Mercado Libre sempre autenticado com token fresco do Supabase, sem necessidade de reconnect manual.

### 1. `headersHelper` (recomendado)

Aponta o `.mcp.json` para o script `bin/get-ml-headers.ps1`. Esse script roda **toda vez** que o Claude Code abre conexao com o servidor (startup, reconnect via `/mcp`, reconexao automatica), retornando JSON com `Authorization: Bearer <token>` puxado direto do Supabase. Sem janela de token velho, sem reconnect manual.

### 2. Hook `SessionStart` (legado/fallback)

Mantido por compatibilidade. Atualiza o `.mcp.json` no inicio da sessao gravando o Bearer no campo `headers`. Em projetos que ainda nao migraram para `headersHelper`, ele continua funcionando — mas exige `/mcp` reconnect manual quando o Claude Code abre o projeto antes do hook terminar.

### 3. Slash command `/ml-kit:refresh-ml`

Atualiza o token manualmente via hook (modo legado), util quando ainda se usa o campo `headers` em vez de `headersHelper`.

## Requisitos do projeto

Para ambos os modos funcionarem, o projeto precisa ter:

- `.env` com:
  - `SUPABASE_PROJECT_ID=<ref-do-projeto>`
  - `SUPABASE_ANON_KEY=<anon-key>`
- `.mcp.json` com bloco `mcpServers.mercadolibre` usando transport `http`.
- Tabela `public.access_token_ML` com coluna `access_token` (text) e `expires_at` (timestamptz) no Supabase.

Faltando qualquer item, o helper retorna `{}` (e o MCP falha com 401 explicito) e o hook faz early-exit silencioso.

## Configuracao recomendada do `.mcp.json`

```json
{
  "mcpServers": {
    "mercadolibre": {
      "type": "http",
      "url": "https://mcp.mercadolibre.com/mcp",
      "headersHelper": "powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File C:\\Users\\Almir\\claude-plugins\\ml-kit\\bin\\get-ml-headers.ps1"
    }
  }
}
```

> Caminho absoluto do script intencional — `headersHelper` nao expande `${CLAUDE_PLUGIN_ROOT}`.

## Configuracao legada (hook + headers)

```json
{
  "mcpServers": {
    "mercadolibre": {
      "type": "http",
      "url": "https://mcp.mercadolibre.com/mcp",
      "headers": {
        "Authorization": "Bearer <preenchido-pelo-hook>"
      }
    }
  }
}
```

## Atualizacao do plugin

```
/plugin marketplace update almir-plugins
/plugin update ml-kit@almir-plugins
```

Apos atualizar, **rode `/mcp` reconnect uma vez** para que o Claude Code releia a configuracao do `.mcp.json` (so necessario na transicao para o novo plugin).

## Limitacoes

- Funciona apenas no Windows (PowerShell 5.1+).
- `headersHelper` tenta `$env:CLAUDE_PROJECT_DIR` primeiro e cai para `(Get-Location).Path` (PWD) se nao estiver setada — Claude Code spawna o helper com o cwd no projeto, entao funciona em ambos os casos.
- Token ML expira em ~6h. Com `headersHelper` o refresh acontece automaticamente em qualquer reconexao.
