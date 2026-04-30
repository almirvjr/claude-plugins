#requires -Version 5.1
# Loga status do access_token ML pre-venda no SessionStart.
#
# IMPORTANTE: este hook NAO escreve em .mcp.json. Antigamente (v1.0-v1.3) ele
# atualizava o campo headers.Authorization, mas isso conflita com o
# headersHelper (introduzido em v1.1, que ja faz leitura ao vivo do Supabase
# em toda conexao MCP) — o headers literal ficava cacheado com token antigo
# enquanto o headersHelper era ignorado, derrubando o MCP em ~6h.
#
# A partir de v1.4, este hook so consulta o token e loga status. headersHelper
# eh fonte unica de verdade para o Authorization. .mcp.json so deve ter
# headersHelper, sem o campo headers.

$ErrorActionPreference = 'Stop'

$projectRoot = $env:CLAUDE_PROJECT_DIR
if (-not $projectRoot) { exit 0 }

$envPath = Join-Path $projectRoot '.env'
$mcpPath = Join-Path $projectRoot '.mcp.json'

if (-not (Test-Path $envPath)) { exit 0 }
if (-not (Test-Path $mcpPath)) { exit 0 }

# Parse .env simples
$envVars = @{}
Get-Content $envPath | ForEach-Object {
    if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

$projectId = $envVars['SUPABASE_PROJECT_ID']
$anonKey   = $envVars['SUPABASE_ANON_KEY']
if (-not $projectId -or -not $anonKey) { exit 0 }

# Checa se .mcp.json tem bloco mercadolibre
try {
    $json = Get-Content $mcpPath -Raw | ConvertFrom-Json
} catch {
    exit 0
}
if (-not $json.mcpServers -or -not $json.mcpServers.mercadolibre) { exit 0 }

# Aviso se o usuario ainda tem campo `headers` literal no .mcp.json. Sem
# remover, o Claude Code prioriza-o em vez do headersHelper e o token
# cacheado vence em ~6h.
if ($json.mcpServers.mercadolibre.headers) {
    Write-Host "[ml-kit] AVISO: .mcp.json ainda tem 'headers' literal no bloco mercadolibre. Remova esse campo — apenas 'headersHelper' deve ser usado."
}

# Filtra app_name=pre-venda: ver comentario em bin/get-ml-headers.ps1.
$url = "https://$projectId.supabase.co/rest/v1/access_token_ML?select=access_token,expires_at&app_name=eq.pre-venda&order=id.desc&limit=1"
$headers = @{
    'apikey'        = $anonKey
    'Authorization' = "Bearer $anonKey"
    'Accept'        = 'application/json'
}

try {
    $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 15
} catch {
    Write-Host "[ml-kit] Falha ao consultar Supabase: $_"
    exit 0
}

if (-not $resp -or $resp.Count -eq 0) {
    Write-Host "[ml-kit] Nenhum token encontrado em access_token_ML (app_name=pre-venda)"
    exit 0
}

$token     = $resp[0].access_token
$expiresAt = $resp[0].expires_at
if (-not $token) { exit 0 }

$preview = $token.Substring(0, [Math]::Min(20, $token.Length))
Write-Host "[ml-kit] Token ML pre-venda: $preview... Expira: $expiresAt (headersHelper resolve em cada conexao)"
exit 0
