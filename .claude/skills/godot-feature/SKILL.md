---
name: godot-feature
description: Use when implementing a Godot 4.6 gameplay feature, scene behavior, UI flow, tool script, or reusable game system.
---

# Godot Feature Skill

Build features code-first, with MCP only as the editor/runtime bridge.

## Workflow

1. Restate the feature boundary and current stage in one short paragraph: foundation, ordinary feature development, or a user-declared vertical slice.
2. Identify the scripts, scenes, resources, and input/project settings involved.
3. Prefer typed GDScript and small responsibilities.
4. Use MCP only when you need live scene state, node operations, screenshots, or runtime errors.
5. Keep scene scripts as coordinators. Extract reusable logic into components, resources, or standalone scripts.
6. Add concise Chinese comments for function purpose, important gameplay logic, special cases, timing windows, tunable parameters, and non-obvious Godot behavior.
7. Run `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`.
8. If verification passes and the user did not forbid committing, stage only the necessary task files and commit using Angular/Conventional Commits style.
9. Explain the important Godot concepts used and report the commit hash.

Only include a short manual functional smoke check when the changed interaction is high risk. Do not ask whether an unfinished framework is fun. A formal playtest checklist and feel judgement belong only to a user-declared vertical-slice milestone.

## Code Rules

- Use explicit types for exported properties, variables, arrays, dictionaries, function parameters, and return values where practical.
- Avoid deep hard-coded node paths in reusable logic.
- Prefer signals for cross-node events.
- Prefer resources for tunable data.
- Avoid putting unrelated systems into one node script.
- Every custom function should have a short Chinese comment explaining its purpose unless it is purely trivial.
- Comment special logic branches, judgement windows, state transitions, resource-loading assumptions, and performance-sensitive code in Chinese.
- Do not add noisy comments for self-evident one-line code.
- After code changes, inspect `git status` and `git diff`, stage explicit paths only, and commit as `type(scope): short summary`.
- Do not commit unrelated user changes, generated caches, local tools, exports, builds, `.godot/`, `.tmp/`, or ignored files.
