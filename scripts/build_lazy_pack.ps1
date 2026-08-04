param(
    [string]$OutputRoot = "dist",
    [string]$PackName = "GodotAIStarterLazyPack",
    [switch]$IncludeGodot,
    [string]$GodotBin = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outputRootPath = Join-Path $repoRoot $OutputRoot
$godotVersion = "4.7.1"
$godotFolderName = "Godot-$godotVersion"
$packDirectoryName = if ($IncludeGodot) { "$PackName-Godot-$godotVersion-win64" } else { $PackName }
$packRoot = Join-Path $outputRootPath $packDirectoryName
$templateRoot = Join-Path $packRoot "template"
$zipPath = Join-Path $outputRootPath ($packDirectoryName + ".zip")

if (Test-Path -LiteralPath $packRoot) {
    Remove-Item -Recurse -Force -LiteralPath $packRoot
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -Force -LiteralPath $zipPath
}

New-Item -ItemType Directory -Force -Path $templateRoot | Out-Null
Set-Content -LiteralPath (Join-Path $outputRootPath ".gdignore") -Value "" -Encoding UTF8

function Resolve-BundledGodot {
    param([string]$CandidatePath)

    if (-not $CandidatePath) {
        $CandidatePath = & (Join-Path $repoRoot "scripts\resolve-godot.ps1")
    }

    if (-not (Test-Path -LiteralPath $CandidatePath)) {
        throw "Godot path does not exist: $CandidatePath"
    }

    $resolvedPath = (Resolve-Path -LiteralPath $CandidatePath).Path
    $version = & $resolvedPath --version 2>$null
    $versionText = $version | Select-Object -First 1
    if ($LASTEXITCODE -ne 0 -or -not ($versionText -and ($versionText.ToString() -match "^4\.7\.1\."))) {
        throw "Godot 4.7.1 stable is required for the bundled package. Candidate '$resolvedPath' reported: $versionText"
    }

    return $resolvedPath
}

$copyItems = @(
    ".github",
    ".claude",
    "addons",
    "docs",
    "scenes",
    "scripts",
    "tests",
    ".editorconfig",
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

foreach ($localOnlyDir in @(".git", ".godot", ".tmp", "dist")) {
    $path = Join-Path $templateRoot $localOnlyDir
    if (Test-Path -LiteralPath $path) {
        Remove-Item -Recurse -Force -LiteralPath $path
    }
}

Get-ChildItem -LiteralPath $templateRoot -Recurse -Force -Filter "*.uid" |
    Remove-Item -Force

if ($IncludeGodot) {
    $bundledGodotConsole = Resolve-BundledGodot -CandidatePath $GodotBin
    $bundledGodotSourceDirectory = Split-Path -Parent $bundledGodotConsole
    $bundledGodotTargetDirectory = Join-Path $templateRoot (Join-Path "tools" $godotFolderName)
    New-Item -ItemType Directory -Force -Path $bundledGodotTargetDirectory | Out-Null

    foreach ($engineFile in @(
        "Godot_v4.7.1-stable_win64.exe",
        "Godot_v4.7.1-stable_win64_console.exe"
    )) {
        $sourceEngineFile = Join-Path $bundledGodotSourceDirectory $engineFile
        if (-not (Test-Path -LiteralPath $sourceEngineFile)) {
            throw "Required Godot engine file is missing: $sourceEngineFile"
        }
        Copy-Item -LiteralPath $sourceEngineFile -Destination $bundledGodotTargetDirectory -Force
    }

    $engineHash = (Get-FileHash -LiteralPath (Join-Path $bundledGodotTargetDirectory "Godot_v4.7.1-stable_win64.exe") -Algorithm SHA256).Hash
    $engineManifest = @"
Godot version: 4.7.1.stable.official.a13da4feb
Platform: Windows x64 standard
Official source: https://github.com/godotengine/godot-builds/releases/tag/4.7.1-stable
Engine SHA-256: $engineHash
License: https://github.com/godotengine/godot/blob/4.7.1-stable/LICENSE.txt
"@
    Set-Content -LiteralPath (Join-Path $bundledGodotTargetDirectory "ENGINE_MANIFEST.txt") -Value $engineManifest -Encoding UTF8
}

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
    $versionText = $version | Select-Object -First 1
    if ($LASTEXITCODE -ne 0 -or -not ($versionText -and ($versionText.ToString() -match "^4\.7\.1\."))) {
        throw "Godot 4.7.1 stable is required. Candidate '$resolvedPath' reported: $versionText"
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
if (-not $foundClaude) {
    Write-Host "Claude Code command not found. Setup can continue; use Codex chat or install Claude Code later."
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
    ".github",
    ".claude",
    "addons",
    "docs",
    "scenes",
    "scripts",
    "tests",
    "tools",
    ".editorconfig",
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

$projectGodotBin = $selectedGodotBin
$templateToolsDirectory = Join-Path $templateRoot "tools"
if (Test-Path -LiteralPath $templateToolsDirectory) {
    $resolvedTemplateToolsDirectory = (Resolve-Path -LiteralPath $templateToolsDirectory).Path
    if ($selectedGodotBin.StartsWith($resolvedTemplateToolsDirectory, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativeGodotPath = $selectedGodotBin.Substring($templateRoot.Length).TrimStart("\\")
        $projectGodotBin = Join-Path $targetRoot $relativeGodotPath
    }
}

$toolConfigDirectory = Join-Path $targetRoot "tools"
New-Item -ItemType Directory -Force -Path $toolConfigDirectory | Out-Null
Set-Content -LiteralPath (Join-Path $toolConfigDirectory "godot-bin.path") -Value $projectGodotBin -Encoding UTF8

$handoff = @"
# Session Handoff

Last updated: $(Get-Date -Format "yyyy-MM-dd")

## Current State

- New Godot 4.7.1 AI-assisted project scaffolded from GodotAIStarterLazyPack.
- Confirmed Godot path is saved locally in ``tools/godot-bin.path`` and is ignored by Git.
- Godot MCP addon is installed under ``addons/godot_mcp/``.
- Project MCP config is in ``.mcp.json``.
- AI tool adapters are available: ``.mcp.json`` and ``.claude/skills/``.
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

    $env:GODOT_BIN = $projectGodotBin

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
Godot target: 4.7.1 stable
Bundled engine: $IncludeGodot
MCP server: godot-mcp-server@0.5.0
Optional AI tool entries: Claude Code, Codex chat
"@

Set-Content -LiteralPath (Join-Path $packRoot "VERSION.txt") -Value $version -Encoding UTF8

Compress-Archive -Path (Join-Path $packRoot "*") -DestinationPath $zipPath -Force
$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
$zipHashPath = "$zipPath.sha256"
$zipFileName = Split-Path -Leaf $zipPath
Set-Content -LiteralPath $zipHashPath -Value "$zipHash  $zipFileName" -Encoding ascii -NoNewline

Write-Host "Lazy pack built:" $packRoot
Write-Host "Zip:" $zipPath
Write-Host "SHA-256:" $zipHashPath
exit 0

