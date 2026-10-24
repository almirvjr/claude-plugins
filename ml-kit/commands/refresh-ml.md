---
description: Confere e (se preciso) forca o refresh do access_token ML - pre-venda e pos-venda
---

Renova os tokens do Mercado Livre. **Desde 12/10 (pos-venda) e 14/10/2026 (pre-venda) quem renova e o
Supabase, nao o n8n:** a Edge Function `renovar-acesso`, chamada pelo `pg_cron` de 10 em 10 min, renova
quando faltam <=90 min. O refresh manual e excecao.

Os workflows antigos do n8n (`KOblYJST7loNVAqP` pre, `qwHoWOpBcRGUgb7k` pos) estao **DESLIGADOS** e ficam
so como volta-atras. **Nao religue nem rode na mao** — renovariam por fora da trava do Supabase.
Diario: `.claude-hub/plans/2026-10-08-piloto-n8n-para-supabase-renovacao-acesso.md`.

## ⚠️ Renovar token NAO e idempotente

Cada renovacao **queima o `refresh_token` anterior**; duas ao mesmo tempo derrubam o acesso. Por isso
renovar so passa pela Edge Function: ela tem trava no banco (a segunda desiste com `trava_ocupada`) e o
`forcar` so vale se a ultima renovacao daquele acesso tiver mais de 10 min.

## Passo 1 — Descartar o alarme falso ANTES de culpar o token

1. **`get-ml-headers.ps1` devolveu `{}` calado?** Ele le o `.env` de `$env:CLAUDE_PROJECT_DIR` (ou do cwd).
   Na raiz do hub (`~/workspace`, sem `.env`) ele imprime `{}` sem erro. **Isso nao e token expirado.**
   ```powershell
   $env:CLAUDE_PROJECT_DIR = 'C:\Users\Almir\workspace\projects\reposicao'
   ```
2. **So o banco diz se o token morreu.** `select app_name, expires_at from public."access_token_ML";`
   (MAIUSCULAS = aspas). Vale ~6h; BRT = UTC-3. No futuro = vivo, o problema e outro.

## Passo 2 — Ver se o relogio do Supabase esta rodando

```sql
select quando, alvo, resultado, detalhe from ops.execucoes
where rotina = 'renovar-acesso' and alvo in ('ml-pre','ml-pos') order by quando desc limit 10;
select acesso, ligado, falhas_seguidas, ultima_renovacao_em from ops.renovacao_acesso;
```
Esperado: rodada a cada 10 min (`nao_precisou` / `renovou`), `ligado=true`, `falhas_seguidas=0`.
`falhou` = o `detalhe` diz o motivo (ex.: 429 do ML e passageiro, a rodada seguinte costuma renovar).
Painel para o Almir: app da reposicao → botao **Rotinas**.

## Passo 3 — Forcar (so se o passo 1 provou que precisa)

O agente consegue sozinho, pelo MCP do Supabase (sem segredo no terminal):
```sql
select ops.chamar_funcao('renovar-acesso', '{"acesso":"ml-pre","forcar":true,"origem":"refresh-ml"}'::jsonb);
```
Troque `ml-pre` por `ml-pos`. **Um acesso por vez, uma vez so.** A chamada e assincrona (devolve so um
numero de pedido); espere ~10 s e confira o Passo 4.

## Passo 4 — Confirmar

Releia o Passo 2: deve aparecer `renovou` com `[refresh-ml] forçado; ...`. Releia `expires_at`: ~6h no
futuro. Se veio `nao_precisou` com `forcar`, e porque renovou ha menos de 10 min — o token ja esta fresco.
**Nao precisa reconectar MCP** — o `get-ml-headers.ps1` le o token fresco a cada conexao.

## Notas

- **NAO chame `hooks/refresh-ml-token.ps1`.** Desde a v1.4 ele so loga status.
- O `Vigia de Expiracao` do n8n (`Fg4QCGUH8961q2Nw`) **nao renova mais** pre nem pos-venda (condicoes
  `nao-pos-venda-supabase` / `nao-pre-venda-supabase` no IF); continua **so avisando** se faltar <=30 min.
