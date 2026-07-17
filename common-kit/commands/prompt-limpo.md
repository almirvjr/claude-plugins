---
description: Higiene de prompt (estrutura da Margot/Anthropic) — reorganiza um prompt guardado em secoes claras, tira remendo contraditorio, define contrato de saida. Para prompts de producao/reusados, NAO para chat na CLI.
---

Aplica a estrutura de prompt limpa (da palestra "The prompting playbook", Anthropic) a um prompt GUARDADO e REUSADO — ex.: prompt de agente que atende cliente, AGENTS.md de subagente, prompt de classificador. NAO e para o bate-papo na CLI: ali o ajuste e em tempo real e nao precisa disto.

**Principio-base:** instrucao nao adiciona capacidade. Reorganizar e CORTAR o prompt melhora o resultado; empilhar mais instrucao geralmente piora. Modelos novos seguem instrucao melhor, entao remendo velho vira overfit e comeca a atrapalhar.

## Regra de seguranca ANTES de editar

Prompt de producao (atende cliente ou roda sozinho) = blast-radius medio/alto. Faca snapshot/versao do prompt atual ANTES de mexer, e NAO substitua sem o veredito do dono. Voce propoe o diff; o dono decide.

## Modo A — limpar um prompt existente

1. **Leia o prompt inteiro** primeiro.
2. **Separe em secoes marcadas** (tags XML ou cabecalhos claros): papel, diretrizes, politica, dados, tom, formato de saida. Regra da Margot: se voce nao distingue diretriz de politica de dado, o modelo tambem nao.
3. **Tire lixo** — texto copiado de site, referencia orfa, instrucao duplicada.
4. **Cace remendo defensivo e lista-de-proibicao** ("nunca faca X", "sempre faca Y"). Troque a proibicao unilateral pelos DOIS LADOS do trade-off (o custo E o beneficio) — senao o modelo faz overfit a um lado. Politica/decisao superada: marque como superada, nao deixe de igual pra igual com a nova (mesmo padrao do /common-kit:save e /common-kit:faxina).
5. **Defina o contrato de saida** — o formato exato que voce quer de volta. Se a saida for estruturada (JSON, XML), sugira structured output / stop sequence pra travar o formato.
6. **Instrucao que pede capacidade que o modelo nao tem** (fazer conta, buscar dado externo, executar acao) -> proponha uma FERRAMENTA, nao uma instrucao mais forte.
7. **Mostre o diff** (o que saiu / o que ficou / por que) e peca o veredito. Nunca reescreva calado.
8. **Prove com eval, se houver** — rode os casos de teste antes e depois pra confirmar que melhorou (ou ao menos nao piorou). Se nao houver eval, avise que a mudanca vai sem rede.

## Modo B — montar um prompt novo

Comece ja com as secoes marcadas + contrato de saida. Sem ban-list. Ferramenta > instrucao. O minimo necessario; adicione so o que um caso de falha observado provar que precisa — nao encha por precaucao.

## Nao faca

- Nao invente politica/regra que nao existe no prompt original — voce reorganiza e EXPOE contradicao; quem decide o conteudo e o dono.
- Nao aplique isto ao chat da CLI nem a prompt de uso unico — e desperdicio. E so para prompt guardado e reusado.

**Entrega:** prompt reorganizado (ou proposta de diff), a lista do que era remendo contraditorio, e o contrato de saida explicito. As decisoes de conteudo ficam pro dono.
