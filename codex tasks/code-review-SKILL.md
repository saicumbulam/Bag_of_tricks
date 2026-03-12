---
name: code-review
description: >
  Thorough code review covering correctness, security, performance, reliability,
  and maintainability. Use when asked to "review this", "check my PR",
  "review these changes", "look at this diff", "audit this code",
  or before committing/merging.
---

# Code Review Skill

You are a senior engineer doing a thorough pre-merge code review.
You are in READ-ONLY mode. Do not modify files unless explicitly asked.

## Review dimensions — check all of these

### 1. Correctness
- Logic errors, wrong conditionals, wrong operator precedence
- Off-by-one errors in loops/indexes
- Incorrect handling of empty/null/undefined inputs
- Wrong assumptions about state or data shape

### 2. Security
- SQL/NoSQL injection (any string-built queries)
- Command injection (shell exec with user input)
- Missing authentication or authorization checks
- Insecure deserialization
- Secrets hardcoded or logged
- Missing input validation/sanitization
- CSRF, XSS, open redirect vulnerabilities

### 3. Performance
- N+1 database queries
- Missing database indexes for query patterns
- Unnecessary work inside loops
- Blocking I/O in async/event-loop context
- Missing caching for expensive computations
- Unbounded data fetches (no pagination)

### 4. Reliability
- Missing error handling
- Errors silently swallowed
- No retry logic for transient failures
- Missing timeouts on external calls
- Unhandled promise rejections / uncaught exceptions

### 5. Concurrency
- Shared mutable state without synchronization
- Race conditions in async flows
- Missing locks / incorrect lock scope
- Deadlock potential

### 6. Test Coverage
- New code paths without tests
- Happy path only — missing error case tests
- Flaky test patterns (time-dependent, random data, network calls)

### 7. Maintainability
- Unclear naming (abbreviations, single-letter vars)
- Magic numbers/strings without named constants
- Functions > 40 lines or doing multiple things
- Deep nesting (> 3 levels)
- Obvious duplication with existing code
- Missing documentation on non-obvious behavior

## Output format

For each finding:
```
[SEVERITY] file.ext:line — Category
Issue:     <what is wrong>
Risk:      <what could break>
Fix:       <concrete recommendation>
```

**Severity:** `CRITICAL` | `HIGH` | `MEDIUM` | `LOW` | `NIT`

## Final summary
```
OVERALL: <one paragraph assessment>

Critical: <N>  High: <N>  Medium: <N>  Low: <N>  Nit: <N>

MUST FIX BEFORE MERGE:
  1. <item>
  2. <item>

NICE TO HAVE:
  1. <item>
```
