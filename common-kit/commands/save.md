---
description: Atualiza arquivos de progresso (PROGRESSO, HISTORICO, DECISOES) com base na sessao atual, faz commit automatico e pergunta se grava o codigo da sessao em commit separado.
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
8. **Grave os tropecos da sessao** (blocos `🧩 Tropecos:` e qualquer erro/retrabalho que nao virou bloco). Filtro: so grava o que VOLTARIA a acontecer numa sessao futura - tropeco de uma vez so morre aqui. Cada um vai pro lugar certo: memoria (vale pra varios projetos), `CLAUDE.md`/`MEMORIA-OPERACIONAL.md` do projeto (so daquele projeto) ou a propria skill (o erro foi da skill). Grave a LICAO GERAL, nao so o caso: corrigir o caso ("na VPS nao ha plugin") nao evita o proximo erro parecido; a licao ("conferir a outra maquina antes de mandar rodar") evita. Item marcado `(ja gravado em …)` no bloco: confira que o registro existe e cobre a licao geral - se so cobre o caso, complete. Procure registro existente antes e atualize em vez de duplicar. No fim, liste o que gravou e onde; se nada passou no filtro, diga "nenhum tropeco recorrente". Este passo vale mesmo fora de repo git (o script abaixo pode falhar, este nao).

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

**O script acima versiona so os arquivos de progresso.** Codigo nunca entra nesse commit nem
vai sozinho: no fim da sessao ele pode estar pela metade, e o repo pode ser compartilhado ou
publico. Por isso, depois do script:

9. **Codigo que ficou de fora = UMA pergunta, e com o "sim" um commit SEPARADO.**
   - Liste o que sobrou: `git status --porcelain` (arquivo alterado e arquivo novo).
     Nada sobrou → pule este passo calado.
   - Antes de perguntar, confira:
     - **visibilidade** do repo (`gh repo view --json visibility -q .visibility`) e se ele e
       compartilhado com outra pessoa (memoria/CLAUDE.md do projeto dizem). Publico ou
       compartilhado entra na pergunta, em destaque;
     - **lixo e segredo**: arquivo de depuracao, resposta de API salva, `.env`, `.tmp*`,
       dump, captura de tela. Esses ficam FORA da lista, e voce diz quais deixou de fora e por que.
       Procure tambem senha, token, chave e CPF no diff;
     - **se o codigo esta pronto**: testes rodados nesta sessao? Se nao, ou se algum falhou,
       diga isso na pergunta.
   - Pergunte UMA vez (AskUserQuestion), mostrando a lista de arquivos e o que a mudanca faz
     em uma frase: "Gravo o codigo tambem?". Sem resposta clara de sim → nao grava.
   - Com o "sim": `git add -- <cada arquivo da lista, pelo nome>` (nunca `git add -A` nem
     `git add .`), commit **proprio**, com mensagem que descreve a mudanca (`feat(...)`,
     `fix(...)`, nunca o `chore: save session progress`), o mesmo trailer de co-autoria, e
     push. Confira o commit novo com `git log -1`, como acima.
   - Com o "nao": diga que o codigo ficou sem commit e liste os arquivos.

Confirme o que foi alterado e exiba este lembrete:

---
**Lembrete:** houve alguma mudanca estrutural nesta sessao? (novo MCP, nova tabela no Supabase, novo workflow permanente, nova credencial, nova regra de trabalho)
Se sim, atualize o `CLAUDE.md` e/ou `REFERENCIA.md` - e ao fazer isso, REMOVA o que ficou obsoleto (nao so acrescente).

**Faxina periodica (a cada ~1 mes, ou quando CLAUDE.md / DECISOES passar do razoavel):** releia CLAUDE.md e DECISOES procurando (a) decisao superada ainda parecendo viva, (b) 3 ou mais entradas do mesmo assunto que deviam virar uma so, (c) fato datado que ja nao e regra. Enxugue.
---
