$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$godot = & (Join-Path $PSScriptRoot "resolve-godot.ps1")

& $godot --path $projectRoot

