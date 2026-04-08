# Test Verification Checklist

A comprehensive checklist for verifying unit tests and integration tests for a feature, with associated Codex CLI prompts for each check.

> **Usage:** Replace `<feature_path>` and `<test_path>` with the actual paths in your repo before running prompts.

---

## 1. Unit Tests

### 1.1 Coverage & Completeness

- [ ] Every public function/method has at least one test
- [ ] All branches (if/else, switch, ternaries) are covered
- [ ] Edge cases tested (null, empty, zero, negative, max, boundaries)
- [ ] Error paths and exception handling tested
- [ ] All return values/types verified
- [ ] Private helpers tested indirectly through public APIs
- [ ] Async/concurrent code paths tested
- [ ] Default parameter values exercised

**Codex Prompts:**

```
codex "List every public function in <feature_path> and map each to its test file. Flag any function without tests."
```
```
codex "Run unit tests for <feature_path> with coverage. Report any branches, lines, or functions below 90%. Show uncovered line numbers."
```
```
codex "For each function in <feature_path>, list edge cases (null, empty, boundary, negative, max) that are NOT covered in <test_path>. Suggest test cases."
```
```
codex "For every function in <feature_path> that throws or returns errors, verify the error path is tested. List missing error tests with file:line."
```
```
codex "Find async functions in <feature_path> and verify each has tests for resolved, rejected, and concurrent invocation paths."
```

---

### 1.2 Test Quality

- [ ] Each test asserts something meaningful (no empty/no-op tests)
- [ ] Tests follow Arrange-Act-Assert (AAA) pattern
- [ ] One logical assertion per test (or tightly related)
- [ ] Test names clearly describe scenario and expected outcome
- [ ] No hardcoded magic values that should be constants/fixtures
- [ ] No commented-out tests or `skip`/`xit`/`.only` without justification
- [ ] No duplicate tests covering identical scenarios

**Codex Prompts:**

```
codex "Scan <test_path> for tests with no assertions, only truthy/non-null checks, or weak matchers. List them with file:line."
```
```
codex "Review test names in <test_path>. Flag any that don't clearly describe the scenario and expected outcome. Suggest renames using 'should_X_when_Y' format."
```
```
codex "Find all skipped, pending, commented-out, .only, or .skip tests in <test_path>. List them with file:line and reason if any."
```
```
codex "Identify duplicate or near-duplicate tests in <test_path> and suggest consolidations."
```
```
codex "Check tests in <test_path> for AAA structure (Arrange, Act, Assert). Flag tests where structure is unclear or violated."
```

---

### 1.3 Isolation

- [ ] External dependencies mocked (DB, network, filesystem, time)
- [ ] No real network calls
- [ ] No real file I/O outside tmp directories
- [ ] No shared mutable state between tests
- [ ] Setup/teardown properly cleans up resources
- [ ] Tests are deterministic (no randomness, time, or order dependencies)

**Codex Prompts:**

```
codex "Find any tests in <test_path> that touch real network, real filesystem (outside tmp), real DB, or shared global state. List violations."
```
```
codex "List all external dependencies in <feature_path> and verify each is mocked in the corresponding unit tests. Flag any real calls."
```
```
codex "Identify tests in <test_path> that depend on Date.now, time.time(), Math.random, random.*, system time, or test execution order. Suggest fixes."
```
```
codex "Inspect setup/teardown in <test_path>. Verify resources (mocks, temp files, patches) are cleaned up even when tests fail."
```

---

### 1.4 Execution

- [ ] All unit tests pass locally
- [ ] Tests run fast (< 100ms per unit test ideally)
- [ ] Coverage report generated and meets threshold
- [ ] No warnings or deprecation messages during runs
- [ ] Tests pass in CI environment

**Codex Prompts:**

```
codex "Run all unit tests in <test_path> and report pass/fail counts, total runtime, and any tests slower than 100ms."
```
```
codex "Run unit tests with coverage for <feature_path> and verify total coverage meets the project threshold. Output a summary."
```
```
codex "Run unit tests in <test_path> and capture all warnings, deprecation notices, and stderr output. List them."
```

---

## 2. Integration Tests

### 2.1 Scope & Coverage

