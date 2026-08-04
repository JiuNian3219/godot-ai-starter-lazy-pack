# 0008 CI, Prototype Scenes, and Asset Ledger

Status: Accepted
Date: 2026-08-04

## Context

AI-assisted game work needs repeatable validation outside a local machine, a contained place to test mechanics, and durable provenance for generated assets.

## Decision

Run the existing verification script on every push and pull request using official Godot 4.7.1 Linux binaries in GitHub Actions. Keep prototype scenes under `scenes/prototypes/` with explicit promotion or deletion rules. Track retained AI and external assets in a Markdown ledger under `docs/assets/`.

## Consequences

The template gains a hosted quality gate without committing an engine binary. Prototype experimentation stays out of production dependencies. Asset replacement, licensing, ownership, import settings, and future package boundaries remain discoverable in Git history.
