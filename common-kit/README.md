# common-kit

Plugin local Claude Code com utilitarios compartilhados entre projetos.

## O que faz

- **Hook PreToolUse (Write)**: bloqueia escrita de arquivos fora do projeto atual (`$CLAUDE_PROJECT_DIR`) ou de paths permitidos (`~/claude-plugins/`, `~/claude-templates/`, `~/bin/`, memoria/plans do Claude). Previne lixo espalhado pelo disco.
- **Slash command** `/common-kit:save`: atualiza `PROGRESSO.md`/`HISTORICO.md`/`DECISOES.md` e faz commit automatico ("chore: save session progress [auto]").

## Instalacao (dev)

```bash
claude --plugin-dir C:\Users\Almir\claude-plugins\common-kit
```

Combinar com outros plugins:
```bash
claude --plugin-dir C:\Users\Almir\claude-plugins\ml-kit --plugin-dir C:\Users\Almir\claude-plugins\common-kit
```

## Reload apos edit

`/reload-plugins`
