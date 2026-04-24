# ml-kit

Plugin local Claude Code para automacao Mercado Libre.

## O que faz

- **Hook SessionStart**: ao abrir/retomar sessao, le o `access_token` mais recente da tabela `public.access_token_ML` no Supabase e atualiza `.mcp.json` do projeto com `Authorization: Bearer <token>`.
- **Slash command** `/ml-kit:refresh-ml`: roda o refresh manualmente.

## Requisitos do projeto

Para o hook funcionar, o projeto precisa ter:

- `.env` com:
  - `SUPABASE_PROJECT_ID=<ref-do-projeto>`
  - `SUPABASE_ANON_KEY=<anon-key>`
- `.mcp.json` com bloco `mcpServers.mercadolibre` usando transport `http` (ver `.mcp.json.example` no template de projeto).
- Tabela `public.access_token_ML` com coluna `access_token` (text) e `expires_at` (timestamptz) no Supabase.

Faltando qualquer item, o hook faz early-exit silencioso (nao quebra sessoes em projetos que nao usam ML).

## Instalacao (uso local durante dev)

```bash
claude --plugin-dir C:\Users\Almir\claude-plugins\ml-kit
```

Ou configurar via marketplace (futuro).

## Reload apos edit

Dentro do Claude Code: `/reload-plugins`

## Limitacoes

- Token ML expira em ~6h. Hook dispara apenas em `SessionStart`. Se expirar durante sessao longa, use `/ml-kit:refresh-ml` + `/mcp` reload.
- Requer PowerShell 5.1+ no Windows.
