---
description: Atualiza arquivos de progresso (PROGRESSO, HISTORICO, DECISOES) com base na sessao atual e faz commit automatico.
---

Atualize os arquivos de progresso com base no que foi feito nesta sessao.

Siga estas regras:

1. **Leia o `PROGRESSO.md` atual** antes de modificar (use `$CLAUDE_PROJECT_DIR/PROGRESSO.md`).
2. **Mova tarefas concluidas para `HISTORICO.md`** - qualquer item `[x]` que nao esteja ainda no historico. Nunca apague do HISTORICO.md, apenas acrescente.
3. **Atualize "Proximas Tarefas" no `PROGRESSO.md`** com o que ficou pendente ou foi identificado como proximo passo.
4. **Mantenha o `PROGRESSO.md` enxuto** - maximo ~40 linhas.
5. **Adicione decisoes tecnicas em `DECISOES.md`** - qualquer decisao relevante tomada nesta sessao que ainda nao esteja registrada. Nunca apague entradas existentes.
6. **Nao duplique** - verifique se a informacao ja existe antes de acrescentar.

Apos atualizar os arquivos, execute via Bash (usando `$CLAUDE_PROJECT_DIR` para compatibilidade com qualquer projeto):

```bash
cd "$CLAUDE_PROJECT_DIR" && git add PROGRESSO.md HISTORICO.md DECISOES.md CLAUDE.md REFERENCIA.md 2>/dev/null; git diff --cached --quiet || git commit -m "chore: save session progress [auto]

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

Confirme o que foi alterado e exiba este lembrete:

---
**Lembrete:** houve alguma mudanca estrutural nesta sessao? (novo MCP, nova tabela no Supabase, novo workflow permanente, nova credencial, nova regra de trabalho)
Se sim, atualize o `CLAUDE.md` e/ou `REFERENCIA.md` antes de fechar a sessao.
---