- [ ] Every cross-component interaction has a test
- [ ] All API endpoints tested (happy path + error cases)
- [ ] Database read/write paths verified
- [ ] External service integrations tested (real or contract mocks)
- [ ] Authentication/authorization flows tested
- [ ] Message queue/event flows verified end-to-end
- [ ] Data migrations tested (if applicable)
- [ ] Rollback/failure scenarios tested

**Codex Prompts:**

```
codex "List every API endpoint, DB query, and external service call in <feature_path>. For each, confirm there is a corresponding integration test."
```
```
codex "For each API endpoint in <feature_path>, verify integration tests cover happy path, validation errors, auth failures, and server errors."
```
```
codex "List all DB operations in <feature_path> and verify integration tests cover both read and write paths, including transaction rollback."
```
```
codex "Identify all auth/authz checks in <feature_path> and confirm integration tests cover authorized, unauthorized, and forbidden cases."
```

---

### 2.2 Environment & Setup

- [ ] Test DB/services spin up cleanly (containers, fixtures)
- [ ] Schema migrations applied before tests
- [ ] Test data seeded reproducibly
- [ ] Environment variables/config isolated from prod
- [ ] Cleanup runs even on test failure
- [ ] No state leaks between test runs

**Codex Prompts:**

```
codex "Inspect the integration test setup in <test_path>. Verify DB containers/fixtures spin up cleanly and migrations apply before tests run."
```
```
codex "Check that test data seeding in <test_path> is reproducible and idempotent. Flag any tests that depend on prior test state."
```
```
codex "Verify environment variables and config used in <test_path> are isolated from production. List any prod URLs, credentials, or hosts."
```
```
codex "Run the integration test suite twice in a row and confirm no state leaks between runs. Report any failures on the second run."
```

---

### 2.3 Contracts & Boundaries

- [ ] API request/response schemas validated
- [ ] Error responses match documented contract
- [ ] Status codes correct for all paths
- [ ] Backward compatibility verified
- [ ] Cross-team API contracts honored

**Codex Prompts:**

```
codex "Compare request/response schemas in <feature_path> against the integration tests. Flag any field, type, or status code mismatches."
```
```
codex "For each error response in <feature_path>, verify integration tests assert the documented error code, message, and HTTP status."
```
```
codex "Check backward compatibility: run integration tests against the previous API version and flag breaking changes."
```
```
codex "Verify the chassis ID API contract tests in <test_path> cover every field and status code in the Plan Service and GPUCP API spec. Flag missing cases."
```

---

### 2.4 Reliability

- [ ] Tests handle timing/eventual consistency properly (no flaky `sleep`)
- [ ] Retries and timeouts tested
- [ ] Concurrency/race conditions exercised
- [ ] Tests pass repeatedly (run 5–10x to detect flakes)

**Codex Prompts:**

```
codex "Find all hardcoded sleep/wait calls in <test_path> and suggest replacing them with proper polling or event-based waits."
```
```
codex "List retry and timeout logic in <feature_path> and verify integration tests cover both successful retries and exhausted retries."
```
```
codex "Run the integration test suite for <feature_path> 10 times. Report any test that fails intermittently or has variable runtime > 2x median."
```
```
codex "Identify potential race conditions in <feature_path> and confirm integration tests exercise concurrent access patterns."
```

---

## 3. Pre-Merge Gate

Run these final checks before declaring the feature done.

**Codex Prompts:**

```
codex "Run unit + integration tests for <feature_path>, generate coverage report, lint test files, and produce a single pass/fail summary with any blocker issues."
```
```
codex "Generate a test verification report for <feature_path> covering: total tests, pass rate, coverage %, flaky tests, missing edge cases, and contract gaps."
```
```
codex "Diff <feature_path> against main branch. For every changed function, verify a corresponding test exists or was updated."
```

---

## Suggested Workflow

1. **Discovery** — Map functions to tests (1.1, 2.1)
2. **Quality** — Audit assertions, naming, structure (1.2)
3. **Isolation** — Verify mocks and determinism (1.3)
4. **Environment** — Check setup/teardown (2.2)
5. **Contracts** — Validate API schemas (2.3)
6. **Reliability** — Detect flakes (2.4)
7. **Pre-merge gate** — Final aggregated report (3)

Pipe each prompt's output into a markdown file under `./test-audit/` to maintain an audit trail.
