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

Write-Host "Checking main script syntax..."
Invoke-Godot --headless --path $projectRoot --check-only --script res://scripts/main.gd

Write-Host "Checking health component syntax..."
Invoke-Godot --headless --path $projectRoot --check-only --script res://scripts/components/health_component.gd

Write-Host "Checking smoke test syntax..."
Invoke-Godot --headless --path $projectRoot --check-only --script res://tests/smoke_scene.gd

Write-Host "Checking main scene contract syntax..."
Invoke-Godot --headless --path $projectRoot --check-only --script res://tests/main_scene_contract.gd

Write-Host "Checking health component test syntax..."
Invoke-Godot --headless --path $projectRoot --check-only --script res://tests/health_component_test.gd

Write-Host "Running smoke test..."
Invoke-Godot --headless --path $projectRoot --script res://tests/smoke_scene.gd

Write-Host "Running main scene contract..."
Invoke-Godot --headless --path $projectRoot --script res://tests/main_scene_contract.gd

Write-Host "Running health component test..."
Invoke-Godot --headless --path $projectRoot --script res://tests/health_component_test.gd

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
