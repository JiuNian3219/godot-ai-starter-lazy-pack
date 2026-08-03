# 0003 Do Not Trust Noninteractive Summary Output

Date: 2026-06-04

## What Happened

Claude Code non-interactive `-p` mode successfully modified files, but returned little or no textual summary in this Windows environment.

## Why It Matters

A missing summary does not mean no work happened. Conversely, a nice summary would not prove the work is correct.

## Detection

Always inspect `git status`, relevant diffs, and verification output after a non-interactive Claude Code run.

## Rule Added

Treat `git diff` plus `scripts/verify.ps1` as the source of truth. Do not use agent summary text as the final acceptance signal.

