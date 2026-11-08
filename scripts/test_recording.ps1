$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scratch = Join-Path $repoRoot (".tmp/recording-test-" + [Guid]::NewGuid().ToString("N"))
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")
$utf8 = New-Object Text.UTF8Encoding($false)

# This test needs a real graphics driver (Linux CI can use Xvfb), not --headless capture.
try {
    & (Join-Path $PSScriptRoot "copy_template.ps1") -SourceRoot $repoRoot -TargetRoot $scratch
    New-Item -ItemType Directory -Path (Join-Path $scratch "tools") | Out-Null
    [IO.File]::WriteAllText((Join-Path $scratch "tools/godot-bin.path"), $godot, $utf8)
    [IO.File]::WriteAllText((Join-Path $scratch "scripts/recording_probe.gd"), @'
extends Node2D

func _process(delta: float) -> void:
    $Marker.position.x += 120.0 * delta
'@, $utf8)
    [IO.File]::WriteAllText((Join-Path $scratch "scenes/recording_probe.tscn"), @'
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/recording_probe.gd" id="1"]
[node name="Probe" type="Node2D"]
script = ExtResource("1")
[node name="Marker" type="ColorRect" parent="."]
offset_left = 20.0
offset_top = 20.0
offset_right = 60.0
offset_bottom = 60.0
color = Color(1, 0, 0, 1)
'@, $utf8)
    $record = Join-Path $scratch "scripts/record_game.ps1"
    & $record -Scene "res://scenes/recording_probe.tscn" -Frames 12 -Fps 30 -OutputFile ".tmp/space in path/frame.png"
    $images = @(Get-ChildItem -LiteralPath (Join-Path $scratch ".tmp/space in path") -Filter "*.png" | Sort-Object Name)
    if ($images.Count -ne 12) { throw "Expected 12 recorded frames, got $($images.Count)." }
    foreach ($image in $images) {
        $bytes = [IO.File]::ReadAllBytes($image.FullName)
        if ([BitConverter]::ToString($bytes, 0, 8) -ne "89-50-4E-47-0D-0A-1A-0A") { throw "Invalid PNG: $image" }
    }
    if ((Get-FileHash -LiteralPath $images[0].FullName).Hash -eq (Get-FileHash -LiteralPath $images[-1].FullName).Hash) {
        throw "Moving probe produced identical first and last frames."
    }
    $projectFile = Join-Path $scratch "project.godot"
    $projectText = [IO.File]::ReadAllText($projectFile, $utf8) -replace 'run/main_scene="[^"]+"', 'run/main_scene="res://scenes/recording_probe.tscn"'
    [IO.File]::WriteAllText($projectFile, $projectText, $utf8)
    & $record -Frames 3 -OutputFile ".tmp/clip.avi"
    $video = [IO.File]::ReadAllBytes((Join-Path $scratch ".tmp/clip.avi"))
    if ([Text.Encoding]::ASCII.GetString($video, 0, 4) -ne "RIFF" -or [Text.Encoding]::ASCII.GetString($video, 8, 4) -ne "AVI ") {
        throw "Invalid AVI container."
    }
    $rejected = $false
    try { & $record -Frames 3 -OutputFile ".tmp/clip.avi" }
    catch {
        if ($_.Exception.Message -notlike "Recording output already exists*") { throw }
        $rejected = $true
    }
    if (-not $rejected) { throw "Existing recording was overwritten." }
    [IO.File]::WriteAllText((Join-Path $scratch "scripts/recording_probe.gd"), "extends Node2D`nfunc _ready() -> void:`n    assert(false, 'RECORDING_ERROR_FIXTURE')`n", $utf8)
    $rejected = $false
    try { & $record -Scene "res://scenes/recording_probe.tscn" -Frames 3 -OutputFile ".tmp/broken.png" }
    catch {
        if ($_.Exception.Message -notlike "Godot recording command failed*") { throw }
        $rejected = $true
    }
    if (-not $rejected) { throw "Recording with a runtime script error was accepted." }
    Write-Host "Recording checks passed: moving PNG frames, AVI, existing output protection and runtime error rejection."
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        $resolved = (Resolve-Path -LiteralPath $scratch).Path
        $allowed = Join-Path (Join-Path $repoRoot ".tmp") "recording-test-"
        if (-not $resolved.StartsWith($allowed, [StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe cleanup path." }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
