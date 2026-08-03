param(
    [switch]$AsJson,
    [switch]$IncludeIncompatible
)

$ErrorActionPreference = "Stop"

function Add-Candidate {
    param(
        [System.Collections.Generic.List[string]]$Candidates,
        [string]$Path
    )

    if ($Path -and (Test-Path -LiteralPath $Path)) {
        $Candidates.Add((Resolve-Path -LiteralPath $Path).Path)
    }
}

function Get-GodotVersion {
    param([string]$GodotPath)

    $version = & $GodotPath --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        return ""
    }

    $firstLine = $version | Select-Object -First 1
    if ($null -eq $firstLine) {
        return ""
    }

    return $firstLine.ToString().Trim()
}

$candidatePaths = [System.Collections.Generic.List[string]]::new()
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

if ($env:GODOT_BIN) {
    Add-Candidate -Candidates $candidatePaths -Path $env:GODOT_BIN
}

foreach ($commandName in @("godot", "godot4", "godot-console", "godot4-console")) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    if ($command) {
        Add-Candidate -Candidates $candidatePaths -Path $command.Source
    }
}

$searchRoots = @(
    (Join-Path $projectRoot "tools"),
    (Join-Path $env:USERPROFILE "Downloads"),
    (Join-Path $env:LOCALAPPDATA "Programs\Godot"),
    (Join-Path $env:ProgramFiles "Godot"),
    (Join-Path ${env:ProgramFiles(x86)} "Godot"),
    "C:\Godot"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

foreach ($searchRoot in $searchRoots) {
    Get-ChildItem -LiteralPath $searchRoot -Filter "Godot*.exe" -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        ForEach-Object { Add-Candidate -Candidates $candidatePaths -Path $_.FullName }
}

$documentsRoot = Join-Path $env:USERPROFILE "Documents"
if (Test-Path -LiteralPath $documentsRoot) {
    Get-ChildItem -LiteralPath $documentsRoot -Filter "Godot*.exe" -File -Recurse -Depth 6 -ErrorAction SilentlyContinue |
        ForEach-Object { Add-Candidate -Candidates $candidatePaths -Path $_.FullName }
}

$results = $candidatePaths |
    Sort-Object -Unique |
    ForEach-Object {
        $version = Get-GodotVersion -GodotPath $_
        [PSCustomObject]@{
            Path = $_
            Version = $version
            IsGodot471 = $version -match "^4\.7\.1\."
        }
    }

if (-not $IncludeIncompatible) {
    $results = @($results | Where-Object { $_.IsGodot471 })
}

if ($AsJson) {
    $results | ConvertTo-Json -Depth 3
    exit 0
}

if (-not $results) {
    Write-Host "No compatible Godot 4.7.1 executable was found in GODOT_BIN, PATH, project tools, Downloads, Documents, or common install folders."
    exit 1
}

$index = 1
foreach ($result in $results) {
    Write-Host "[$index] Version: $($result.Version)"
    Write-Host "    Path: $($result.Path)"
    $index++
}
