# 0006 Godot 4.7.1 and Release Package

Status: Accepted
Date: 2026-08-04

## Context

The template was pinned to Godot 4.6.3. The user wants an AI-shareable package that can create a project without separately locating an engine download.

## Decision

Move the template baseline to Godot 4.7.1 stable. Keep engine binaries ignored by Git, but let `scripts/build_lazy_pack.ps1 -IncludeGodot` generate a separate Windows x64 ZIP containing the official Godot 4.7.1 executable pair and an engine manifest. Publish that ZIP as a private GitHub Release asset.

## Consequences

The source repository remains small and auditable. A release asset provides an immediately installable package and exact engine reproducibility. The packaged engine is Windows x64 only; other platforms require separate artifacts.

## Verification

Run the project verification with Godot 4.7.1, build both package variants, install a project from the bundled ZIP, and confirm a fresh shell resolves the copied project-local engine.
