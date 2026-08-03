# Godot AI Workflow

## Tool entries

- Godot 4.7.1: editor, runtime, importer, command-line validator.
- Git + Git LFS: checkpoint every meaningful step, store large binary assets safely.
- Claude Code: AI tool entry that can expose project-local Claude skills.
- Codex chat: AI tool entry that can read project rules and update project files through direct conversation.
- Godot MCP: bridge between AI clients and the running Godot editor. It is the hands and eyes, not the architecture.

## Daily loop

1. Write a small task with clear boundaries.
2. Identify engineering risks using `docs/engineering_rules.md`, game-specific risks using `docs/game_development_rules.md`, and module boundaries using `docs/architecture_rules.md` when files/resources are added.
3. Choose one active writing agent for this task.
4. Run `scripts/verify.ps1`.
5. Use the right validation stage: foundation and ordinary feature work use technical checks; only an explicitly declared vertical-slice milestone receives a formal playtest and feel-tuning loop.
6. After code changes, commit automatically if verification passes and the user did not forbid committing.
7. Stage only the files required by the task and use Angular/Conventional Commits style: `type(scope): short summary`.
8. Optionally ask another agent to review, explain, or take over after the first agent stops.
9. Update `docs/session_handoff.md` after substantial work.
10. Record decisions or lessons when the work creates durable knowledge.

## Code-first standard

- Typed GDScript is preferred.
- Scene scripts should coordinate nodes, not become giant feature dumps.
- Reusable gameplay behavior belongs in components, resources, or standalone scripts.
- MCP should be used for editor operations, scene inspection, screenshots, and runtime errors.
- Every feature should be readable enough for a learning developer to study and modify.
- Every completed code-changing task should end with a clean scoped commit after verification passes.
- Module boundaries and dependency direction should follow `docs/architecture_rules.md`.
- Avoid accidental package bloat from shared assets or cross-module preloads.
- Engineering quality should follow `docs/engineering_rules.md`: tests, resource size, performance, input/platform, UI, save/data, debug visibility, and manual playtest needs.
- Game-specific quality should follow `docs/game_development_rules.md`: core loop, feel, feedback, input latency, camera, animation, physics, level iteration, asset pipeline, FPS budget, tuning, and playtest checklist.

## Durable Memory

- Use `docs/decisions/` for durable choices.
- Use `docs/lessons/` for repeatable mistakes and gotchas.
- Use `docs/session_handoff.md` to resume after long AI sessions or context switches.
- Use `.claude/skills/godot-memory` when ending a substantial Claude Code session.
- For Codex chat sessions, explicitly ask Codex to update `docs/session_handoff.md`, decisions, and lessons when needed.

## Common pitfalls

- Godot 3 snippets often fail in Godot 4.7.1. Always specify `Godot 4.7.1 GDScript`.
- `.tscn` is text, but careless edits can break resources, signals, or node ownership.
- MCP changes are direct edits, not safe preview operations.
- A workflow that relies only on MCP can produce a working scene with messy, unmaintainable code.
- Two agents editing the same files will create confusion quickly.
- AI can generate code faster than it can judge game feel. Do not ask whether an unfinished framework is fun; run hands-on playtesting when a representative vertical slice is ready.
- Keep third-party MCP servers pinned and local. Do not add broad filesystem/network tools without a reason.
