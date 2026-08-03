# 0001 AI-Assisted Godot Workflow

Status: Accepted
Date: 2026-06-04

## Context

The project uses AI heavily for Godot game development. MCP can operate the editor, but it does not guarantee good gameplay architecture, readable scripts, or reliable tests.

## Decision

Use both Claude Code and Codex chat as capable AI work agents. Either can implement, test, refactor, review, explain, or update project memory.

Only one agent should be the active writing agent for a task. The other agent may review or take over after the first agent stops and shares changed files, verification output, and open risks.

Keep gameplay logic code-first in typed GDScript. Use MCP for editor/runtime operations, scene inspection, screenshots, and runtime errors.

Maintain durable project memory in:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/ai_memory.md`
- `docs/decisions/`
- `docs/lessons/`
- `docs/session_handoff.md`

## Consequences

Agents have explicit project memory and less reason to repeat old mistakes. The workflow has some documentation overhead, but it protects long-running work from context drift.

## Verification

Run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1` after changes. For substantial work, ask another agent to review the diff and update decisions or lessons when needed.
