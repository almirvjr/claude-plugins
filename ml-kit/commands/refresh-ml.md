---
description: Atualiza token ML no .mcp.json com valor fresco da tabela access_token_ML no Supabase
---

Execute o script PowerShell do plugin para atualizar o `.mcp.json` do projeto atual.

Passos:
1. Rode via Bash: `powershell -NoProfile -ExecutionPolicy Bypass -File "$CLAUDE_PLUGIN_ROOT/hooks/refresh-ml-token.ps1"`
   (Se `$CLAUDE_PLUGIN_ROOT` nao resolver, use o caminho absoluto do plugin: `C:\Users\Almir\claude-plugins\ml-kit\hooks\refresh-ml-token.ps1`.)
2. Confirme que a saida mostrou `[ml-kit] Token ML atualizado: ...`
3. Avise o usuario: precisa rodar `/mcp` e desconectar/reconectar o servidor `mercadolibre` para carregar o novo token (ou reiniciar a sessao).
