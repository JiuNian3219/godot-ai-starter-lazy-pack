# 0002 Qoder Optional Tool Adapter

## Status

Superseded by 0004

## Context

The project started with Claude Code and Codex chat as AI tool entries. The user wants to test QoderCN/Qoder as a possible replacement or additional workflow, but the project should not become dependent on any single AI product.

Qoder currently supports project-level rules under `.qoder/rules/`, project-level skills under `.qoder/skills/{skill-name}/SKILL.md`, and MCP configuration compatible with project-local `.mcp.json`.

## Decision

Add QoderCN/Qoder as an optional AI tool adapter:

- Keep Claude Code, QoderCN/Qoder, and Codex chat as equivalent ways for the current AI agent to access the workspace.
- Allow only one active writing agent per task.
- Store Qoder-specific rules under `.qoder/rules/`.
- Store Qoder-specific skills under `.qoder/skills/`.
- Reuse the same `AGENTS.md`, `docs/`, `.mcp.json`, and `scripts/verify.ps1` instead of creating a separate Qoder-only workflow.
- Keep Qoder checks optional in the lazy pack installer.

## Historical Consequences

- New projects can test QoderCN/Qoder without changing the engineering rules.
- Claude Code and Codex remain usable with the same project.
- Qoder absence must not block installation or verification.
- Any future Qoder-specific behavior should stay thin and point back to shared project docs where possible.
