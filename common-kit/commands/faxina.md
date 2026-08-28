---
description: Faxina periodica anti-acumulo — separa regra viva de diario morto no CLAUDE.md, PROGRESSO.md, DECISOES.md e memorias, sem apagar conhecimento. Mede os tres antes de classificar. Roda ~1x/mes.
---

Faxina de higiene. O objetivo NAO e deletar conhecimento — e separar **regra viva** de **diario morto** nos textos que carregam automatico e acumulam sem dono. A licao: instrucao velha acumulada nao fica neutra, ela degrada as instrucoes futuras (patch contraditorio).

## Escopo (o que auditar)

Os tres, sempre — nenhum depende de o usuario pedir:

1. Do projeto atual (`$CLAUDE_PROJECT_DIR/`): **`CLAUDE.md`, `PROGRESSO.md` e `DECISOES.md`.** Os tres nomes, sempre — nao so o `CLAUDE.md`.
2. Se a invocacao for no nivel do hub (a conversa nao e sobre um projeto especifico), os **mesmos tres** de cada projeto em `projects/*/`.
3. O indice `MEMORY.md` e os arquivos em `memory/` do perfil Claude. **Nao espere o usuario pedir "faxina nas memorias".** O indice carrega em TODA sessao de TODO projeto, entao um gancho podre ali contamina mais que qualquer `CLAUDE.md` de projeto.

🔴 **Copiar pro backup NAO conta como auditar.** O snapshot da secao seguinte toca em todo arquivo do escopo, entao e facil sair da rodada com a sensacao de ter olhado o que so foi copiado. Todo arquivo que entrou no backup tem que sair na tabela da Entrega com um veredito — inclusive "intacto" ou "nao auditado, porque X". Falhou assim em 28/08/2026: 10 `DECISOES.md` foram copiados e nenhum foi aberto; o `/save` vinha avisando havia semanas que dois deles tinham estourado, e a faxina passou por cima calada.

## Regra de seguranca ANTES de tocar em qualquer coisa

Faca um snapshot reversivel primeiro. Ex.: copie os arquivos-alvo para uma pasta `_pre-faxina-backup/` (ou confie no git se o alvo for versionado e estiver limpo). Nunca edite sem rede de seguranca.

## Passo 0 — MEDIR antes de classificar

Nem todo estrago e de conteudo. Tem estrago de **volume** e de **forma**, e o metodo dos 3 baldes abaixo nao enxerga nenhum dos dois — ele so olha o que a frase diz, nunca o tamanho do arquivo nem se a frase terminou. Rode estas medidas primeiro e trate o que aparecer como achado de primeira classe, nao como nota de rodape:

- **Peso do que carrega sozinho.** `wc -c` em cada `CLAUDE.md`, comparados entre si. O arquivo muito fora da curva e o alvo da rodada, mesmo que nenhuma frase dele esteja errada. Meca em BYTES, nao linhas — uma unica linha pode ter 11 mil caracteres.
- 🔴 **Meca os TRES tipos na mesma passada, nunca so o `CLAUDE.md`.** Rode literalmente isto antes de classificar qualquer coisa:
  ```
  wc -c CLAUDE.md projects/*/CLAUDE.md | sort -n
  wc -l projects/*/PROGRESSO.md | sort -n     # teto ~40 linhas (contrato do /save)
  wc -c projects/*/DECISOES.md  | sort -n
  ```
  Os tetos nao sao iguais, porque o custo nao e igual: **`CLAUDE.md` e `PROGRESSO.md` carregam sozinhos no inicio da sessao e por isso TEM TETO**; `DECISOES.md` e `HISTORICO.md` sao **append-only por design** e podem crescer, ja que so entram quando alguem vai ler. Entao:
  - `PROGRESSO.md` **acima de ~40 linhas** = achado de primeira classe, teto estourado, mesmo com todo o conteudo correto.
  - `DECISOES.md` grande **nao e violacao por si so** — audite pelo CONTEUDO (decisao superada ainda parecendo viva). Mas passou de ~150 KB, levante como fila de veredito: **arquivo que ninguem consegue ler inteiro rende o mesmo que arquivo nao escrito**, e a saida e arquivar por periodo (`DECISOES-2026-H1.md`), nunca apagar.
- ⚠️ **Aplique o PRINCIPIO, nao a letra do comando.** A regra e "texto que cresce sem dono tem teto"; a lista de nomes acima e so onde ela costuma morder. Achou no projeto outro arquivo que carrega sozinho ou que virou depositario (um `REFERENCIA.md`, um `NOTAS.md`), meca junto e diga o numero.
- **Confira o que o `/save` anda avisando.** Se o usuario ve um alerta recorrente ao fechar a sessao ("PROGRESSO em N linhas", "DECISOES passou de X"), esse alerta E o achado, ja pre-medido de graca. A faxina que nao o cita esta cega justamente para o que o dono ja enxerga — e o alerta que repete sem consequencia vira paisagem, o mesmo defeito do vigia sem freio.
- **Peso do indice `MEMORY.md`.** Meca em **BYTES** (`wc -c`), nunca em linhas. O teto real e o limite de leitura do arquivo (~24 KB) e a meta de compactacao e **17 KB**; passou de ~14 KB, e achado de primeira classe mesmo com o conteudo todo saudavel. **Contar linha nao serve aqui:** em 31/07/2026 o indice tinha 142 linhas (71% do antigo teto de 200 — "tranquilo") e ja pesava 20,1 KB, acima do limite. A regra de linha nao apitou nenhuma vez enquanto o arquivo estourava.
- **Quebre o peso do indice em 3 partes antes de decidir o corte** — sem isso voce corta no lugar errado. Medido em 31/07/2026: nome dos arquivos **44%**, titulo dos links **34%**, gancho/prosa so **22%**. Ou seja, o texto que da pra reescrever e a menor fatia; o peso mora na quantidade de ENTRADAS. Com 219 memorias, o indice tem um piso de ~15 KB mesmo apagando todo gancho.
- **Linha cortada no meio da frase.** No indice, procure linha que termina em preposicao, artigo ou parentese aberto. Sao ganchos escritos pela metade em sessoes passadas, e o pedaco que faltou costuma ser justamente a conclusao ("Modern Standby nao", "...pages.dev nao"). Reescreva usando o `description:` do proprio arquivo de memoria como fonte.
- **Integridade do indice.** Todo arquivo em `memory/` tem linha no indice? Toda linha aponta pra arquivo que existe? (Ao montar o filtro, lembre que nome de arquivo pode ter maiuscula — filtro so-minusculas gera orfa falsa.)

