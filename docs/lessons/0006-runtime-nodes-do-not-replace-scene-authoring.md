# 0006 Runtime Nodes Do Not Replace Scene Authoring

Date: 2026-08-04

## What Happened

AI-generated Godot code created nodes in `_ready()` or other runtime paths when the user expected to see and edit them in the Godot scene tree.

## Why It Matters

The game can appear to work while layout, collisions, cameras, and level structure remain hidden in scripts. This makes tuning, reviews, scene reuse, and later content production harder.

## Detection

Compare the changed `.tscn` file, inspect the editor scene tree, and run a focused scene contract test that asserts required persisted node paths.

## Rule Added

Classify nodes as persistent scene, runtime, or debug before implementation. Persistent authored structure must be saved to `.tscn`; runtime nodes must document why they are dynamic and when they are freed.
