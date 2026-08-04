# 0007 Scene Node Persistence Contract

Status: Accepted
Date: 2026-08-04

## Context

AI agents can create nodes with runtime code instead of adding intended authoring structure to `.tscn` files. The game may run, but designers cannot inspect or tune the expected nodes in the Godot editor.

## Decision

Classify every new node as persistent scene, runtime, or debug. Persistent scene nodes are the default for authored structure and must be visible in the editor, saved to `.tscn`, and covered by a focused scene contract test when the scene is important. Runtime nodes remain valid for data-driven or temporary content, but must document their lifecycle.

## Consequences

Scene intent becomes visible in version control and the Godot editor. Tests will catch accidental removal or replacement of important saved nodes. The workflow does not prohibit runtime instancing, because that would break valid gameplay patterns such as projectiles and spawned enemies.
