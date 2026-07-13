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
# push automatico do que foi commitado (nao falha a sessao se nao houver remote/upstream/auth)
git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 \
  && git -C "$CLAUDE_PROJECT_DIR" push --quiet && echo "✅ git push ok" \
  || echo "⚠️ git push nao feito (sem upstream/remote/auth) — rode 'git push' manual se necessario"
```

Confirme o que foi alterado e exiba este lembrete:

---
**Lembrete:** houve alguma mudanca estrutural nesta sessao? (novo MCP, nova tabela no Supabase, novo workflow permanente, nova credencial, nova regra de trabalho)
Se sim, atualize o `CLAUDE.md` e/ou `REFERENCIA.md` antes de fechar a sessao.
---
