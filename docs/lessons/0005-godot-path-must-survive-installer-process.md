# 0005 Godot Path Must Survive the Installer Process

Date: 2026-08-04

## What Happened

The installer used `-GodotBin` to set `GODOT_BIN` only in its own PowerShell process. Its validation passed, but later `verify.ps1` calls started in a fresh shell and could not resolve Godot.

## Why It Matters

An installation check is not meaningful if ordinary project commands cannot repeat it. Asking the user to rediscover the executable for every session defeats the lazy-pack goal.

## Detection

After installing, clear `GODOT_BIN` and run `powershell -ExecutionPolicy Bypass -File scripts\verify.ps1` from a new PowerShell process.

## Rule Added

Ask the user to confirm an auto-discovered Godot 4.6.x executable during installation, then save it to ignored `tools/godot-bin.path`. All project scripts resolve this saved path first.
