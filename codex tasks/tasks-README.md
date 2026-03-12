# Codex Tasks, Skills & Custom Prompts
# How to add specific tasks to Codex

There are THREE mechanisms for adding tasks to Codex:

---

## 1. SKILLS — `~/.codex/skills/<name>/SKILL.md`
Auto-triggered by Codex OR explicitly called with `$skill-name`

### Install
```bash
mkdir -p ~/.codex/skills
cp -r skills/* ~/.codex/skills/
```

### Skills included:

| Skill | Trigger phrases | What it does |
|---|---|---|
| `$debug-issue` | "debug this", "why is this failing", "find the bug" | Root cause analysis with SYMPTOM→CAUSE→FIX→TEST |
| `$run-tests` | "run tests", "did tests pass", "what's failing" | Detects framework, runs suite, reports failures |
| `$code-review` | "review this", "check my PR", "audit this" | 7-dimension review: correctness, security, perf, etc. |
| `$git-commit` | "commit this", "create a commit", "stage and commit" | Conventional Commits message + safe staging |
| `$check-security` | "security audit", "find vulnerabilities", "scan for secrets" | Scans for injection, secrets, weak auth, CVEs |
| `$generate-docs` | "document this", "add docstrings", "update README" | JSDoc, Python docstrings, Go comments |
| `$fix-ci` | "fix CI", "pipeline is broken", "GitHub Actions failing" | Diagnoses and fixes CI failures |
| `$changelog` | "generate changelog", "write release notes" | Structured changelog from git commits |
| `$refactor-code` | "refactor this", "clean up", "reduce duplication" | Safe refactoring with test gates |
| `$db-check` | "check DB queries", "find N+1", "audit database" | N+1 detection, missing indexes, SQL injection scan |

### How to invoke
```
# Explicit — type $ then skill name in TUI
$debug-issue  ← Codex loads full instructions and starts the workflow

# Implicit — just describe your task naturally
"There's a bug in the auth middleware, can you help debug it?"
→ Codex auto-detects and activates $debug-issue

# In a prompt
"Use the $run-tests skill to check if my changes broke anything"
```

### Enable skills feature flag
```bash
codex --enable skills
# Or add to config.toml:
# [features]
# skills = true  (if not already on by default in your version)
```

---

## 2. CUSTOM PROMPTS — `~/.codex/prompts/<name>.md`
Reusable prompt templates, invoked as `/prompts:<name>` in the TUI

> ⚠️ Custom prompts are deprecated in favor of Skills.
> Use Skills for new workflows. Prompts still work for simple templates.

### Install
```bash
mkdir -p ~/.codex/prompts
cp prompts/* ~/.codex/prompts/
```

### Prompts included:

| Command | What it does |
|---|---|
| `/prompts:draft-pr` | Writes a PR description from current branch diff |
| `/prompts:explain-code` | Deep explanation of a file or function |
| `/prompts:write-tests` | Writes tests for specified code |

### How to invoke with arguments
```
/prompts:draft-pr BASE=develop TITLE="Add payment retry logic"

/prompts:explain-code FILE=src/auth/middleware.ts

/prompts:write-tests FILE=src/services/user.ts FUNCTION=getProfile TYPE=unit
```

---

## 3. NON-INTERACTIVE (codex exec) — Run tasks from your terminal
Use `codex exec` to trigger Codex tasks directly from shell scripts, Makefiles, or CI.

### Examples

```bash
# Run a debug investigation headlessly
codex exec --profile debug "Debug the failing test in src/auth/auth.test.ts"

# Security scan before pushing
codex exec --profile review \
  "Use the check-security skill to audit src/api/ for vulnerabilities. Output JSON."

# Auto-generate changelog on release
codex exec --profile fast \
  "Use the changelog skill to generate release notes from the last git tag. Write to CHANGELOG.md."

# CI: verify tests after a PR
codex exec --approval never --sandbox workspace-write \
  "Run the full test suite and report any failures with suggested fixes"

# Pipe a stack trace for instant debugging
cat logs/error.log | codex exec - "Debug this error and find the root cause"
```

### Wire into a Makefile
```makefile
review:
	codex exec --profile review "Use code-review skill on files changed in the last commit"

security:
	codex exec --profile review "Use check-security skill on the src/ directory"

changelog:
	codex exec --profile fast "Use changelog skill to update CHANGELOG.md from last tag"

docs:
	codex exec --profile fast "Use generate-docs skill on all undocumented public functions in src/"
```

---

## Quick Reference Card

```
You type:                          What happens:
─────────────────────────────────────────────────────────────────
"debug this stack trace"           → $debug-issue auto-triggers
"$debug-issue"                     → $debug-issue explicit trigger
"run tests"                        → $run-tests auto-triggers
"$run-tests"                       → $run-tests explicit trigger
"review my PR"                     → $code-review auto-triggers
"commit this"                      → $git-commit auto-triggers
"security audit"                   → $check-security auto-triggers
"document this function"           → $generate-docs auto-triggers
"CI is broken"                     → $fix-ci auto-triggers
"generate changelog"               → $changelog auto-triggers
"refactor this"                    → $refactor-code auto-triggers
"check for N+1 queries"            → $db-check auto-triggers
/prompts:draft-pr BASE=main        → expands PR template
/prompts:explain-code FILE=x.ts    → deep code explanation
```
