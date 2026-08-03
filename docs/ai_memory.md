# AI Memory Workflow

Long-running AI-assisted game projects need durable memory in the repository, not only in chat history.

## Read Before Work

Before a medium or large task, the active agent should read:

- `AGENTS.md`
- `CLAUDE.md`
- `.qoder/rules/` when the current tool recognizes Qoder rules
- `docs/ai_workflow.md`
- `docs/ai_memory.md`
- relevant files under `docs/decisions/`
- relevant files under `docs/lessons/`

Use `rg` to search decisions and lessons before changing architecture, tools, testing, scene structure, or workflow rules.

## Record Decisions

Create or update an ADR under `docs/decisions/` when a choice is durable and affects future work.

Record decisions for:

- engine/plugin/tooling choices
- language and architecture choices
- scene/component boundaries
- testing strategy
- asset pipeline choices
- save/load, combat, inventory, state-machine, networking, or UI architecture

Do not create ADRs for tiny implementation details that can be understood from the code.

## Record Lessons

Create or update a lesson under `docs/lessons/` when the project hits a repeatable failure mode.

Good lessons include:

- what happened
- why it mattered
- how to detect it next time
- the rule or verification added

## Session Handoff

At the end of a substantial AI session, update `docs/session_handoff.md` with:

- what changed
- current verification result
- open risks
- next suggested task
- files that matter

Use this after long AI runs, context compaction, or a switch between AI tool entries.

## Review Loop

Treat Claude Code, QoderCN/Qoder, and Codex chat as tool entries for a current AI agent. Any one entry may be used for implementation or review, but only one should write files for a task at a time.

Before calling work done:

1. Run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`.
2. Review the diff for bugs and missing tests.
3. Record any durable decision or repeatable lesson.
4. Keep `docs/prompts.md` and project skills updated when an AI behavior fails.
