$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scratchRoot = Join-Path (Join-Path $repoRoot ".tmp") ("verification-" + [Guid]::NewGuid().ToString("N"))
$fixture = Join-Path $scratchRoot "project"
$powerShellExecutable = (Get-Process -Id $PID).Path
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")

# Windows PowerShell 的 Set-Content -Encoding UTF8 会加 BOM，场景文件不能使用它。
function Set-FixtureText {
    param([string]$Path, [string]$Value)
    [IO.File]::WriteAllText($Path, $Value, [Text.UTF8Encoding]::new($false))
}

# 在独立进程运行真实入口，既检查退出码，也核对预期的失败原因。
function Assert-Verification {
    param([string]$Label, [bool]$ShouldPass, [string]$ExpectedOutput)

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $powerShellExecutable -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture "scripts/verify.ps1") 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    $text = $output -join "`n"
    if (($exitCode -eq 0) -ne $ShouldPass -or -not $text.Contains($ExpectedOutput)) {
        throw "Verification regression failed: $Label (exit $exitCode)`n$text"
    }
    Write-Host "Passed:" $Label
}

try {
    & (Join-Path $PSScriptRoot "copy_template.ps1") -SourceRoot $repoRoot -TargetRoot $fixture
    New-Item -ItemType Directory -Force -Path (Join-Path $fixture "tools") | Out-Null
    Set-Content -LiteralPath (Join-Path $fixture "tools/godot-bin.path") -Value $godot -Encoding UTF8

    # 删除全部初始示例，使用不同路径、不同根节点类型且没有 Title 的启动场景。
    foreach ($path in @("scenes/main.tscn", "scripts/main.gd", "scripts/components/health_component.gd", "tests/health_component_test.gd")) {
        Remove-Item -LiteralPath (Join-Path $fixture $path)
    }
    Remove-Item -LiteralPath (Join-Path $fixture "tests")
    $projectFile = Join-Path $fixture "project.godot"
    $projectText = Get-Content -LiteralPath $projectFile -Raw -Encoding UTF8
    Set-FixtureText -Path $projectFile -Value ($projectText.Replace('res://scenes/main.tscn', 'res://scenes/current_game.tscn'))
    Set-FixtureText -Path (Join-Path $fixture "scenes/current_game.tscn") -Value @'
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/current_game.gd" id="1"]
[node name="CurrentGame" type="Control"]
script = ExtResource("1")
'@
    $startupScript = Join-Path $fixture "scripts/current_game.gd"
    Set-FixtureText -Path $startupScript -Value 'extends Control'
    Assert-Verification -Label "replaced placeholders, no tests directory" -ShouldPass $true -ExpectedOutput "No project behavior tests found"

    Set-FixtureText -Path $startupScript -Value @'
extends Control
func _ready() -> void:
    assert(false, "STARTUP_FAILURE_FIXTURE")
'@
    Assert-Verification -Label "current startup error fails" -ShouldPass $false -ExpectedOutput "STARTUP_FAILURE_FIXTURE"
    Set-FixtureText -Path $startupScript -Value 'extends Control'

    New-Item -ItemType Directory -Force -Path (Join-Path $fixture "tests/nested") | Out-Null
    # 辅助脚本即使不能作为 SceneTree 执行，也不应被当作测试启动。
    Set-FixtureText -Path (Join-Path $fixture "tests/helper.gd") -Value 'extends RefCounted'
    $testScript = Join-Path $fixture "tests/nested/current_game_test.gd"
    Set-FixtureText -Path $testScript -Value @'
extends SceneTree
func _init() -> void:
    print("PROJECT_TEST_FAILURE_FIXTURE")
    quit(7)
'@
    Assert-Verification -Label "new nested test failure is detected" -ShouldPass $false -ExpectedOutput "PROJECT_TEST_FAILURE_FIXTURE"

    Set-FixtureText -Path $testScript -Value @'
extends SceneTree
func _init() -> void:
    _run.call_deferred()
func _run() -> void:
    for frame in range(10):
        await process_frame
    print("ASYNC_PROJECT_TEST_COMPLETED")
    quit()
'@
    Assert-Verification -Label "async test runs to completion; helper is ignored" -ShouldPass $true -ExpectedOutput "ASYNC_PROJECT_TEST_COMPLETED"
    Write-Host "Verification regression checks passed."
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratch = (Resolve-Path -LiteralPath $scratchRoot).Path
        $allowedPrefix = Join-Path (Join-Path $repoRoot ".tmp") "verification-"
        if (-not $resolvedScratch.StartsWith($allowedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove a directory outside the test workspace."
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}
