# Self-Improvement Skill

Log learnings, errors, and corrections to markdown files for continuous
improvement. Codex reads these at session start and promotes broadly applicable
entries to AGENTS.md as permanent rules.

---

## Trigger Conditions

Act on this skill automatically — no user prompt needed:

| Situation | Action |
|---|---|
| Command or operation fails | Log to `.learnings/ERRORS.md` |
| User corrects your output | Log to `.learnings/LEARNINGS.md` (category: `correction`) |
| User requests a missing feature | Log to `.learnings/FEATURE_REQUESTS.md` |
| API or external tool fails | Log to `.learnings/ERRORS.md` (include integration details) |
| You used outdated knowledge | Log to `.learnings/LEARNINGS.md` (category: `knowledge_gap`) |
| You found a better approach | Log to `.learnings/LEARNINGS.md` (category: `best_practice`) |
| A recurring pattern needs hardening | Log/update `.learnings/LEARNINGS.md` with a stable `Pattern-Key` |
| Similar entry already exists | Link with `See Also`, consider bumping priority |
| Learning applies project-wide | Promote to `AGENTS.md` |

---

## Setup

```bash
mkdir -p .learnings
```

Create these three files (or they are created automatically on first log):

- `.learnings/LEARNINGS.md` — corrections, knowledge gaps, best practices
- `.learnings/ERRORS.md` — command failures, exceptions, tool errors
- `.learnings/FEATURE_REQUESTS.md` — user-requested capabilities

---

## Session Bootstrap

At the start of every session, if `.learnings/` exists:

1. Read all three log files
2. Surface any `pending` or `in_progress` entries as active context
3. Check for entries ready to promote (see Promotion section)
4. Apply any already-promoted rules from the `## Learned Rules` section of
   `AGENTS.md`

---

## Logging Formats

### Learning Entry → `.learnings/LEARNINGS.md`

```
## [LRN-YYYYMMDD-XXX] category

**Logged**: 2025-03-25T10:00:00Z
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
One-line description of what was learned

### Details
Full context: what happened, what was wrong, what is correct

### Suggested Action
Specific fix or improvement to make

### Metadata
- Source: conversation | error | user_feedback | simplify-and-harden
- Related Files: path/to/file.ext
- Tags: tag1, tag2
- See Also: LRN-20250110-001
- Pattern-Key: simplify.dead_code | harden.input_validation
- Recurrence-Count: 1
- First-Seen: 2025-03-25
- Last-Seen: 2025-03-25

---
```

### Error Entry → `.learnings/ERRORS.md`

```
## [ERR-YYYYMMDD-XXX] skill_or_command_name

**Logged**: 2025-03-25T10:00:00Z
**Priority**: high
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
Brief description of what failed

### Error
```
Actual error message or output
```

### Context
- Command/operation attempted
- Input or parameters used
- Environment details if relevant

### Suggested Fix
If identifiable, what might resolve this

### Metadata
- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20250110-001

---
```

### Feature Request Entry → `.learnings/FEATURE_REQUESTS.md`

```
## [FEAT-YYYYMMDD-XXX] capability_name

**Logged**: 2025-03-25T10:00:00Z
**Priority**: medium
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Requested Capability
What the user wanted to do

### User Context
Why they needed it, what problem it solves

### Complexity Estimate
simple | medium | complex

### Suggested Implementation
How this could be built

### Metadata
- Frequency: first_time | recurring
- Related Features: existing_feature_name

---
```

---

## ID Generation

Format: `TYPE-YYYYMMDD-XXX`

| Part | Values |
|---|---|
| TYPE | `LRN`, `ERR`, `FEAT` |
| YYYYMMDD | Current date |
| XXX | Sequential `001`, `002` or random `A3F` |

Examples: `LRN-20250325-001`, `ERR-20250325-A3F`, `FEAT-20250325-002`

---

## Resolving Entries

When an issue is fixed, update in place:

1. Change `**Status**: pending` → `**Status**: resolved`
2. Append a resolution block after Metadata:

```
### Resolution
- **Resolved**: 2025-03-26T09:00:00Z
- **Commit/PR**: abc123 or #42
- **Notes**: What was done
```

Other status values:

| Status | Meaning |
|---|---|
| `pending` | Logged, not yet addressed |
| `in_progress` | Actively being worked on |
| `resolved` | Fixed |
| `wont_fix` | Decided not to address (add reason) |
| `promoted` | Elevated to AGENTS.md |

