---
description: Write tests for a function, module, or recent changes
argument-hint: [FILE=<path>] [FUNCTION=<n>] [TYPE=unit|integration|e2e]
---

Write $TYPE tests (default: unit) for:
$FILE $FUNCTION

## Instructions

1. First read the existing test files to match exact style, imports, and framework.
2. Read the code to be tested thoroughly — understand all paths.
3. Write tests covering:
   - Happy path (normal expected input)
   - Edge cases (empty, null, zero, boundary values)
   - Error conditions (invalid input, downstream failures)
   - Any async/concurrent behavior

4. Each test must:
   - Have a descriptive name: `it("returns null when user not found")`
   - Test ONE behavior per test
   - Use realistic test data
   - Assert on behavior, not implementation

5. Do NOT:
   - Mock internal modules (only mock external I/O: DB, HTTP, filesystem)
   - Write tests that always pass regardless of logic
   - Skip negative/error cases

After writing tests, run them and report results.
