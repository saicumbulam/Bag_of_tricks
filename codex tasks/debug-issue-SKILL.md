---
name: debug-issue
description: >
  Deep bug investigation and root cause analysis. Use when debugging an error,
  exception, unexpected behavior, regression, or crash. Triggered by phrases like
  "debug this", "why is this failing", "find the bug", "investigate this error",
  or when a stack trace or error message is mentioned.
---

# Debug Issue Skill

You are performing systematic root-cause analysis. Follow this exact protocol.

## Phase 1 — Reproduce
1. Identify the exact error message, stack trace, or unexpected behavior described.
2. Locate the failing code path in the repository.
3. Confirm you can trace the failure to a specific line or condition.
4. State: **"Reproduction confirmed at: `<file>:<line>`"**

## Phase 2 — Isolate
1. Read the failing function fully, including all called functions.
2. Identify ALL code paths that could reach the failure point.
3. List 2–3 ranked hypotheses with confidence %:
   ```
   Hypothesis 1 (70%): <description>
   Hypothesis 2 (20%): <description>
   Hypothesis 3 (10%): <description>
   ```

## Phase 3 — Verify
- Test each hypothesis by reading relevant code — do NOT modify yet.
- Eliminate false hypotheses by finding contradicting evidence.
- Confirm the true root cause with a clear reason why others are wrong.

## Phase 4 — Fix
- Apply the **minimal** change that resolves the root cause.
- Do not refactor, optimize, or clean up unrelated code.
- Run the test suite after the fix.

## Phase 5 — Document
Conclude with this exact block:
```
ROOT CAUSE:  <one sentence>
FILE:        <file>:<line>
FIX APPLIED: <description of change>
TEST RESULT: <pass/fail + command run>
REGRESSION:  <test that would catch this — write it if it doesn't exist>
RELATED:     <any other code with the same bug pattern>
```

## Search patterns to check
- Off-by-one errors in loops and array access
- Null/nil/undefined dereferences
- Race conditions and missing locks
- Incorrect assumptions about data shape or type
- Missing error propagation
- State not reset between requests
- Environment-specific behavior (dev vs prod config)
