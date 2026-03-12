---
name: fix-ci
description: >
  Inspect failing CI/CD pipeline, identify the root cause, and propose or apply
  a fix. Use when asked to "fix CI", "CI is failing", "pipeline is broken",
  "GitHub Actions failing", "build is failing", or "why is CI red".
---

# Fix CI Skill

## Step 1 — Find CI configuration
```bash
# GitHub Actions
ls .github/workflows/

# GitLab CI
cat .gitlab-ci.yml 2>/dev/null

# CircleCI
cat .circleci/config.yml 2>/dev/null

# Bitbucket Pipelines
cat bitbucket-pipelines.yml 2>/dev/null

# Jenkins
cat Jenkinsfile 2>/dev/null
```

## Step 2 — Identify the failure
If a failure log is provided, parse it for:
- The exact error message
- The step/job that failed
- The line of code or command that errored

If no log provided, check recent git changes that could affect CI:
```bash
git log --oneline -10
git diff HEAD~1 -- .github/ package.json pyproject.toml go.mod Cargo.toml
```

## Step 3 — Categorize the failure

**Build failures:**
- Missing dependency? Check lock file vs install command
- Type error? Find the problematic type
- Compile error? Read the full error message

**Test failures:**
- Run tests locally first
- Identify flaky tests (check git history for repeated failures)
- Environment differences (missing env vars, DB, ports)

**Lint/format failures:**
```bash
# Auto-fix lint issues
pnpm lint --fix 2>/dev/null || npm run lint:fix 2>/dev/null
black . 2>/dev/null
gofmt -w . 2>/dev/null
cargo fmt 2>/dev/null
```

**Dependency/install failures:**
- Outdated lock file
- Missing peer dependencies
- Version constraint conflicts
- Private registry auth issues

**Environment failures:**
- Missing secrets/env vars in CI config
- Service containers not configured (DB, Redis)
- Insufficient permissions

## Step 4 — Apply fix
State what the root cause is before applying any change.
Apply the minimal fix.
Describe what changed and why it fixes the CI.

## Step 5 — Report
```
CI FAILURE ANALYSIS
===================
Pipeline: <tool>
Job:      <job name>
Step:     <step name>
Error:    <error message>

ROOT CAUSE: <explanation>
FIX:        <what was changed>
VERIFY:     <how to confirm it's fixed locally before pushing>
```
