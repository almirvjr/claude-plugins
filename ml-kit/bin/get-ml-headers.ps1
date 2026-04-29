#requires -Version 5.1
# get-ml-headers.ps1
#
# Imprime no stdout um JSON com os headers HTTP a serem usados pela conexao MCP do
# Mercado Libre (campo `headersHelper` no .mcp.json). Le o access_token mais recente
# da tabela public.access_token_ML do Supabase usando credenciais do .env do projeto.
#
# Roda em todo conexao/reconexao MCP, garantindo token sempre fresco sem necessidade
# de editar .mcp.json ou rodar /mcp reconnect manualmente.
#
# Em qualquer falha (sem .env, .env incompleto, Supabase off, sem token), imprime "{}"
# para que o Claude Code conecte sem header e o erro seja explicito (HTTP 401).

$ErrorActionPreference = 'Stop'

function Emit-Empty {
    Write-Output '{}'
    exit 0
}

$projectRoot = $env:CLAUDE_PROJECT_DIR
if (-not $projectRoot) { Emit-Empty }

$envPath = Join-Path $projectRoot '.env'
if (-not (Test-Path $envPath)) { Emit-Empty }

# Parse .env simples (KEY=VALUE, ignora comentarios e linhas vazias)
$envVars = @{}
Get-Content $envPath | ForEach-Object {
    if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

$projectId = $envVars['SUPABASE_PROJECT_ID']
$anonKey   = $envVars['SUPABASE_ANON_KEY']
if (-not $projectId -or -not $anonKey) { Emit-Empty }

$url = "https://$projectId.supabase.co/rest/v1/access_token_ML?select=access_token&order=id.desc&limit=1"
$headers = @{
    'apikey'        = $anonKey
    'Authorization' = "Bearer $anonKey"
    'Accept'        = 'application/json'
}

try {
    $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 15
} catch {
    Emit-Empty
}

if (-not $resp -or $resp.Count -eq 0) { Emit-Empty }

$token = $resp[0].access_token
if (-not $token) { Emit-Empty }

$result = @{ Authorization = "Bearer $token" } | ConvertTo-Json -Compress
Write-Output $result
exit 0
