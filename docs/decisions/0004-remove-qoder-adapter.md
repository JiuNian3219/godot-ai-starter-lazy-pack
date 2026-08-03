# 0004 Remove Qoder Adapter

Status: Accepted
Date: 2026-08-04

## Context

The optional `.qoder/` rules and skills duplicated shared workflow guidance already present in `AGENTS.md` and `docs/`. They were not needed for the current workflow and created a maintenance risk when project rules changed.

## Decision

Remove `.qoder/` and all live Qoder-specific installer checks, prompts, manifests, and handoff instructions. Keep the shared rules, MCP configuration, Claude project skills, and Codex chat workflow.

## Consequences

The lazy pack has fewer duplicate rule surfaces and no longer advertises Qoder support. A future Qoder experiment can use the shared project rules directly or add a deliberately small adapter in a separate change.

## Verification

Build the lazy pack and confirm its template contains no `.qoder/` directory or Qoder-specific installation checks. Run `scripts/verify.ps1` after the change.
