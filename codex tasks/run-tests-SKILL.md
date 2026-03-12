---
name: run-tests
description: >
  Detect the project's test framework, run the full test suite, interpret
  results, and report failures clearly. Use when asked to "run tests",
  "check tests", "did tests pass", "what's failing", or after making
  code changes to verify nothing broke.
---

# Run Tests Skill

## Step 1 — Detect test framework
Check for these in order and use the first match:

```bash
# Node / JS / TS
[ -f package.json ] && cat package.json | grep -E '"test"|"jest"|"vitest"|"mocha"'

# Python
[ -f pyproject.toml ] && grep -E 'pytest|unittest' pyproject.toml
[ -f setup.py ] && grep 'pytest' setup.py

# Go
[ -f go.mod ] && echo "Use: go test ./..."

# Rust
[ -f Cargo.toml ] && echo "Use: cargo test"

# Ruby
[ -f Gemfile ] && grep 'rspec\|minitest' Gemfile

# Makefile fallback
[ -f Makefile ] && grep '^test:' Makefile
```

## Step 2 — Run tests
Execute the detected test command. Common ones:
- `pnpm test` / `npm test` / `yarn test`
- `pnpm test --coverage` for coverage report
- `pytest -v` / `pytest --tb=short`
- `go test ./... -v`
- `cargo test`
- `bundle exec rspec`

## Step 3 — Parse and report results

**If all pass:**
```
✅ ALL TESTS PASSED
Suite:    <name>
Tests:    <N> passed, 0 failed
Duration: <time>
Coverage: <% if available>
```

**If any fail:**
```
❌ TEST FAILURES DETECTED
Failed: <N> tests

FAILURE 1:
  Test:    <full test name>
  File:    <file>:<line>
  Error:   <error message>
  Expected: <expected value>
  Got:      <actual value>

[repeat for each failure]

SUMMARY:
  Passed:  <N>
  Failed:  <N>
  Skipped: <N>
```

## Step 4 — Diagnose failures
For each failing test:
1. Read the test to understand what it's asserting.
2. Read the production code it's testing.
3. Determine if the failure is: (a) a real bug, (b) a stale test, or (c) an environment issue.
4. Suggest the fix.

Do NOT auto-fix unless explicitly asked.
