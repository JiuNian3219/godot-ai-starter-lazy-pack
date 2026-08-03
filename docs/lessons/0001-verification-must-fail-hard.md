# 0001 Verification Must Fail Hard

Date: 2026-06-04

## What Happened

Claude Code generated a HealthComponent test that reported failures, but the PowerShell verification script still printed `Verify complete` because external command exit codes were not checked.

## Why It Matters

AI agents stop when work appears complete. A verification script that prints success after failed tests creates false confidence and lets bad code accumulate.

## Detection

Every external Godot command in `scripts/verify.ps1` must be run through a wrapper that checks `$LASTEXITCODE`.

## Rule Added

`scripts/verify.ps1` now uses `Invoke-Godot` and throws when Godot exits with a non-zero status.

