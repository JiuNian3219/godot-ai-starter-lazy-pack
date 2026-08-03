param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$ProjectName = "",

    [string]$GodotBin = ""
)

$ErrorActionPreference = "Stop"

$templateRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetRoot = [System.IO.Path]::GetFullPath($TargetPath)

if (-not (Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
}

$targetRoot = (Resolve-Path -LiteralPath $targetRoot).Path

if ($targetRoot -eq $templateRoot.Path) {
    throw "TargetPath must not be the template project itself."
}

if (-not $ProjectName) {
    $ProjectName = Split-Path -Leaf $targetRoot
}

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$CommandArgs
    )

    & $Command @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Command $($CommandArgs -join ' ')"
    }
}

function Resolve-SelectedGodot {
    param([string]$CandidatePath)

    if (-not (Test-Path -LiteralPath $CandidatePath)) {
        throw "Godot path does not exist: $CandidatePath"
    }

    $resolvedPath = (Resolve-Path -LiteralPath $CandidatePath).Path
    $version = & $resolvedPath --version 2>$null
    if ($LASTEXITCODE -ne 0 -or -not (($version | Select-Object -First 1).ToString() -match "^4\.6\.")) {
        throw "Godot 4.6.x stable is required. Candidate '$resolvedPath' reported: $($version | Select-Object -First 1)"
    }

    return $resolvedPath
}

$selectedGodotBin = ""
if ($GodotBin) {
    $selectedGodotBin = Resolve-SelectedGodot -CandidatePath $GodotBin
}
elseif ($env:GODOT_BIN) {
    $selectedGodotBin = Resolve-SelectedGodot -CandidatePath $env:GODOT_BIN
}
else {
    Write-Host "Godot selection is required before setup. Compatible candidates discovered by the helper:"
    & powershell -ExecutionPolicy Bypass -File (Join-Path $templateRoot "scripts\find_godot_candidates.ps1")
    throw "Ask the user to confirm one candidate, then rerun with -GodotBin <confirmed path>."
}

$copyItems = @(
    ".claude",
    ".qoder",
    "addons",
    "docs",
    "scenes",
    "scripts",
    "tests",
    ".gitattributes",
    ".gitignore",
    ".mcp.json",
    "AGENTS.md",
    "CLAUDE.md",
    "project.godot"
)

foreach ($item in $copyItems) {
    $source = Join-Path $templateRoot $item
    $dest = Join-Path $targetRoot $item
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $dest -Recurse -Force
    }
}

Get-ChildItem -LiteralPath $targetRoot -Recurse -Filter "*.uid" -ErrorAction SilentlyContinue |
    Remove-Item -Force

$projectFile = Join-Path $targetRoot "project.godot"
$projectText = Get-Content -Raw -Encoding UTF8 -LiteralPath $projectFile
$projectText = $projectText -replace 'config/name="[^"]+"', ('config/name="' + $ProjectName.Replace('"', '') + '"')
Set-Content -LiteralPath $projectFile -Value $projectText -Encoding UTF8

$toolConfigDirectory = Join-Path $targetRoot "tools"
New-Item -ItemType Directory -Force -Path $toolConfigDirectory | Out-Null
Set-Content -LiteralPath (Join-Path $toolConfigDirectory "godot-bin.path") -Value $selectedGodotBin -Encoding UTF8

$handoff = @"
# Session Handoff

Last updated: $(Get-Date -Format "yyyy-MM-dd")

## Current State

- New Godot 4.6.x AI-assisted project scaffolded from the verified template.
- Confirmed Godot path is saved locally in ``tools/godot-bin.path`` and is ignored by Git.
- Godot MCP addon is installed under ``addons/godot_mcp/``.
- Claude project MCP config is in ``.mcp.json``.
- Claude project skills exist for feature implementation, testing, review, and project memory.
- Long-term AI memory exists under ``docs/ai_memory.md``, ``docs/decisions/``, ``docs/lessons/``, and this file.

## Verification

Run:

````powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
````

## Open Risks

- Replace the sample scene/component with your actual first game feature once the project direction is clear.
- Keep checking ``git diff`` and ``scripts/verify.ps1`` after AI-generated changes.

## Next Suggested Task

Write ``docs/game_brief.md`` with the game type, core loop, first playable target, art direction, and explicit non-goals.
"@

Set-Content -LiteralPath (Join-Path $targetRoot "docs\session_handoff.md") -Value $handoff -Encoding UTF8

Push-Location $targetRoot
try {
    if (-not (Test-Path ".git")) {
        Invoke-External git init
    }

    Invoke-External git lfs install

    $env:GODOT_BIN = $selectedGodotBin

    Invoke-External powershell -ExecutionPolicy Bypass -File scripts\verify.ps1

    Write-Host ""
    Write-Host "Template setup complete:" $targetRoot
    Write-Host "Project name:" $ProjectName
    Write-Host ""
    Write-Host "Next commands:"
    Write-Host '  cmd /c "claude mcp get godot"'
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\open_editor.ps1"
    Write-Host "  claude"
}
finally {
    Pop-Location
}