⚠️ **Agrupar derruba LINHA, quase nao derruba BYTE** — o texto continua todo la, so espremido. Se a medida que estourou foi o PESO, agrupar nao resolve e ainda esconde o problema da proxima rodada (a contagem de linha cai, o arquivo continua gordo). Em 31/07/2026, 37 das 142 linhas ja eram agrupadas, com 239 chars de media contra 106 das simples, carregando 44% do peso do arquivo. Quando o estouro for de peso, o caminho e (1) enxugar gancho que so repete o titulo e (2) com **veredito do dono**, FUNDIR memorias do mesmo assunto num arquivo so — cada memoria a menos tira ~90 bytes do indice (nome + titulo + gancho), enquanto agrupar linha tira quase zero.

**Agrupar nao e apagar.** Pra ganhar espaco no indice, junte memorias do MESMO assunto numa linha so, separadas por ` · ` (padrao que o indice ja usa). Vale pra quirk tecnico complementar — n8n, openclaw, gotcha de maquina. **Nao agrupe feedback de comportamento nem estado de projeto:** enterrar esses numa linha comprida e o oposto do objetivo. Depois de agrupar, prove que nada sumiu — conte os arquivos referenciados antes e depois e mostre o numero.

## Metodo — classifique cada trecho/arquivo em 3 baldes

1. **REGRA VIVA (fica intacta):** quirk tecnico, feedback de comportamento, arquitetura/config atual. E o padrao. Na duvida entre isto e "mista", escolha isto (deixe quieto).

2. **MISTA (enxugar):** uma regra viva grudada em diario datado (datas, "aplicado em", "status APLICADO", "validacao pendente", passo-a-passo, caminhos de backup, narrativa de incidente pontual). Reescreva mantendo a regra viva em 1-3 paragrafos curtos e jogando fora o passo-a-passo datado. Preserve frontmatter e links.

3. **AGLOMERADO / CONTRADICAO / ESTADO DE PROJETO (PARA — veredito humano):**
   - 3+ entradas do mesmo assunto que talvez uma tenha aposentado a outra;
   - duas afirmacoes que se contradizem (ex.: uma diz X, outra diz "X foi refutado");
   - "estado atual do projeto" (onde ele parou hoje) — isso NAO e lixo, pode ser o estado real; so o dono sabe.
   Nesses casos NAO edite. Liste e pergunte ao usuario qual venceu.

## Regras duras

- Na duvida, PARE e pergunte. Nunca corte um fato vivo por engano. Conservador.
- Nunca DELETE um arquivo/memoria — no maximo enxuga o corpo ou arquiva (move pra pasta de arquivo). O dono decide o que some.
- Decisao superada nao se apaga: marca como `[SUPERADA]` (mesmo padrao do /common-kit:save).
- Se for muita coisa, faca em fatias e mostre por amostragem — nao despeje 50 decisoes de uma vez.
- **Nao encerre a rodada com arquivo do escopo sem veredito.** Antes de escrever a Entrega, liste o escopo e cheque um por um. Arquivo grande que voce decidiu nao auditar e uma escolha legitima — desde que apareca dita, com o motivo. O que nao vale e sumir da tabela.

## Entrega

Ao final, apresente um resumo escaneavel: as MEDIDAS do Passo 0 (peso dos arquivos, linhas do indice antes/depois), quantas ENXUGADAS, quantas INTACTAS, e a FILA DE VEREDITO (aglomerados + contradicoes + estado-de-projeto) pra o usuario decidir. As contradicoes ativas sao a prioridade — sao instrucao podre em uso.

🔴 **Tabela de cobertura, obrigatoria.** Antes do resto, uma linha por arquivo do escopo — os `CLAUDE.md`, os `PROGRESSO.md`, os `DECISOES.md` e o `MEMORY.md`. Sem ela nao da pra distinguir "auditei e estava limpo" de "esqueci", e as duas coisas se parecem exatamente igual no relatorio:

| Arquivo | Medida | Veredito |
|---|---|---|
| `projects/x/CLAUDE.md` | 8,0 KB | intacto |
| `projects/x/PROGRESSO.md` | 96 linhas (teto 40) | 🔴 fila de veredito |
| `projects/x/DECISOES.md` | 548 KB | auditado por amostragem — 2 decisoes marcadas `[SUPERADA]` |

Se um arquivo do escopo nao existir no projeto, diga "nao existe" em vez de omitir a linha.

Se uma contradicao puder ser resolvida com evidencia em vez de pergunta (ler o workflow, o codigo, o banco), **resolva e diga qual venceu e como voce sabe**. Fila de veredito e pra o que so o dono sabe, nao pra o que da trabalho conferir.
