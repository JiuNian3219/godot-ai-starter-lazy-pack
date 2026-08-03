# Godot AI Project Instructions

This project uses Godot 4.7.1 stable with GDScript.

## Rules

- Treat Godot engine version as 4.7.1 unless the user says otherwise.
- Prefer GDScript for gameplay scripts during prototyping.
- Write good code first. MCP is only an editor/runtime operation bridge, not a substitute for architecture, readable scripts, tests, or clear data flow.
- Put gameplay logic in focused scripts, reusable components, resources, and scenes with explicit responsibilities.
- Keep node scripts small. Extract shared movement, state, inventory, combat, save, or UI logic before a scene script becomes a catch-all file.
- Use typed GDScript where practical, including typed variables, return types, and exported properties.
- Add concise Chinese comments for function purpose, important gameplay logic, special cases, timing windows, tunable parameters, and non-obvious Godot behavior. Avoid noisy comments for self-evident one-line code.
- Do not edit `.godot/`; it is generated cache.
- Do not edit `project.godot`, `export_presets.cfg`, input maps, autoloads, or plugin settings unless the task explicitly needs it.
- Prefer editing `.gd` scripts directly. Prefer Godot editor or MCP tools for scene/node operations.
- Be careful with `.tscn` files: preserve resource paths, node names, signals, and scene ownership.
- After code or scene changes, run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`.
- After every code-changing task, if verification passes and the user did not explicitly forbid committing, create a Git commit using the Angular/Conventional Commits style. Stage only files that are necessary for the completed task.
- Keep scenes small and composable. Avoid deep node paths when signals or exported NodePath fields are cleaner.
- Use Git before risky changes. Do not revert user changes without being asked.
- For medium or large tasks, read `docs/ai_memory.md`, relevant `docs/decisions/`, relevant `docs/lessons/`, and `docs/session_handoff.md` before changing architecture or workflow.
- Before medium or large work, read `docs/engineering_rules.md`. For gameplay, input, camera, animation, physics, levels, assets, performance, or game-feel work, also read `docs/game_development_rules.md`. Before adding new gameplay/UI/resource files, also read `docs/architecture_rules.md` and identify the module boundary and allowed dependency direction.

## Agent workflow

- Claude Code and Codex chat are AI tool entries with hands on the workspace.
- The current active AI agent may implement, test, refactor, review, explain, or update memory.
- Pick one active writing agent per task. Another AI entry can review, explain, or take over after the first agent stops.
- Do not let two AI agents edit the same files at the same time.
- When handing work from one agent to another, share the changed files, verification output, open risks, and relevant `docs/session_handoff.md` notes.
- Claude Code has project-local skills under `.claude/skills/`. Codex follows `AGENTS.md`, `docs/ai_workflow.md`, `docs/ai_memory.md`, and the user's latest instructions.

## Code quality baseline

- Name nodes, scenes, scripts, signals, and exported properties clearly.
- Avoid hard-coded deep paths such as `$UI/Panel/VBox/Button` in gameplay code when an exported NodePath, signal, group, or injected reference is cleaner.
- Prefer data-driven resources for tunable game data.
- Keep every AI-generated script understandable enough that a human learner can read it and modify it.
- Every custom function should have a short Chinese comment explaining its purpose unless the function is purely trivial. Special logic branches, gameplay judgement windows, state transitions, resource-loading assumptions, and performance-sensitive code must be commented in Chinese.
- When implementing a feature, include a short explanation of the important Godot concepts used.
- Avoid accidental package bloat: do not put large assets in `shared` unless every package truly needs them.
- Avoid cross-module `preload()` / `load()` unless the dependency is allowed by `docs/architecture_rules.md`.
- For game-feel, UI, performance, platform, resource-size, save/data, or input changes, include the relevant engineering risks from `docs/engineering_rules.md`.
- For gameplay changes, report the core loop impact, tunable parameters, and placeholder feedback/assets. Include a manual functional smoke check only when the changed interaction needs one; reserve a full playtest checklist and feel judgement for an explicitly declared vertical-slice milestone.

## Git commit baseline

- Commit automatically after a code-changing task is complete and `scripts/verify.ps1` passes.
- Do not commit after pure review, explanation, planning, or failed verification.
- Inspect `git status` and `git diff` before staging.
- Stage only files that belong to the current task. Prefer explicit path staging such as `git add -- scripts/player.gd tests/player_test.gd`.
- Do not stage unrelated user changes, generated caches, local tools, exports, builds, `.godot/`, `.tmp/`, or ignored files.
- Use Angular/Conventional Commits format: `type(scope): short summary`.
- Allowed common types: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`, `perf`, `build`, `ci`, `style`, `revert`.
- Use a concise English commit subject unless the user asks otherwise. Examples: `feat(player): add dash stamina recovery`, `test(combat): cover guard timing window`.
- Report the commit hash after committing. If committing is impossible because Git identity or repository state is missing, report the blocker clearly.

## Long-term memory

- Record durable architecture/tooling/workflow decisions in `docs/decisions/`.
- Record repeatable mistakes and gotchas in `docs/lessons/`.
- Update `docs/session_handoff.md` after substantial AI-assisted work.
- If verification gives a false positive or AI repeats a bad pattern, update prompts, skills, or verification scripts so the project improves.
