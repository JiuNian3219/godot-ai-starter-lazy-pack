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

Get-ChildItem -LiteralPath (Join-Path $projectRoot "tools") -Filter "Godot_v4.7.1-stable_win64_console.exe" -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
    ForEach-Object { $candidates += $_.FullName }

foreach ($name in @("godot", "godot4", "godot-console", "godot4-console")) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) {
        $candidates += $cmd.Source
    }
}

foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
        $version = & $candidate --version 2>$null
        $versionText = $version | Select-Object -First 1
        if ($LASTEXITCODE -eq 0 -and $versionText -and ($versionText.ToString() -match "^4\.7\.1\.")) {
            Write-Output (Resolve-Path -LiteralPath $candidate)
            exit 0
        }
    }
}

throw "Godot 4.7.1 executable not found. Run scripts\find_godot_candidates.ps1, then save the confirmed path to tools\godot-bin.path or set GODOT_BIN."
