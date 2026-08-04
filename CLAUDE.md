# Claude Code Notes

Use the project-scoped MCP server named `godot` when you need live Godot editor state.

Code quality comes first. MCP is for operating the editor, reading runtime state, manipulating scenes, screenshots, and errors. It is not a replacement for clean scripts, readable architecture, tests, or clear explanations.

For substantial tasks, use the `godot-memory` skill before and after work. Read `docs/ai_memory.md`, relevant decisions, relevant lessons, and `docs/session_handoff.md`.

Before medium or large work, read `docs/engineering_rules.md`. For gameplay, input, camera, animation, physics, levels, assets, performance, or game-feel work, also read `docs/game_development_rules.md`. Before adding new gameplay, UI, resource, or asset files, read `docs/architecture_rules.md` and keep dependency direction clean.

## Godot MCP workflow

1. Open this project in Godot.
2. Ensure the `Godot MCP` plugin is installed and enabled.
3. Confirm the editor shows the MCP connection status.
4. Read `docs/scene_authoring_rules.md` before node work. Use MCP for scene tree inspection, persistent node operations, screenshots, runtime errors, and project visualization.
5. Use normal file edits for scripts when scene state is not needed.
6. Save modified scenes and report changed files.

## Code expectations

- Prefer typed GDScript.
- Keep scene scripts focused on coordinating their scene.
- Extract reusable game logic into components, resources, or standalone scripts.
- Do not bury important gameplay behavior in anonymous editor-only operations.
- Classify every node as persistent scene, runtime, or debug. Save authored UI, collision, camera, and level structure to `.tscn`; for runtime nodes, document their lifecycle and why they are dynamic.
- Explain the key Godot concepts behind any new feature so the user can learn while reviewing it.
- Update project memory when the task creates a durable decision or a repeatable lesson.
- Avoid cross-module `preload()` / `load()` unless the dependency is allowed by `docs/architecture_rules.md`.
- Keep large assets out of shared folders unless they are truly shared by every package.
- Report relevant engineering risks: verification, performance, resource size, platform/input, UI, save/data, and manual playtest needs.
- For gameplay changes, report the core loop impact, tunable parameters, and placeholder feedback/assets. Include a formal playtest checklist only for a user-declared vertical slice.

## Safety

- MCP writes directly to the project and has no reliable undo. Keep changes scoped.
- Summarize intended scene/node changes before broad edits.
- Run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1` after changes.
- Treat a verification script that ignores failed test output as a bug in the workflow.
