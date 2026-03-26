---
name: ralph-mode
description: >
  Autonomous development loops with iteration, backpressure gates, and
  completion criteria for Codex CLI. Use for sustained coding sessions that
  require multiple iterations, test validation, and structured progress
  tracking. Supports Next.js, Python, FastAPI, and GPU workloads.
  Delegates to specialised Codex subagents from .codex/agents/.
---

# Ralph Mode — Autonomous Development Loops (Codex Edition)

Ralph Mode implements iterative, self-correcting autonomous development inside
**Codex CLI**. Each iteration picks one task, implements it, runs backpressure
gates, and reports to `PROGRESS.md` before exiting. Codex does **not**
auto-spawn subagents; every delegation is an explicit prompt from the parent
agent.

---

## When to Use

- Building features that need multiple refinement passes
- Projects with measurable acceptance criteria (tests, typecheck, lint, build)
- Long sessions where you want autonomous progress, not turn-by-turn guidance
- Any workflow that benefits from isolated context per task

---

## Codex vs OpenClaw — Key Differences

| Concept | OpenClaw | Codex |
|---|---|---|
| Spawn sub-task | `sessions_spawn` | Explicit delegation prompt |
| List running agents | `sessions_list` | Not available; track via `PROGRESS.md` |
| Kill a session | `sessions_kill` | `Ctrl+C` / restart Codex |
| Agent config | `AGENTS.md` prose | `.codex/agents/*.toml` |
| Agent discovery | Auto-scan | Explicit mention in prompt |
| Sandbox | Varies | `sandbox_mode` per agent |

---

## File Structure

```
project-root/
├── IMPLEMENTATION_PLAN.md      # Shared state, updated each iteration
├── PROGRESS.md                 # Mandatory per-iteration log
├── .codex/
│   └── agents/                 # Ralph subagents (copy from ralph-mode-codex/)
│       ├── ralph-orchestrator.toml
│       ├── ralph-planner.toml
│       ├── ralph-implementer.toml
│       ├── ralph-validator.toml
│       └── ralph-reviewer.toml
├── specs/                      # Requirements (one file per topic)
│   └── <topic>.md
└── src/
    └── lib/                    # Shared utilities
```

### Install subagents

```bash
# Project-scoped (recommended)
mkdir -p .codex/agents
cp ralph-mode-codex/.codex/agents/*.toml .codex/agents/

# Or global (available in all projects)
mkdir -p ~/.codex/agents
cp ralph-mode-codex/.codex/agents/*.toml ~/.codex/agents/
```

---

## Three-Phase Workflow

### Phase 1 — Requirements

- Write specs in `specs/` (one file per topic, one topic per sentence without "and")
- Define acceptance criteria: observable, verifiable outcomes
- Example spec scope test:
  - ✅ `"JWT-based user authentication"`
  - ❌ `"Auth, profiles, and billing"` → split into 3 specs

### Phase 2 — Planning  *(delegate to `ralph-planner`)*

Prompt pattern:
```
Use ralph-planner to perform a gap analysis against specs/ and generate
IMPLEMENTATION_PLAN.md. No implementation during this phase.
```

`ralph-planner` produces a prioritised task list. No code is written.

### Phase 3 — Building  *(iterative, delegate to `ralph-implementer`)*

One task per iteration. Prompt pattern:
```
Use ralph-implementer to pick the next uncompleted task from
IMPLEMENTATION_PLAN.md, implement it, run validation, and update PROGRESS.md.
```

---

## Backpressure Gates

Gates reject incomplete work automatically, driving convergence through
iteration rather than assumption.

### Programmatic (always required)

```
Tests:     npm run test      /  pytest
Typecheck: npx tsc --noEmit  /  mypy src/
Lint:      npm run lint      /  ruff check src/
Build:     npm run build
```

All gates must return exit code 0 before a task is marked `[x]`.

### Subjective (LLM-as-judge, use after programmatic gates pass)

