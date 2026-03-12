---
name: git-commit
description: >
  Stage files, write a high-quality Conventional Commits message, and commit.
  Use when asked to "commit this", "create a commit", "write a commit message",
  "stage and commit", or "commit my changes". Optionally creates a PR draft.
---

# Git Commit Skill

## Step 1 — Understand the changes
```bash
git status
git diff --staged       # what's already staged
git diff               # what's unstaged
```
Read through the diff to understand what actually changed.

## Step 2 — Stage files (if nothing staged)
If the user hasn't specified files, stage all tracked changes:
```bash
git add -u             # stage tracked modified/deleted files
# OR
git add <specific files>   # if user specified
```
**Never stage:**
- `.env`, `*.secret`, `*credentials*`, `*token*` files
- Build artifacts (`dist/`, `build/`, `*.pyc`, `node_modules/`)
- Lock files unless they were intentionally changed

## Step 3 — Write the commit message

Follow **Conventional Commits** format:
```
<type>(<scope>): <short description>

[optional body — explain WHY not WHAT]

[optional footer — BREAKING CHANGE, Closes #123]
```

**Types:**
- `feat` — new feature or behavior
- `fix` — bug fix
- `refactor` — code change without behavior change
- `test` — adding or updating tests
- `docs` — documentation only
- `chore` — build, deps, config changes
- `perf` — performance improvement
- `ci` — CI/CD changes

**Rules for the subject line:**
- ≤ 72 characters
- Lowercase after the colon
- No period at end
- Imperative mood: "add", "fix", "remove" (not "added", "fixes")

**Examples:**
```
feat(auth): add OAuth2 login with Google
fix(api): handle null userId in getProfile endpoint
refactor(db): extract query builder from UserRepository
test(payments): add edge cases for zero-amount transactions
```

## Step 4 — Commit
```bash
git commit -m "<message>"
```

## Step 5 — Report
```
✅ COMMITTED
Hash:    <short SHA>
Branch:  <current branch>
Message: <full commit message>
Files:   <N> changed, <N> insertions, <N> deletions
```

**Do NOT push** unless explicitly asked.
**Do NOT commit to main/master** without explicit confirmation.
