---
name: changelog
description: >
  Generate a structured changelog from git commits. Use when asked to
  "generate changelog", "write release notes", "what changed in this release",
  "summarize commits", or "create CHANGELOG.md".
---

# Changelog Skill

## Step 1 — Get commits
```bash
# Since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline --no-merges

# Last N commits if no tags
git log --oneline --no-merges -30

# Between two refs
git log <from>..<to> --oneline --no-merges
```

## Step 2 — Categorize by Conventional Commits type
Group commits into sections:
- `feat:` → **New Features**
- `fix:` → **Bug Fixes**
- `perf:` → **Performance**
- `refactor:` → **Refactoring**
- `test:` → **Tests**
- `docs:` → **Documentation**
- `ci:` → **CI/CD**
- `chore:` → **Maintenance**
- `BREAKING CHANGE:` → **⚠️ Breaking Changes** (always first)

## Step 3 — Write changelog entry

```markdown
## [x.y.z] - YYYY-MM-DD

### ⚠️ Breaking Changes
- **auth**: removed deprecated `loginWithPassword()` — use `login()` instead (#234)

### New Features
- **payments**: add Stripe subscription support with webhook handling (#289)
- **api**: add cursor-based pagination to `/users` endpoint (#291)

### Bug Fixes
- **auth**: fix session not invalidated on password change (#287)
- **db**: handle null `updatedAt` in user serializer (#285)

### Performance
- **api**: add Redis caching to product list endpoint, 80% latency reduction (#288)

### Refactoring
- **users**: extract UserRepository from UserService (#283)

### Maintenance
- bump `express` from 4.18.2 to 4.19.0
- bump `typescript` from 5.3 to 5.4
```

## Step 4 — Update CHANGELOG.md
If `CHANGELOG.md` exists, prepend the new entry after the header.
If it doesn't exist, create it with the new entry.

## Output
Show the generated changelog entry and confirm where it was written.
