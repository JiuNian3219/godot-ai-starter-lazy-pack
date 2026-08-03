# 0005 Repository README AI Install Entrypoint

Status: Accepted
Date: 2026-08-04

## Context

The reusable template had detailed installation instructions under `docs/`, but a GitHub link alone did not give a new AI agent an obvious, self-contained entry point for creating a project.

## Decision

Add a repository-root `README.md` with a copyable installation request and an explicit AI workflow: use or clone the template repository, build the ZIP, discover and confirm Godot, install through `install.ps1`, then verify in a new shell.

## Consequences

The repository link becomes a useful handoff artifact without duplicating the detailed constraints in `docs/next_project_prompt.md`. Private-repository access remains a required precondition.

## Verification

Confirm the README links to the canonical prompt and describes the actual scripts and saved Godot-path behavior. Run `scripts/verify.ps1` and build the lazy pack.
