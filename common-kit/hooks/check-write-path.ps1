$raw = [Console]::In.ReadToEnd()
$json = $raw | ConvertFrom-Json
$path = $json.tool_input.file_path

if (-not $path) { exit 0 }

$normalized = $path.Replace('/', '\')

# Permite qualquer path dentro do projeto atual
$projectDir = $env:CLAUDE_PROJECT_DIR
if ($projectDir -and $normalized.StartsWith($projectDir)) { exit 0 }

# Permite paths utilitarios fora do projeto
$allowedRoots = @(
    'C:\Users\Almir\claude-plugins\',
    'C:\Users\Almir\claude-templates\',
    'C:\Users\Almir\bin\',
    'C:\Users\Almir\.claude\plans\'
)
foreach ($root in $allowedRoots) {
    if ($normalized.StartsWith($root)) { exit 0 }
}

# Permite pasta memory dentro de .claude/projects
if ($normalized.StartsWith('C:\Users\Almir\.claude\projects\') -and $normalized -like '*\memory\*') { exit 0 }

# Nega o resto
@{
    hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        permissionDecision = 'deny'
        permissionDecisionReason = "BLOQUEADO: Write fora do projeto atual. Caminho: '$path'. Projeto atual: '$projectDir'."
    }
} | ConvertTo-Json -Compress
