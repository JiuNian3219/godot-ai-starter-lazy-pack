---
name: godot-memory
description: Use when finishing a substantial Godot task, making an architectural/tooling decision, learning from a failure, switching between Claude Code and Codex chat, or preparing a new AI session.
---

# Godot Memory Skill

Keep durable project memory in the repository.

## Before Work

1. Read `docs/ai_memory.md`.
2. Search `docs/decisions/` and `docs/lessons/` for relevant history.
3. Check `docs/session_handoff.md` for current state and open risks.

## After Work

1. Run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`.
2. Update `docs/session_handoff.md` with changed files, verification result, risks, and next task.
3. Add or update an ADR if the task made a durable architecture, tooling, or workflow choice.
4. Add or update a lesson if a repeatable failure happened.

## What Counts As A Decision

- New tool, plugin, architecture, scene boundary, test strategy, asset pipeline, or system pattern.
- A choice that future work should follow or deliberately revisit.

## What Counts As A Lesson

- A bug, false-positive test, AI failure mode, Godot version gotcha, or workflow issue likely to repeat.

