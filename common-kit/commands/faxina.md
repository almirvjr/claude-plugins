---
description: Faxina periodica anti-acumulo — separa regra viva de diario morto no CLAUDE.md, DECISOES e memorias, sem apagar conhecimento. Roda ~1x/mes.
---

Faxina de higiene. O objetivo NAO e deletar conhecimento — e separar **regra viva** de **diario morto** nos textos que carregam automatico e acumulam sem dono. A licao: instrucao velha acumulada nao fica neutra, ela degrada as instrucoes futuras (patch contraditorio).

## Escopo (o que auditar)

1. O `CLAUDE.md` do projeto atual (`$CLAUDE_PROJECT_DIR/CLAUDE.md`) e o `DECISOES.md`.
2. Se o usuario pedir "faxina nas memorias", auditar tambem o hub: o indice `MEMORY.md` e os arquivos em `memory/` do perfil Claude.

## Regra de seguranca ANTES de tocar em qualquer coisa

Faca um snapshot reversivel primeiro. Ex.: copie os arquivos-alvo para uma pasta `_pre-faxina-backup/` (ou confie no git se o alvo for versionado e estiver limpo). Nunca edite sem rede de seguranca.

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

Ao final, apresente um resumo escaneavel: quantas ENXUGADAS, quantas INTACTAS, e a FILA DE VEREDITO (aglomerados + contradicoes + estado-de-projeto) pra o usuario decidir. As contradicoes ativas sao a prioridade — sao instrucao podre em uso.
