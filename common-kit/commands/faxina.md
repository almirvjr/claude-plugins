---
description: Faxina periodica anti-acumulo — separa regra viva de diario morto no CLAUDE.md, DECISOES e memorias, sem apagar conhecimento. Roda ~1x/mes.
---

Faxina de higiene. O objetivo NAO e deletar conhecimento — e separar **regra viva** de **diario morto** nos textos que carregam automatico e acumulam sem dono. A licao: instrucao velha acumulada nao fica neutra, ela degrada as instrucoes futuras (patch contraditorio).

## Escopo (o que auditar)

Os tres, sempre — nenhum depende de o usuario pedir:

1. O `CLAUDE.md` do projeto atual (`$CLAUDE_PROJECT_DIR/CLAUDE.md`) e o `DECISOES.md`.
2. Se a invocacao for no nivel do hub (a conversa nao e sobre um projeto especifico), os `CLAUDE.md` de cada projeto em `projects/*/`.
3. O indice `MEMORY.md` e os arquivos em `memory/` do perfil Claude. **Nao espere o usuario pedir "faxina nas memorias".** O indice carrega em TODA sessao de TODO projeto, entao um gancho podre ali contamina mais que qualquer `CLAUDE.md` de projeto.

## Regra de seguranca ANTES de tocar em qualquer coisa

Faca um snapshot reversivel primeiro. Ex.: copie os arquivos-alvo para uma pasta `_pre-faxina-backup/` (ou confie no git se o alvo for versionado e estiver limpo). Nunca edite sem rede de seguranca.

## Passo 0 — MEDIR antes de classificar

Nem todo estrago e de conteudo. Tem estrago de **volume** e de **forma**, e o metodo dos 3 baldes abaixo nao enxerga nenhum dos dois — ele so olha o que a frase diz, nunca o tamanho do arquivo nem se a frase terminou. Rode estas medidas primeiro e trate o que aparecer como achado de primeira classe, nao como nota de rodape:

- **Peso do que carrega sozinho.** `wc -c` em cada `CLAUDE.md`, comparados entre si. O arquivo muito fora da curva e o alvo da rodada, mesmo que nenhuma frase dele esteja errada. Meca em BYTES, nao linhas — uma unica linha pode ter 11 mil caracteres.
- **Teto de leitura do indice.** `wc -l MEMORY.md` contra o teto de 200 linhas. Passou de ~150 (75%), e hora de agrupar. Isso e achado, mesmo com o conteudo todo saudavel.
- **Linha cortada no meio da frase.** No indice, procure linha que termina em preposicao, artigo ou parentese aberto. Sao ganchos escritos pela metade em sessoes passadas, e o pedaco que faltou costuma ser justamente a conclusao ("Modern Standby nao", "...pages.dev nao"). Reescreva usando o `description:` do proprio arquivo de memoria como fonte.
- **Integridade do indice.** Todo arquivo em `memory/` tem linha no indice? Toda linha aponta pra arquivo que existe? (Ao montar o filtro, lembre que nome de arquivo pode ter maiuscula — filtro so-minusculas gera orfa falsa.)

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

## Entrega

Ao final, apresente um resumo escaneavel: as MEDIDAS do Passo 0 (peso dos arquivos, linhas do indice antes/depois), quantas ENXUGADAS, quantas INTACTAS, e a FILA DE VEREDITO (aglomerados + contradicoes + estado-de-projeto) pra o usuario decidir. As contradicoes ativas sao a prioridade — sao instrucao podre em uso.

Se uma contradicao puder ser resolvida com evidencia em vez de pergunta (ler o workflow, o codigo, o banco), **resolva e diga qual venceu e como voce sabe**. Fila de veredito e pra o que so o dono sabe, nao pra o que da trabalho conferir.
