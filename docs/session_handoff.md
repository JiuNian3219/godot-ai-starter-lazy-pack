# Session Handoff

Last updated: 2026-08-04

## Current State

- Godot 4.7.1 stable local tool is available under `tools/` and ignored by Git.
- Godot MCP addon is installed under `addons/godot_mcp/`.
- Claude project MCP config is in `.mcp.json`.
- Claude project skills exist for feature implementation, testing, review, and project memory.
- Codex chat can use `AGENTS.md` and the docs directly.
- A reusable `HealthComponent` and command-line test were added as a real validation pass.
- Long-term AI memory now exists under `docs/ai_memory.md`, `docs/decisions/`, `docs/lessons/`, and `docs/session_handoff.md`.
- Architecture and dependency rules now exist under `docs/architecture_rules.md`.
- Engineering quality rules now exist under `docs/engineering_rules.md`.
- Game-specific development rules now exist under `docs/game_development_rules.md`.
- `scripts/audit_dependencies.ps1` is included in `scripts/verify.ps1` and catches basic forbidden cross-module references and oversized shared assets.
- A read-only Claude SessionStart hook script exists at `scripts/ai_context.ps1`.
- `scripts/find_godot_candidates.ps1` locates compatible Godot executables. New projects save the user-confirmed path to ignored `tools/godot-bin.path`, so validation survives a new terminal session.
- Manual playtesting is phase-gated: technical checks for foundations and ordinary features; formal playtesting only after the user declares a representative vertical-slice milestone.
- The repository root `README.md` is the shareable AI installation entry point. It directs an AI to use the release package or build it from source, ask for Godot-path confirmation, install, and verify.
- `docs/scene_authoring_rules.md` distinguishes persistent scene, runtime, and debug nodes. `tests/main_scene_contract.gd` proves the template can fail when required editor-visible scene structure is missing.
- GitHub Actions now downloads Linux Godot 4.7.1 and runs `scripts/verify.ps1`; `.editorconfig`, prototype-scene rules, and the AI asset ledger are part of the template.

## Verification

Last command:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

Result:

```text
Main scene contract passed: persisted node structure is present
HealthComponent tests: 22 passed, 0 failed
Verify complete.
```

## Open Risks

- Claude Code non-interactive mode on Windows may produce little or no textual summary, so always inspect the diff and verification output.
- `.mcp.json` works with `cmd /c "claude mcp get godot"`; direct PowerShell `claude mcp add ... -y ...` can misparse `-y`.
- The current tests are lightweight smoke/unit-style checks, not a full gdUnit4 test suite.
- `claude doctor` timed out during this validation run, but `claude -p` exits and project MCP/Godot verification work.
- Do not let multiple AI tool entries edit the same files at the same time. Hand off explicitly with changed files, verify output, and open risks.
- Future feature work should identify module boundaries and dependency direction before adding files.
- A vertical slice is a polished representative section, not an early framework or first-playable gate. Do not ask users to judge unfinished scaffolding for fun.
- Dependency audit is intentionally lightweight. It catches obvious `res://` references and large shared assets, but it is not a full Godot dependency graph analyzer.
- Scene contract tests cover only the paths explicitly asserted for important scenes; they do not infer every intended node automatically.
- The new Linux CI workflow must be confirmed by its first remote GitHub Actions run; this Windows machine has no local `pwsh` executable for an equivalent host check.

## Next Suggested Task

Confirm the first GitHub Actions run after this workflow is pushed. When adding the first gameplay scene, classify every node under `docs/scene_authoring_rules.md`, add assertions for its important persistent nodes, and use a focused prototype scene when tuning a single mechanism.