```
Use ralph-reviewer to assess UX quality of the new onboarding flow.
Criteria: user can complete core flow without confusion.
Return: PASS or FAIL with specific feedback.
```

---

## IMPLEMENTATION_PLAN.md Format

```markdown
# Implementation Plan

## In Progress
- [ ] Task name (iteration N)
  - Notes: discoveries, blockers

## Completed
- [x] Task name (iteration N)

## Backlog
- [ ] Future task
```

---

## PROGRESS.md Format — Mandatory After Every Iteration

`ralph-implementer` **must** write this after every iteration. Parent agents
and `loop.sh` tail this file for status.

```markdown
# Ralph: [Task Name]

## Iteration [N] — [ISO timestamp]

### Status
Complete ✅ | Blocked ⛔ | Failed ❌

### What Was Done
- [Specific changes made]

### Validation
- Tests:     PASS / FAIL
- Typecheck: PASS / FAIL
- Lint:      PASS / FAIL
- Build:     PASS / FAIL

### Blockers
None | [Description + attempted solutions]

### Next Step
[Specific next task from IMPLEMENTATION_PLAN.md]

### Files Changed
- `path/to/file` — [brief description]
```

### Completion entry

```markdown
## Status: COMPLETE ✅

**Finished:** [ISO timestamp]

### Final Verification
- [x] TypeScript: Pass
- [x] Tests: Pass
- [x] Build: Pass

### Testing Instructions
1. Run: `npm run dev`
2. Visit: `http://localhost:3000/feature`
3. Verify: [specific checks]
```

---

## Subagent Roles

All five Ralph subagents live in `.codex/agents/`. Codex will not
auto-spawn them — reference them explicitly in your delegation prompts.

| Subagent | Hat | When to Delegate |
|---|---|---|
| `ralph-orchestrator` | Coordinator | Outer-loop management, planning the session |
| `ralph-planner` | Architect | Phase 2 gap analysis + IMPLEMENTATION_PLAN.md generation |
| `ralph-implementer` | Implementer | One task: code change + gate validation + PROGRESS.md |
| `ralph-validator` | Tester | Gate-only pass: run tests/lint/typecheck and report |
| `ralph-reviewer` | Reviewer | LLM-as-judge for subjective criteria; binary PASS/FAIL |

### Integrating awesome-codex-subagents

Ralph Mode is designed to compose with the broader
[awesome-codex-subagents](https://github.com/VoltAgent/awesome-codex-subagents)
library. Copy any of these alongside the Ralph agents for richer workflows:

**Recommended companions:**

| Category | Agent | Use in Ralph Mode |
|---|---|---|
| Core Dev | `fullstack-developer` | Implementation on complex full-stack tasks |
| Core Dev | `backend-developer` | API / service layer implementation |
| Core Dev | `frontend-developer` | React/Vue UI implementation |
| Quality | `code-reviewer` | Pre-commit review gate |
| Quality | `qa-expert` | Test suite design for new features |
| Quality | `debugger` | Unblock a BLOCKED iteration |
| Quality | `error-detective` | Diagnose cryptic gate failures |
| Quality | `architect-reviewer` | Phase 1 architecture validation |
| Quality | `performance-engineer` | Performance gate before final commit |
| Dev Exp | `refactoring-specialist` | Targeted refactor tasks |
| Dev Exp | `documentation-engineer` | Auto-generate/update docs after features land |
| Dev Exp | `git-workflow-manager` | Branch strategy + commit discipline |
| Meta | `workflow-orchestrator` | Multi-stage session planning |
| Meta | `multi-agent-coordinator` | Parallelising independent tasks |
| Meta | `context-manager` | Trim context when iterations grow large |
| Data/AI | `llm-architect` | Tasks touching LLM infrastructure |
| Data/AI | `mlops-engineer` | ML pipeline tasks |

Install pattern:
```bash
cp path/to/awesome-codex-subagents/categories/01-core-development/fullstack-developer.toml .codex/agents/
```

Then reference in prompts:
```
Use fullstack-developer to implement the payments webhook handler.
Validate with ralph-validator after. Update PROGRESS.md.
```

---

## Delegation Prompt Patterns

### Single-file task (recommended default)
```
Use ralph-implementer.
File: src/lib/auth.ts
Change: Add verifyToken() function using jsonwebtoken.
Validate: npx tsc --noEmit && npm run test
Then update PROGRESS.md and exit.
```

### Planning phase
```
Use ralph-planner to read specs/ and existing src/, then produce
IMPLEMENTATION_PLAN.md. Do not write any application code.
```

### Validation only
```
Use ralph-validator to run npm run test, npx tsc --noEmit, npm run lint.
Report results in PROGRESS.md. Do not change any source files.
```

### Subjective review
```
Use ralph-reviewer to assess the checkout flow UX.
Criteria: user can add item to cart and complete purchase in under 4 clicks.
Verdict: PASS or FAIL with specific change requests written to PROGRESS.md.
```

### Unblocking a stuck iteration
```
Use debugger to investigate the failing test at src/__tests__/auth.test.ts.
Identify root cause, propose minimal fix.
Then use ralph-implementer to apply the fix and re-run gates.
```

### Parallel independent tasks
```
Spawn two subagents in parallel:
- ralph-implementer: implement GET /api/users route in src/app/api/users/route.ts
- documentation-engineer: write API docs for existing routes in docs/api.md
Wait for both. Summarise results.
```

---

## Stopping Conditions

| Signal | Meaning |
|---|---|
| All `IMPLEMENTATION_PLAN.md` tasks `[x]` | Loop complete |
| All acceptance criteria met | Loop complete |
| `PROGRESS.md` shows `Status: BLOCKED` | Intervene or escalate |
| Max iterations reached | Pause, re-evaluate scope |
| Manual `Ctrl+C` | Immediate stop |

---

## Loop Mechanics

### Outer loop (you, the parent agent, coordinate)

1. Run `loop.sh` or issue delegation prompts manually
2. Watch `PROGRESS.md` — it's the single source of truth
3. Intervene only when `BLOCKED` or gate failures repeat
4. Regenerate `IMPLEMENTATION_PLAN.md` when scope drifts — plans are cheap

### Inner loop (each delegated subagent executes)

1. **Study** — Read `IMPLEMENTATION_PLAN.md`, `specs/`, relevant `src/` files
2. **Select** — Pick the first uncompleted task
3. **Implement** — One file, one change (see Single-File Rule below)
4. **Validate** — Run all gates from `AGENTS.md` / project scripts
5. **Update** — Mark `[x]` in plan, write `PROGRESS.md`, commit
6. **Exit** — Fresh context on next iteration

### Single-File Rule (critical)

Each delegation gets **one file**. Not "all errors", not "check then decide".

```
# BAD — causes stalls
Fix all TypeScript errors across lib/db.ts, lib/auth.ts, and route.ts.

