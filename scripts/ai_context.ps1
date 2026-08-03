$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Read-ShortFile {
    param([string]$Path, [int]$MaxChars = 1800)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
    if ($text.Length -le $MaxChars) {
        return $text
    }
    return $text.Substring(0, $MaxChars) + "`n..."
}

$sections = @()
$sections += "Project AI memory summary:"
$sections += Read-ShortFile (Join-Path $projectRoot "docs\ai_memory.md") 1400
$sections += Read-ShortFile (Join-Path $projectRoot "docs\session_handoff.md") 1800

$latestDecision = Get-ChildItem -LiteralPath (Join-Path $projectRoot "docs\decisions") -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "README.md" } |
    Sort-Object Name -Descending |
    Select-Object -First 1

if ($latestDecision) {
    $sections += "Latest decision:"
    $sections += Read-ShortFile $latestDecision.FullName 1000
}

$latestLesson = Get-ChildItem -LiteralPath (Join-Path $projectRoot "docs\lessons") -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "README.md" } |
    Sort-Object Name -Descending |
    Select-Object -First 2

foreach ($lesson in $latestLesson) {
    $sections += "Recent lesson:"
    $sections += Read-ShortFile $lesson.FullName 900
}

$output = @{
    hookSpecificOutput = @{
        hookEventName = "SessionStart"
        additionalContext = ($sections -join "`n`n")
    }
}

$output | ConvertTo-Json -Depth 4 -Compress

