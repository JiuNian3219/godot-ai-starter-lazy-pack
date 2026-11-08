param(
    [string]$Scene = "",
    [ValidateRange(1, 18000)]
    [int]$Frames = 90,
    [ValidateRange(1, 120)]
    [int]$Fps = 30,
    [string]$OutputFile = ""
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")

# PNG sequences can be inspected directly by an AI; AVI is available for a video file.
if (-not $OutputFile) {
    $OutputFile = ".tmp/recordings/" + [Guid]::NewGuid().ToString("N") + "/frame.png"
}
if (-not [IO.Path]::IsPathRooted($OutputFile)) {
    $OutputFile = Join-Path $projectRoot $OutputFile
}
$OutputFile = [IO.Path]::GetFullPath($OutputFile)
$extension = [IO.Path]::GetExtension($OutputFile).ToLowerInvariant()
if ($extension -notin @(".png", ".avi")) {
    throw "Use .png for a frame sequence or .avi for a video."
}
$outputDirectory = Split-Path -Parent $OutputFile
$outputStem = [IO.Path]::GetFileNameWithoutExtension($OutputFile)
$framePattern = "^" + [regex]::Escape($outputStem) + "[0-9]+\.png$"
if (Test-Path -LiteralPath $outputDirectory) {
    $existing = @(Get-ChildItem -LiteralPath $outputDirectory -File | Where-Object {
        $_.FullName -eq $OutputFile -or
        ($extension -eq ".png" -and ($_.Name -match $framePattern -or $_.Name -eq "$outputStem.wav"))
    })
    if ($existing.Count -gt 0) { throw "Recording output already exists; choose a new file prefix: $OutputFile" }
}

$sceneArgs = @()
if ($Scene) {
    $sceneRelative = $Scene -replace '^res://', ''
    $scenePath = if ([IO.Path]::IsPathRooted($sceneRelative)) { $sceneRelative } else { Join-Path $projectRoot $sceneRelative }
    if (-not (Test-Path -LiteralPath $scenePath -PathType Leaf)) { throw "Scene not found: $Scene" }
    $sceneArgs = @("--scene", [IO.Path]::GetFullPath($scenePath))
}

function Invoke-RecordingGodot {
    param([string[]]$GodotArgs)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $godot @GodotArgs 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    $output | ForEach-Object { Write-Host $_ }
    if ($exitCode -ne 0 -or ($output -join "`n") -match '(^|\n)(SCRIPT ERROR|ERROR):|Parse Error|Compile Error') {
        throw "Godot recording command failed (exit $exitCode). Any output may be incomplete."
    }
}

Invoke-RecordingGodot -GodotArgs @("--headless", "--path", $projectRoot, "--import")
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
Write-Host "Recording $Frames frames at $Fps FPS. Offline rendering does not measure real-time performance."
# Rendering needs a graphics driver: --headless uses the dummy renderer and cannot capture the game.
Invoke-RecordingGodot -GodotArgs (@("--path", $projectRoot, "--write-movie", $OutputFile,
    "--fixed-fps", "$Fps", "--quit-after", "$Frames", "--disable-vsync", "--windowed") + $sceneArgs)

if ($extension -eq ".png") {
    $captured = @(Get-ChildItem -LiteralPath $outputDirectory -File |
        Where-Object { $_.Name -match $framePattern -and $_.Length -gt 0 } | Sort-Object Name)
    if ($captured.Count -eq 0) { throw "Godot produced no PNG frames: $OutputFile" }
    Write-Host "Captured $($captured.Count) frames. First / middle / last:"
    @($captured[0], $captured[[int][Math]::Floor(($captured.Count - 1) / 2)], $captured[-1]) |
        Select-Object -Unique -ExpandProperty FullName | ForEach-Object { Write-Host $_ }
    if ($captured.Count -lt $Frames) { Write-Warning "The project exited before the requested frame limit." }
}
else {
    if (-not (Test-Path -LiteralPath $OutputFile -PathType Leaf) -or (Get-Item -LiteralPath $OutputFile).Length -le 0) {
        throw "Godot produced no video: $OutputFile"
    }
    Write-Host "Video:" $OutputFile
}
