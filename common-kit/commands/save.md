---
description: Atualiza arquivos de progresso (PROGRESSO, HISTORICO, DECISOES) com base na sessao atual e faz commit automatico.
---

Atualize os arquivos de progresso com base no que foi feito nesta sessao.

Siga estas regras:

1. **Leia o `PROGRESSO.md` atual** antes de modificar (use `$CLAUDE_PROJECT_DIR/PROGRESSO.md`).
2. **Mova tarefas concluidas para `HISTORICO.md`** - qualquer item `[x]` que nao esteja ainda no historico. Nunca apague do HISTORICO.md, apenas acrescente.
3. **Atualize "Proximas Tarefas" no `PROGRESSO.md`** com o que ficou pendente ou foi identificado como proximo passo.
4. **Mantenha o `PROGRESSO.md` enxuto** - maximo ~40 linhas.
5. **Adicione decisoes tecnicas em `DECISOES.md`** - qualquer decisao relevante tomada nesta sessao que ainda nao esteja registrada. Nunca apague entradas existentes. **Se uma decisao desta sessao REVERTE ou SUBSTITUI uma anterior, nao deixe as duas de igual pra igual:** marque a antiga como superada - prefixe a linha antiga com `[SUPERADA AAAA-MM-DD -> ver abaixo]` e registre a nova logo em seguida com o porque. Uma decisao morta que continua parecendo viva vira patch contraditorio e degrada as instrucoes futuras.
6. **Nao duplique** - verifique se a informacao ja existe antes de acrescentar.
7. **Regra de ouro anti-acumulo:** arquivo que carrega automatico no inicio da sessao (CLAUDE.md, PROGRESSO.md) tem TETO e fica enxuto - ao ADICIONAR algo, olhe no mesmo movimento se ha linha velha/superada pra TIRAR. CLAUDE.md e regra viva, nao diario. Arquivos append-only (HISTORICO, DECISOES) sao ARQUIVO: so crescem porque nao carregam automatico no inicio da sessao.

Apos atualizar os arquivos, execute via Bash o script abaixo.

**Troque `<CO-AUTOR>` pelo trailer de co-autoria do SEU modelo atual** (o que o ambiente/CLAUDE.md
define). Nao deixe nome de modelo fixo aqui: commit assinado pelo modelo errado e atribuicao falsa.

```bash
# 1) Descobrir a pasta do projeto. $CLAUDE_PROJECT_DIR nem sempre vem preenchido
#    (em hub com subprojetos, por exemplo). `cd ""` NAO da erro no bash — sem esta
#    guarda o script rodaria na pasta errada e diria que salvou.
DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
if [ -z "$DIR" ] || [ ! -d "$DIR/.git" ]; then
  echo "❌ Nao achei a raiz do repo (CLAUDE_PROJECT_DIR vazio e cwd fora de repo git). NADA foi commitado."
  echo "   Rode de dentro do projeto, ou passe a pasta certa na mao."
  exit 1
fi
cd "$DIR" || exit 1
echo "📁 projeto: $DIR"

# 2) Adicionar SO o que existe. `git add a.md b.md` aborta a lista INTEIRA se um
#    dos nomes nao existir — era o bug: projeto sem REFERENCIA.md nao commitava nada,
#    e o `2>/dev/null` original escondia o erro.
for f in PROGRESSO.md HISTORICO.md DECISOES.md CLAUDE.md REFERENCIA.md; do
  [ -f "$f" ] && git add -- "$f"
done

# 3) Commit — dizendo em voz alta quando NAO ha o que commitar.
if git diff --cached --quiet; then
  echo "ℹ️ Nenhuma mudanca nos arquivos de progresso — nenhum commit criado."
else
  git commit -q -m "chore: save session progress [auto]

Co-Authored-By: <CO-AUTOR>" && echo "✅ commit: $(git log --pretty='%h %s' -1)"
fi

# 4) Push (nao derruba a sessao se nao houver remote/upstream/auth).
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push --quiet && echo "✅ git push ok" || echo "⚠️ git push falhou — rode 'git push' manual"
else
  echo "⚠️ sem upstream — commit ficou local"
fi
```

**Confira o resultado antes de dizer que salvou:** o commit tem que ser NOVO (`git log -1`
mostrando a mensagem e o horario de agora). Push "ok" sem commit novo so quer dizer que nao
havia nada pra enviar — nao que salvou.

**Este comando versiona so os arquivos de progresso.** Codigo alterado na sessao continua sem
commit de proposito. Se houver, diga isso ao usuario no fim e ofereca commitar em separado.

Confirme o que foi alterado e exiba este lembrete:

---
**Lembrete:** houve alguma mudanca estrutural nesta sessao? (novo MCP, nova tabela no Supabase, novo workflow permanente, nova credencial, nova regra de trabalho)
Se sim, atualize o `CLAUDE.md` e/ou `REFERENCIA.md` - e ao fazer isso, REMOVA o que ficou obsoleto (nao so acrescente).

**Faxina periodica (a cada ~1 mes, ou quando CLAUDE.md / DECISOES passar do razoavel):** releia CLAUDE.md e DECISOES procurando (a) decisao superada ainda parecendo viva, (b) 3 ou mais entradas do mesmo assunto que deviam virar uma so, (c) fato datado que ja nao e regra. Enxugue.
---
