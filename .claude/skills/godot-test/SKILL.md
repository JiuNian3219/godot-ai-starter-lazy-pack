---
name: godot-test
description: Use when adding or improving verification, smoke tests, regression tests, or testability for Godot 4.7.1 GDScript code.
---

# Godot Test Skill

Use lightweight Godot command-line tests first. Introduce gdUnit4 only when the project has enough pure logic to justify the addon.

## Workflow

1. Separate logic that can be tested without a full scene.
2. Add or update a smoke test when scene loading, imports, or runtime startup are affected.
3. For important authored scenes, add focused assertions for persisted node paths; do not accept runtime-created nodes as evidence that intended `.tscn` structure exists.
4. Add deterministic script-level tests for pure logic.
5. Add concise Chinese comments explaining test intent, special assertions, and regression risks.
6. Keep tests readable for a learner.
7. Update `scripts/verify.ps1` so the check runs from one command.
8. If verification passes and the user did not forbid committing, stage only the necessary test/code files and commit using Angular/Conventional Commits style.

## Preferred Checks

- `godot --headless --path . --import`
- `godot --headless --path . --check-only --script res://path/to/script.gd`
- scene startup smoke tests with `--quit-after`

## When to Add gdUnit4

Add gdUnit4 when there are multiple reusable gameplay systems, data resources, save/load logic, inventory/combat/state-machine code, or bug regressions that need assertions.
