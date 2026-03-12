---
name: refactor-code
description: >
  Safe, behavior-preserving code improvements: naming, extraction, deduplication,
  complexity reduction, and modernization. Use when asked to "refactor this",
  "clean up this code", "improve this", "simplify this", "extract this function",
  or "reduce duplication". Always runs tests after each change.
---

# Refactor Code Skill

**Core rule: Behavior preservation is non-negotiable.**
If tests fail after any change — STOP and revert immediately.

## Step 1 — Establish baseline
```bash
# Run tests to confirm green baseline
<detected test command>
```
If tests are already failing, STOP. Report this and do not proceed.

## Step 2 — Identify refactoring targets
Look for these in the specified code:

| Pattern | Refactoring |
|---|---|
| Variables named `x`, `data`, `temp`, `stuff` | Rename |
| Functions > 40 lines | Extract sub-functions |
| Same code block 3+ times | Extract + reuse |
| `if (a) { if (b) { if (c) {` deep nesting | Early returns / guard clauses |
| Magic numbers: `if (status === 3)` | Named constants |
| Boolean flags in function args | Separate functions or options object |
| Long parameter lists (> 4 params) | Options object |
| `async` function with no `await` | Remove async |
| Outdated syntax | Modernize (optional chaining, nullish coalescing, etc.) |

## Step 3 — Apply one change at a time
For each refactoring:
1. State what you're changing and why.
2. Apply the change.
3. Run tests — confirm still green.
4. Only then proceed to the next change.

**Never bundle multiple refactors into one step.**

## Step 4 — Do NOT
- Change public API signatures
- Change observable behavior
- Add new dependencies
- Rewrite logic that works, even if you'd write it differently
- Refactor code unrelated to what was asked

## Step 5 — Report
```
REFACTORING SUMMARY
===================
Files changed: <list>
Changes applied:
  1. <description of change + why>
  2. <description of change + why>
  ...

Test result: ✅ <N> passed / ❌ FAILED — reverted
```
