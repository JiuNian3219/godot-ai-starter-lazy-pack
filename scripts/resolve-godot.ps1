$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$candidates = @()

$savedPathFile = Join-Path $projectRoot "tools\godot-bin.path"
if (Test-Path -LiteralPath $savedPathFile) {
    $savedPath = (Get-Content -LiteralPath $savedPathFile -TotalCount 1).Trim()
    if ($savedPath) {
        $candidates += $savedPath
    }
}

if ($env:GODOT_BIN) {
    $candidates += $env:GODOT_BIN
}

$localConsole = Join-Path $projectRoot "tools\Godot-4.6.3\Godot_v4.6.3-stable_win64_console.exe"
$localGui = Join-Path $projectRoot "tools\Godot-4.6.3\Godot_v4.6.3-stable_win64.exe"
$candidates += $localConsole
$candidates += $localGui

foreach ($name in @("godot", "godot4", "godot-console", "godot4-console")) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) {
        $candidates += $cmd.Source
    }
}

foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
        $version = & $candidate --version 2>$null
        if ($LASTEXITCODE -eq 0 -and (($version | Select-Object -First 1).ToString() -match "^4\.6\.")) {
            Write-Output (Resolve-Path -LiteralPath $candidate)
            exit 0
        }
    }
}

throw "Godot 4.6.x executable not found. Run scripts\find_godot_candidates.ps1, then save the confirmed path to tools\godot-bin.path or set GODOT_BIN."
