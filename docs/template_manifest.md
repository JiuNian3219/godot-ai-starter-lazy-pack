# Template Manifest

This file explains exactly what the Godot AI template uses.

## External Dependencies

You provide these on the machine:

- Godot 4.7.1 stable
- Git
- Git LFS
- Node.js LTS with npm/npx
- Claude Code, optional
- Codex chat access through the user interface

The template does not require Codex CLI.
The template does not require Claude Code, but includes optional Claude Code skills for that tool entry to discover project workflows.

## External Runtime Packages

These are fetched by commands when needed:

- `godot-mcp-server@0.5.0`

It is launched by `.mcp.json`:

```json
{
  "mcpServers": {
    "godot": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "godot-mcp-server@0.5.0"]
    }
  }
}
```

## Copied Template Files

Use `scripts/create_new_project_from_template.ps1` to copy these from this verified template:

- `.claude/settings.json`
- `.claude/skills/godot-feature/SKILL.md`
- `.claude/skills/godot-test/SKILL.md`
- `.claude/skills/godot-review/SKILL.md`
- `.claude/skills/godot-memory/SKILL.md`
- `.claude/commands/godot-feature.md`
- `.claude/commands/godot-test.md`
- `.claude/commands/godot-review.md`
- `.claude/commands/godot-memory.md`
- `.mcp.json`
- `.gitattributes`
- `.editorconfig`
- `.gitignore`
- `AGENTS.md`
- `CLAUDE.md`
- `addons/godot_mcp/`
- `docs/`
- `.github/workflows/verify.yml`
- `project.godot`
- `scenes/`
- `scripts/`
- `tests/`

## Project-Local Skills

The Claude skills are not downloaded from a marketplace. They are plain Markdown files under `.claude/skills/` and are copied from this template.

Codex does not need a separate local skill package for this template. It uses `AGENTS.md`, `docs/ai_workflow.md`, `docs/ai_memory.md`, and the prompts in `docs/prompts.md`.

## Godot MCP Addon

The addon lives under `addons/godot_mcp/` and is copied from this verified template. The Node-side MCP server is still fetched with `npx` as `godot-mcp-server@0.5.0`.

## Ignored Local State

These should not be committed:

- `.godot/`
- `.tmp/`
- `tools/`
- `tools/godot-bin.path` stores the user-confirmed Godot executable for this project.
- `builds/`
- `exports/`

## Validation Command

Every new project should pass:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

The verified template currently checks:

- Godot version
- project import
- main script syntax
- HealthComponent syntax
- smoke test syntax
- HealthComponent test syntax
- main scene load/instantiate smoke test
- main scene persisted-node contract test
- HealthComponent behavior test
- hosted GitHub Actions verification on push and pull request

## Godot Discovery

`scripts/find_godot_candidates.ps1` checks `GODOT_BIN`, PATH, the project `tools/` folder, and common Windows install/download folders for Godot 4.7.1. The installation prompt requires the current AI agent to show these candidates and ask the user to confirm one before it runs the installer. `install.ps1` then saves that confirmed absolute path to the ignored `tools/godot-bin.path`, which `scripts/resolve-godot.ps1` reads in later terminals.

`scripts/build_lazy_pack.ps1 -IncludeGodot` creates a separate Windows x64 distribution ZIP with the selected Godot 4.7.1 executable pair under `template/tools/Godot-4.7.1/`. It writes an `ENGINE_MANIFEST.txt` with the engine source and SHA-256, plus a sibling `.sha256` file for the finished ZIP. The engine is never copied into the Git repository itself.

## Prompt Locations

The pack keeps prompts intentionally small:

- `docs/next_project_prompt.md`: installation and verification prompt for the lazy pack.
- `docs/prompts.md`: Chinese prompts for implementation, testing, review, and memory.
- `docs/engineering_rules.md`: broad engineering quality rules for code, tests, resources, performance, input, UI, data, debugging, and memory.
- `docs/scene_authoring_rules.md`: node persistence categories and verification requirements for editor-authored scene structure.
- `docs/prototype_scene_rules.md`: rules for focused, disposable mechanic test scenes.
- `docs/assets/asset_manifest.md`: retained AI and external asset provenance, ownership, and import ledger.
- `docs/game_development_rules.md`: game-specific rules for core loop, feel, feedback, input, camera, animation, physics, levels, assets, performance, tuning, and playtesting.
- `docs/architecture_rules.md`: module boundaries, dependency direction, and packaging-sensitive rules.
- `.claude/skills/`: Claude Code project skills used after installation.
