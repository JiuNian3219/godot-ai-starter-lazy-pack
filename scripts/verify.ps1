$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")

function Invoke-Godot {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$GodotArgs
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $godotOutput = & $godot @GodotArgs 2>&1
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    $godotOutput | ForEach-Object { Write-Host $_ }

    if ($LASTEXITCODE -ne 0) {
        throw "Godot command failed with exit code ${LASTEXITCODE}: $godot $($GodotArgs -join ' ')"
    }

    $errorPattern = 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Compilation failed'
    if (($godotOutput -join "`n") -match $errorPattern) {
        throw "Godot command output contained script/compile errors: $godot $($GodotArgs -join ' ')"
    }
}

Write-Host "Godot:" $godot
Invoke-Godot --version

Write-Host "Importing project assets..."
Invoke-Godot --headless --path $projectRoot --import

# 使用项目当前配置的启动场景；退出由验证命令控制，不侵入游戏脚本。
Write-Host "Checking current project startup (5 frames)..."
Invoke-Godot --headless --path $projectRoot --quit-after 5

# 示例可随项目替换；仅运行当前存在的轻量 SceneTree 行为测试。
$testRoot = Join-Path $projectRoot "tests"
$projectTests = @()
if (Test-Path -LiteralPath $testRoot) {
    $projectTests = @(Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter "*_test.gd" | Sort-Object FullName)
}
if ($projectTests.Count -eq 0) {
    Write-Host "No project behavior tests found (tests/**/*_test.gd). Startup and dependency checks still run."
}
foreach ($test in $projectTests) {
    $testPath = "res://" + $test.FullName.Substring($projectRoot.Path.Length + 1).Replace("\", "/")
    Write-Host "Running project test:" $testPath
    Invoke-Godot --headless --path $projectRoot --script $testPath
}

Write-Host "Auditing architecture dependencies..."
$powerShellExecutable = if ($PSVersionTable.PSEdition -eq "Desktop") {
    Join-Path $PSHOME "powershell.exe"
}
elseif ($env:OS -eq "Windows_NT") {
    Join-Path $PSHOME "pwsh.exe"
}
else {
    Join-Path $PSHOME "pwsh"
}

& $powerShellExecutable -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "audit_dependencies.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Dependency audit failed."
}

Write-Host "Verify complete."