---

## Promotion to AGENTS.md

When a learning is broadly applicable, promote it to permanent project memory
so every future Codex session inherits it automatically.

### When to Promote

- Learning applies across multiple files or features
- Prevents a recurring mistake
- Documents a project-specific convention
- Workflow improvement that should always run

### How to Promote

1. Distill the learning into a concise rule (one or two lines)
2. Append to the `## Learned Rules` section in `AGENTS.md` (create section if
   it doesn't exist)
3. Update the original entry:
   - `**Status**: promoted`
   - Add `**Promoted**: AGENTS.md`

### Promotion Format in AGENTS.md

```markdown
## Learned Rules
<!-- Promoted automatically from .learnings/ — do not edit manually -->

### [LRN-20250325-001] correction — 2025-03-25
> Use `pnpm install`, not `npm install`. Lock file is pnpm-lock.yaml.

### [LRN-20250325-002] best_practice — 2025-03-25
> After any API change, regenerate the TypeScript client:
> `pnpm run generate:api && pnpm tsc --noEmit`
```

### Promotion Decision Table

| Learning type | Promote to |
|---|---|
| Project conventions, gotchas | `AGENTS.md` → `## Learned Rules` |
| Workflow steps that always run | `AGENTS.md` → relevant section |
| Tool-specific gotchas | `AGENTS.md` → `## Tool Notes` |
| Recurring architectural issues | `AGENTS.md` + create a tech debt task |

---

## Recurring Pattern Detection

Before logging a new entry:

```bash
# Search for similar existing entries
grep -ri "keyword" .learnings/
```

If a match exists:
1. Add `See Also: ERR-YYYYMMDD-XXX` in the new entry's Metadata
2. Increment `Recurrence-Count` on the existing entry
3. Bump priority if it keeps recurring
4. Consider systemic fix — recurring issues signal missing automation or docs

---

## Codex-Native Wiring

### Option 1 — `notify` (runs after every turn)

```toml
# ~/.codex/config.toml
notify = "bash .codex/hooks/reflect.sh"
```

```bash
# .codex/hooks/reflect.sh
#!/usr/bin/env bash
PAYLOAD=$(cat)
EVENT=$(echo "$PAYLOAD" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('event',''))")

if [[ "$EVENT" == "agent-turn-complete" ]]; then
  # Check git diff for any new errors surfaced this turn
  DIFF=$(git diff --stat 2>/dev/null)
  if [[ -n "$DIFF" ]]; then
    echo "[reflect] Turn complete. Files changed: $DIFF"
  fi
fi
```

### Option 2 — Instruction-only (no external scripts)

Add to `AGENTS.md` so Codex enforces logging automatically:

```markdown
## Automatic Behaviors

After EVERY task:
- If any tool call failed, append an ERR entry to `.learnings/ERRORS.md`
- If the user corrected your output, append an LRN entry to
  `.learnings/LEARNINGS.md`
- If `.learnings/` does not exist, create it silently before logging

At the start of EVERY session:
- Read `.learnings/LEARNINGS.md` and surface any `high` or `critical`
  priority pending entries
- Apply all rules in the `## Learned Rules` section of this file
```

### Option 3 — RALPH Integration (if using the RALPH multi-agent system)

Add REFLECT as Phase 6 in `agents/ralph-orchestrator.md`:

```markdown
## Phase 6 — REFLECT

After every completed task:

1. Read `.learnings/` for any pending entries added during this session
2. Check if any sub-task required a retry (indicates a planning gap)
3. Check reviewer report for BLOCKERs (indicates implementer patterns to fix)
4. Log findings to `.learnings/LEARNINGS.md` or `.learnings/ERRORS.md`
5. If 3+ entries share a pattern, promote to `## Learned Rules` in AGENTS.md

Completion report format:
## Reflect Report
- New entries logged: N
- Promoted to AGENTS.md: [rule text or "none"]
- Recurring patterns detected: [or "none"]
```

---

## stream_max_retries Note

If logging stream disconnect errors frequently, fix at the source instead of
logging them as ERR entries:

```toml
# ~/.codex/config.toml
[model_providers.openai]
stream_max_retries = 10
stream_idle_timeout_ms = 300000
```
