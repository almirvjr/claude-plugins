# common-kit

Plugin local Claude Code com utilitarios compartilhados entre projetos.

## O que faz

- **Slash command** `/common-kit:save`: atualiza `PROGRESSO.md`/`HISTORICO.md`/`DECISOES.md` e faz commit automatico ("chore: save session progress [auto]").

A protecao de writes fora do projeto fica por conta do hook global em `~/.claude/hooks/check-write-path.ps1` (configurado em `~/.claude/settings.json`), nao deste plugin.

## Instalacao via marketplace

```shell
/plugin marketplace add almirvjr/claude-plugins
/plugin install common-kit@almir-plugins
```

## Reload apos edit

`/reload-plugins`
