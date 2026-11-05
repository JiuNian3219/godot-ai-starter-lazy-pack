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
    $versionText = $version | Select-Object -First 1
    if ($LASTEXITCODE -ne 0 -or -not ($versionText -and ($versionText.ToString() -match "^4\.7\.1\."))) {
        throw "Godot 4.7.1 stable is required. Candidate '$resolvedPath' reported: $versionText"
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

& (Join-Path $PSScriptRoot "copy_template.ps1") -SourceRoot $templateRoot -TargetRoot $targetRoot

$projectFile = Join-Path $targetRoot "project.godot"
$projectText = Get-Content -Raw -Encoding UTF8 -LiteralPath $projectFile
$projectText = $projectText -replace 'config/name="[^"]+"', ('config/name="' + $ProjectName.Replace('"', '') + '"')
Set-Content -LiteralPath $projectFile -Value $projectText -Encoding UTF8

$toolConfigDirectory = Join-Path $targetRoot "tools"
New-Item -ItemType Directory -Force -Path $toolConfigDirectory | Out-Null
Set-Content -LiteralPath (Join-Path $toolConfigDirectory "godot-bin.path") -Value $selectedGodotBin -Encoding UTF8

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
