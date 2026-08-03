# 0003 Godot Discovery and Vertical-Slice Gate

Status: Accepted
Date: 2026-08-04

## Context

The lazy-pack installer accepted a Godot path only for its own process. New terminals could not find Godot, so a project that passed installation later failed validation. The workflow also requested playtest checklists after every gameplay change, which pushed agents to evaluate unfinished scaffolding as if it were a game.

## Decision

The installation prompt makes the active AI agent run `scripts/find_godot_candidates.ps1`, show compatible Godot 4.7.1 candidates, and ask the user to confirm one. The installer validates and saves the selected absolute path to ignored `tools/godot-bin.path`; `resolve-godot.ps1` reads it before environment and PATH fallbacks.

Validation has three stages: foundation, ordinary feature development, and a user-declared vertical slice. Only the vertical slice receives a formal playtest and feel-tuning checklist. It must be a limited but representative experience whose in-scope gameplay, presentation, and technical baseline work together near the intended quality bar.

## Consequences

Installation has one explicit confirmation step, but future terminals run reliably without a global environment variable. Agents still report high-risk interactions during feature work, but no longer ask for a premature binary judgement of whether the game is fun.

## Verification

Build the lazy pack, install a temporary project with a confirmed Godot path, open a fresh PowerShell process, and run `scripts/verify.ps1` without `GODOT_BIN` set. Review prompts and agent adapters to confirm that only vertical-slice work requests formal playtesting.
