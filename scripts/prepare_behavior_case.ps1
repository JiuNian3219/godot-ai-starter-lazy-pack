param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("camera", "round", "spawn", "small")]
    [string]$Case,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [string]$GodotBin = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$runRoot = [IO.Path]::GetFullPath($TargetPath)
if (Test-Path -LiteralPath $runRoot) {
    throw "TargetPath must be a new directory; existing evaluation work is never overwritten: $runRoot"
}
$cases = Get-Content -LiteralPath (Join-Path $repoRoot "maintenance/behavior_cases.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$selected = @($cases | Where-Object { $_.id -eq $Case })
if ($selected.Count -ne 1) { throw "Expected one task definition for case: $Case" }

if (-not $GodotBin) {
    $GodotBin = & (Join-Path $PSScriptRoot "resolve-godot.ps1")
}
$godot = (Resolve-Path -LiteralPath $GodotBin).Path
$version = & $godot --version
if ($LASTEXITCODE -ne 0 -or -not (($version | Select-Object -First 1) -match "^4\.7\.1\.")) {
    throw "Godot 4.7.1 is required for this template."
}

$projectRoot = Join-Path $runRoot "project"
& (Join-Path $PSScriptRoot "copy_template.ps1") -SourceRoot $repoRoot -TargetRoot $projectRoot
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "tools") | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText((Join-Path $projectRoot "tools/godot-bin.path"), $godot + "`n", $utf8)

# Export only the normal user task. Evaluation criteria stay outside the candidate workspace.
[IO.File]::WriteAllText((Join-Path $runRoot "task.txt"), $selected[0].prompt + "`n", $utf8)
$files = @(Get-ChildItem -LiteralPath $projectRoot -Recurse -Force -File | Sort-Object FullName | ForEach-Object {
    [ordered]@{
        path = $_.FullName.Substring($projectRoot.Length + 1).Replace("\", "/")
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
})
$baseline = [ordered]@{ case = $Case; files = $files } | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText((Join-Path $runRoot "baseline.json"), $baseline + "`n", $utf8)

Write-Host "Prepared project:" $projectRoot
Write-Host "User task:" (Join-Path $runRoot "task.txt")
Write-Host "Open an independent AI session in project/ and provide only task.txt."
Write-Host "No AI has run and no behavior result has been evaluated."
