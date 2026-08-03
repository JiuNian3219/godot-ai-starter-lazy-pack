param(
    [string]$OutputRoot = "dist",
    [string]$PackName = "GodotAIStarterLazyPack"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outputRootPath = Join-Path $repoRoot $OutputRoot
$packRoot = Join-Path $outputRootPath $PackName
$templateRoot = Join-Path $packRoot "template"
$zipPath = Join-Path $outputRootPath ($PackName + ".zip")

if (Test-Path -LiteralPath $packRoot) {
    Remove-Item -Recurse -Force -LiteralPath $packRoot
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -Force -LiteralPath $zipPath
}

New-Item -ItemType Directory -Force -Path $templateRoot | Out-Null
Set-Content -LiteralPath (Join-Path $outputRootPath ".gdignore") -Value "" -Encoding UTF8

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
    $source = Join-Path $repoRoot $item
    $dest = Join-Path $templateRoot $item
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $dest -Recurse -Force
    }
}

foreach ($localOnlyDir in @(".git", ".godot", ".tmp", "tools", "dist")) {
    $path = Join-Path $templateRoot $localOnlyDir
    if (Test-Path -LiteralPath $path) {
        Remove-Item -Recurse -Force -LiteralPath $path
    }
}

Get-ChildItem -LiteralPath $templateRoot -Recurse -Force -Filter "*.uid" |
    Remove-Item -Force

$installScript = @'
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$ProjectName = "",

    [string]$GodotBin = "",

    [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"

$packRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$templateRoot = Join-Path $packRoot "template"

if (-not (Test-Path -LiteralPath $templateRoot)) {
    throw "Template folder not found: $templateRoot"
}

$targetRoot = [System.IO.Path]::GetFullPath($TargetPath)
if (-not (Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
}
$targetRoot = (Resolve-Path -LiteralPath $targetRoot).Path

if ($targetRoot -eq (Resolve-Path -LiteralPath $templateRoot).Path) {
    throw "TargetPath must not be the pack template folder."
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

function Assert-Command {
    param([string]$Name)

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required command not found: $Name"
    }
    Write-Host "Found ${Name}:" $cmd.Source
}

function Show-OptionalCommandVersion {
    param(
        [string]$Name,
        [string]$Label
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Host "Optional ${Label} command not found."
        return $false
    }

    Write-Host "Found optional ${Label}:" $cmd.Source
    & $Name --version
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Optional ${Label} exists, but '--version' did not exit cleanly. Continuing."
    }
    return $true
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

Write-Host "Checking required tools..."
foreach ($requiredCommand in @("git", "git-lfs", "node", "npm", "npx")) {
    Assert-Command $requiredCommand
}

Invoke-External git --version
Invoke-External git-lfs version
Invoke-External node --version
Invoke-External npm --version
Invoke-External npx --version

Write-Host "Checking optional AI tools..."
$foundClaude = Show-OptionalCommandVersion -Name "claude" -Label "Claude Code"
$foundQoder = Show-OptionalCommandVersion -Name "qodercn" -Label "QoderCN"
if (-not $foundQoder) {
    $foundQoder = Show-OptionalCommandVersion -Name "qoderclicn" -Label "QoderCN CLI"
}
if (-not $foundQoder) {
    $foundQoder = Show-OptionalCommandVersion -Name "qoder" -Label "Qoder"
}
if (-not $foundQoder) {
    $foundQoder = Show-OptionalCommandVersion -Name "qodercli" -Label "Qoder CLI"
}

if (-not $foundClaude -and -not $foundQoder) {
    Write-Host "No Claude Code or QoderCN/Qoder command found. Setup can continue; use Codex chat or install an AI CLI later."
}

$selectedGodotBin = ""
if ($GodotBin) {
    $selectedGodotBin = Resolve-SelectedGodot -CandidatePath $GodotBin
}
elseif ($env:GODOT_BIN) {
    $selectedGodotBin = Resolve-SelectedGodot -CandidatePath $env:GODOT_BIN
}
else {
    Write-Host "Godot selection is required before installation. Compatible candidates discovered by the helper:"
    & powershell -ExecutionPolicy Bypass -File (Join-Path $templateRoot "scripts\find_godot_candidates.ps1")
    throw "Ask the user to confirm one candidate, then rerun install.ps1 with -GodotBin <confirmed path>."
}

Write-Host "Using confirmed Godot:" $selectedGodotBin

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

- New Godot 4.6.x AI-assisted project scaffolded from GodotAIStarterLazyPack.
- Confirmed Godot path is saved locally in ``tools/godot-bin.path`` and is ignored by Git.
- Godot MCP addon is installed under ``addons/godot_mcp/``.
- Project MCP config is in ``.mcp.json``.
- AI tool adapters are available: ``.mcp.json``, ``.claude/skills/``, and ``.qoder/``.
- Shared project rules are available under ``AGENTS.md`` and ``docs/``.
- Long-term AI memory exists under ``docs/ai_memory.md``, ``docs/decisions/``, ``docs/lessons/``, and this file.

## Verification

Run:

````powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
````

## Open Risks

- Replace the sample scene/component with your actual first game feature once the project direction is clear.
- Keep checking ``git diff`` and ``scripts/verify.ps1`` after AI-generated changes.
- Pick only one active writing agent per task.

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

    if (-not $SkipVerify) {
        Invoke-External powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
    }

    Write-Host ""
    Write-Host "Godot AI project setup complete:" $targetRoot
    Write-Host "Project name:" $ProjectName
    Write-Host ""
    Write-Host "Next commands:"
    Write-Host '  powershell -ExecutionPolicy Bypass -File scripts\open_editor.ps1'
    Write-Host '  cmd /c "claude mcp get godot"    # optional adapter check'
    Write-Host '  qodercn                            # optional AI tool entry'
    Write-Host '  Open Codex chat in this folder      # optional AI tool entry'
}
finally {
    Pop-Location
}
'@

Set-Content -LiteralPath (Join-Path $packRoot "install.ps1") -Value $installScript -Encoding UTF8

$readme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot "docs\lazy_pack_README_CN.md")

Set-Content -LiteralPath (Join-Path $packRoot "README_CN.md") -Value $readme -Encoding UTF8

$version = @"
Name: $PackName
Built: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Godot target: 4.6.x stable
MCP server: godot-mcp-server@0.5.0
Optional AI tool entries: Claude Code, QoderCN/Qoder, Codex chat
"@

Set-Content -LiteralPath (Join-Path $packRoot "VERSION.txt") -Value $version -Encoding UTF8

Compress-Archive -Path (Join-Path $packRoot "*") -DestinationPath $zipPath -Force

Write-Host "Lazy pack built:" $packRoot
Write-Host "Zip:" $zipPath
exit 0

