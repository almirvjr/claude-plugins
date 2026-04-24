#requires -Version 5.1
# Atualiza $CLAUDE_PROJECT_DIR/.mcp.json com access_token mais recente da tabela access_token_ML no Supabase.
# Early-exit silencioso se projeto nao tem .env, .mcp.json ou bloco mercadolibre.

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
    Write-Host "[ml-kit] .mcp.json invalido, pulando refresh."
    exit 0
}
if (-not $json.mcpServers -or -not $json.mcpServers.mercadolibre) { exit 0 }

$url = "https://$projectId.supabase.co/rest/v1/access_token_ML?select=access_token,expires_at&order=id.desc&limit=1"
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
    Write-Host "[ml-kit] Nenhum token encontrado em access_token_ML"
    exit 0
}

$token     = $resp[0].access_token
$expiresAt = $resp[0].expires_at
if (-not $token) { exit 0 }

if (-not $json.mcpServers.mercadolibre.headers) {
    $json.mcpServers.mercadolibre | Add-Member -NotePropertyName headers -NotePropertyValue (@{}) -Force
}
$json.mcpServers.mercadolibre.headers | Add-Member -NotePropertyName Authorization -NotePropertyValue "Bearer $token" -Force

$json | ConvertTo-Json -Depth 10 | Set-Content -Path $mcpPath -Encoding utf8

$preview = $token.Substring(0, [Math]::Min(20, $token.Length))
Write-Host "[ml-kit] Token ML atualizado: $preview... Expira: $expiresAt"
exit 0