# GOOD — executes reliably
Fix lib/db.ts line 27: change PoolClient to pg.PoolClient.
Validate: npx tsc --noEmit
Exit after.
```

---

## Technology Stack Configs

### Next.js

```
specs/authentication.md, specs/database.md, specs/api-routes.md
src/app/, src/components/, src/lib/, src/types/

Validation:
  npm run test
  npx tsc --noEmit
  npm run lint
  npm run build
```

### Python / FastAPI

```
specs/data-pipeline.md, specs/api-endpoints.md
src/pipeline.py, src/models/, src/api/, src/tests/

Validation:
  pytest
  mypy src/
  ruff check src/
```

### GPU / ML

```
specs/model-architecture.md, specs/training-data.md
src/models/, src/training/, src/inference/

Validation:
  pytest tests/
  ruff check src/
  nvidia-smi  (sanity check only)
```

---

## Error Handling Requirements

If a subagent hits an unrecoverable error it **must**:

1. Write `PROGRESS.md` with `Status: BLOCKED ⛔`
2. Describe the blocker in detail (error message, file, line)
3. List attempted solutions
4. Exit cleanly — do **not** hang

A Ralph that stops silently is indistinguishable from one still working.

---

## Iteration Time Limits

```markdown
## Operational Parameters
- Max iteration time: 10 minutes
- Total session timeout: 60 minutes
- If iteration exceeds limit: log BLOCKED, exit
```

---

## Anti-Patterns (Hall of Failures)

| Anti-Pattern | Consequence | Prevention |
|---|---|---|
| No PROGRESS.md update | Parent cannot determine status | Mandatory write every iteration |
| Silent failure | Work lost, time wasted | Explicit BLOCKED status |
| Multiple parallel writes to same file | Race conditions | Single-file rule |
| Path assumptions | Wrong directory | Explicit `cwd` verification at start |
| No completion signal | Parent waits forever | Write `Status: COMPLETE` |
| Complex initial prompt | Agent stalls (empty output) | Simplify: one file, one change |
| Skipping gates | Silent regressions | All gates mandatory before `[x]` |
| Marking `[x]` before gates pass | False progress | Gate first, mark second |

---

## Reference Docs — Read by Subagents Every Iteration

Two files live in the project root and are read by `ralph-implementer` at the
start of every iteration, before touching any code.

### `backpressure.md` — Gate Reference (Python)

Documents the full gate stack in order:

| Gate | Command | Pass condition |
|---|---|---|
| Tests | `pytest` | exit 0, 0 failures |
| Typecheck | `mypy src/` | exit 0, no issues |
| Lint | `ruff check src/` | exit 0, no violations |
| Format | `ruff format --check src/` | exit 0, no diffs |
| Security | `bandit -r src/ -ll` | exit 0, no medium/high |
| Import | `python -c "import src"` | exit 0 |

Also documents the shorthand `bash scripts/check.sh` command that runs all
gates in sequence. `ralph-implementer` uses this as the default gate command
when a task doesn't specify a narrower one.

### `patterns.md` — Shared Code Patterns (Python)

Documents the canonical implementation patterns for the project. `ralph-implementer`
reads this before writing any code so it uses existing utilities rather than
reinventing them. Covers:

- Project layout convention (`src/lib/`, `src/services/`, `src/models/`, etc.)
- Configuration via Pydantic `BaseSettings`
- Database access via SQLAlchemy async (`src/lib/database.py`)
- Custom exception hierarchy (`src/lib/errors.py`)
- Structured logging via structlog (`src/lib/logging.py`)
- Pydantic request/response schemas
- Consistent API response envelope (`PageResponse`, `MessageResponse`)
- JWT auth helpers (`src/lib/security.py`)
- FastAPI service-layer pattern (thin routes → service functions)
- Test fixtures (`conftest.py`, unit vs integration test patterns)

Both files are **living documents** — `ralph-implementer` appends new patterns
and gate variants as they are discovered, so future iterations benefit from
accumulated project knowledge.



```bash
# 1. Install Ralph subagents
mkdir -p .codex/agents
cp ralph-mode-codex/.codex/agents/*.toml .codex/agents/

# 2. Write your specs
mkdir -p specs
echo "# Auth Spec\n\nJWT-based user authentication..." > specs/authentication.md

# 3. Run planning phase
codex "Use ralph-planner to analyse specs/ and generate IMPLEMENTATION_PLAN.md"

# 4. Start the build loop
./loop.sh 10   # 10 iteration limit; 0 = unlimited
```

Or drive manually iteration by iteration:
```bash
codex "Use ralph-implementer to pick the next task from IMPLEMENTATION_PLAN.md,
implement it, validate, and update PROGRESS.md."
```

---

## Memory Updates

After each Ralph Mode session:

```markdown
## [Date] Ralph Mode Session

**Project:** [name]
**Iterations:** [N]
**Outcome:** success / partial / blocked
**Learnings:**
- What worked well
- Patterns to add to specs/
- Subagents that helped most
```
