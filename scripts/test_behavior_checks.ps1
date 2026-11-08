$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scratchRoot = Join-Path (Join-Path $repoRoot ".tmp") ("behavior-" + [Guid]::NewGuid().ToString("N"))
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")
$utf8 = [Text.UTF8Encoding]::new($false)

# This checks the preparation tools and a known reference oracle, not AI task success.
function Assert-RoundTest {
    param([string]$Label, [bool]$ShouldPass, [string]$ExpectedOutput)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $godot --headless --path $fixture --script res://tests/round_battle_test.gd 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    $text = $output -join "`n"
    if (($exitCode -eq 0) -ne $ShouldPass -or -not $text.Contains($ExpectedOutput)) {
        throw "Reference oracle failed: $Label (exit $exitCode)`n$text"
    }
    Write-Host "Passed:" $Label
}

try {
    $cases = Get-Content -LiteralPath (Join-Path $repoRoot "maintenance/behavior_cases.json") -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($case in $cases) {
        $runRoot = Join-Path $scratchRoot $case.id
        & (Join-Path $PSScriptRoot "prepare_behavior_case.ps1") -Case $case.id -TargetPath $runRoot -GodotBin $godot
        $projectRoot = Join-Path $runRoot "project"
        if ([IO.File]::ReadAllText((Join-Path $runRoot "task.txt"), $utf8) -ne ($case.prompt + "`n")) {
            throw "Task export must contain only the natural requirement: $($case.id)"
        }
        foreach ($excluded in @("maintenance", "task.txt", "baseline.json", "scripts/prepare_behavior_case.ps1", "scripts/test_behavior_checks.ps1")) {
            if (Test-Path -LiteralPath (Join-Path $projectRoot $excluded)) {
                throw "Evaluation material leaked into the candidate project: $excluded"
            }
        }
        $baseline = Get-Content -LiteralPath (Join-Path $runRoot "baseline.json") -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($file in $baseline.files) {
            if ((Get-FileHash -LiteralPath (Join-Path $projectRoot $file.path) -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) {
                throw "Baseline hash does not match copied content: $($file.path)"
            }
        }
    }
    Write-Host "Passed: four isolated task workspaces; private criteria excluded; baseline hashes match"

    $fixture = Join-Path (Join-Path $scratchRoot "round") "project"
    $referenceRoot = Join-Path $repoRoot "maintenance/reference-round"
    $referenceFiles = @{
        "round_battle_prototype.tscn" = "scenes/prototypes/round_battle_prototype.tscn"
        "round_battle_prototype.gd" = "scripts/gameplay/round_battle_prototype.gd"
        "round_battle_test.gd" = "tests/round_battle_test.gd"
    }
    foreach ($name in $referenceFiles.Keys) {
        $destination = Join-Path $fixture $referenceFiles[$name]
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath (Join-Path $referenceRoot $name) -Destination $destination
    }
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $importOutput = & $godot --headless --path $fixture --editor --import 2>&1
        $importExit = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    if ($importExit -ne 0 -or ($importOutput -join "`n") -match '(?m)^(SCRIPT ERROR:|ERROR:)') {
        throw "Reference fixture import failed: $($importOutput -join "`n")"
    }
    Assert-RoundTest -Label "correct reference: 28 assertions" -ShouldPass $true -ExpectedOutput "28 passed, 0 failed"
    $scriptPath = Join-Path $fixture "scripts/gameplay/round_battle_prototype.gd"
    $original = [IO.File]::ReadAllText($scriptPath, $utf8)
    $mutations = @(
        @("skip wait", "`t`tawait get_tree().create_timer(ACTION_DELAY).timeout", "`t`t# Deliberately removed wait.", "damage must not settle before 0.2 seconds"),
        @("skip lethal stop", "`t`tif enemy_health <= 0:", "`t`tif false:", "later actor must not act after death"),
        @("ignore shield", "mini(enemy_health, damage - shield_damage)", "mini(enemy_health, damage)", "sufficient shield must prevent health damage")
    )
    foreach ($mutation in $mutations) {
        if ([regex]::Matches($original, [regex]::Escape($mutation[1])).Count -ne 1) {
            throw "Expected exactly one mutation location: $($mutation[0])"
        }
        [IO.File]::WriteAllText($scriptPath, $original.Replace($mutation[1], $mutation[2]), $utf8)
        Assert-RoundTest -Label $mutation[0] -ShouldPass $false -ExpectedOutput $mutation[3]
    }
    Write-Host "Behavior preparation and reference checks passed. This is not an AI evaluation result."
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratch = (Resolve-Path -LiteralPath $scratchRoot).Path
        $allowedPrefix = Join-Path (Join-Path $repoRoot ".tmp") "behavior-"
        if (-not $resolvedScratch.StartsWith($allowedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove a directory outside the test workspace."
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}
