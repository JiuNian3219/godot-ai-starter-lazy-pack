# 0004 Negative Tests Must Not Live In Excluded Paths

Date: 2026-06-04

## What Happened

A dependency-audit negative test was first created under `.tmp/`, but the audit script intentionally excludes `.tmp/`. The test appeared to show that the audit was broken, when the test fixture was simply outside the scanned paths.

## Why It Matters

Validation of validation tools must use paths that the tool actually scans. Otherwise false negatives can hide real behavior.

## Detection

When testing audit scripts, place temporary fixtures outside ignored directories or explicitly account for ignore rules.

## Rule Added

Dependency audit negative checks should use a non-excluded temporary directory and delete it after the check.

