# 0002 Godot Signal Tests Need Stable Counters

Date: 2026-06-04

## What Happened

A generated GDScript test used local integer mutation inside a signal lambda. The signal count did not update as expected.

## Why It Matters

Signal tests can silently test the wrong behavior if the counter pattern is unreliable.

## Detection

When testing signals in lightweight SceneTree scripts, use mutable containers such as arrays or dictionaries for counters.

## Rule Added

Signal count tests should use patterns like `var count := [0]` and mutate `count[0]`.

