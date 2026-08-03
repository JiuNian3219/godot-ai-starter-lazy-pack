---
name: godot-review
description: Use when reviewing Godot 4.7.1 GDScript code, AI-generated scripts, scenes, project settings, or MCP-created changes.
---

# Godot Review Skill

Review for bugs, maintainability, Godot version mismatches, and teachability.

## Checklist

- Does this use Godot 4.7.1 APIs, not old Godot 3 patterns?
- Are scripts typed enough to catch mistakes early?
- Are responsibilities clear, or did a scene script become a catch-all file?
- Do custom functions, important gameplay logic, special cases, timing windows, tunable parameters, and non-obvious Godot behavior have concise Chinese comments?
- Are node paths brittle?
- Are signals, groups, resources, and exported references used appropriately?
- Can the user read this and learn from it?
- Does `scripts/verify.ps1` still pass?
- If this was a code-changing task, was there a clean scoped commit using Angular/Conventional Commits style?
- Did the commit avoid unrelated user changes, generated caches, local tools, exports, builds, `.godot/`, `.tmp/`, and ignored files?

## Output

Lead with concrete issues and file references. Then summarize the change in plain language.
