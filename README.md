# almir-plugins

Marketplace privado de plugins Claude Code para automacao n8n/ML/Supabase.

## Plugins

| Plugin | O que faz |
|--------|-----------|
| [ml-kit](./ml-kit/) | Atualiza token Mercado Libre no `.mcp.json` do projeto automaticamente no SessionStart |
| [common-kit](./common-kit/) | `/save` para commits automaticos de progresso + hook que protege writes fora do projeto |

## Instalacao

### Via marketplace local (dev)

```shell
/plugin marketplace add C:\Users\Almir\claude-plugins
/plugin install ml-kit@almir-plugins
/plugin install common-kit@almir-plugins
```

### Via GitHub (quando publicado)

```shell
/plugin marketplace add almir/claude-plugins
/plugin install ml-kit@almir-plugins
```

## Atualizar

```shell
/plugin marketplace update almir-plugins
```

## Desenvolvimento

Cada plugin tem sua propria pasta. Editar arquivos e rodar `/reload-plugins` no Claude Code.

Para testar sem instalar via marketplace:
```bash
claude --plugin-dir C:\Users\Almir\claude-plugins\ml-kit
```
