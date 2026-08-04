# 0007 CI Must Set GODOT_BIN

Date: 2026-08-04

## What Happened

The Linux CI workflow downloaded the official Godot executable, but its filename was not one of the command aliases searched by `scripts/resolve-godot.ps1`. The first remote verification could not find Godot even though the download succeeded.

## Why It Matters

Local Windows validation used a project-local console executable and did not exercise this Linux path. A CI workflow is only useful when it passes the exact executable path it installed to the shared resolver.

## Detection

After changing CI setup, inspect the first GitHub Actions run and confirm `scripts/verify.ps1` reports the expected Godot version before its import step.

## Rule Added

The GitHub Actions install step writes the official Linux executable path to `GODOT_BIN`. Keep CI engine discovery explicit instead of relying on an extracted filename or PATH alias.
