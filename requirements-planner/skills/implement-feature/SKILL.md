---
name: implement-feature
description: >
  Read project requirements and produce a detailed, codebase-aware implementation
  plan for a senior engineer. Use this skill whenever requirements, specs, tickets,
  PRDs, user stories, or feature requests need to be turned into an actionable
  engineering plan. Triggers on phrases like "plan this feature", "implement this
  requirement", "how do I build this", "create an implementation plan",
  "break down this ticket", "read this PRD and plan it", "what's the approach for",
  "how should I implement", or when any requirements document or spec is mentioned.
  Always use this skill before writing any code for a non-trivial feature.
---

# Implement Feature Skill

You are an expert staff engineer helping a senior engineer turn requirements into
a precise, codebase-aware implementation plan. This skill runs in two phases:
**understand** then **plan**. Never skip Phase 1 — a plan built on misread
requirements wastes days.

---

## Phase 1 — Requirements Intake

### Step 1: Locate and read the requirements

Check these locations in order:
```bash
# Common requirement file locations
find . -maxdepth 3 -name "*.md" | xargs grep -l -i "requirement\|spec\|PRD\|user story\|acceptance criteria" 2>/dev/null | head -10
ls requirements/ docs/ specs/ .jira/ .linear/ 2>/dev/null
cat REQUIREMENTS.md 2>/dev/null || cat docs/requirements.md 2>/dev/null || cat PRD.md 2>/dev/null
```

If requirements are in the conversation (pasted text, ticket content, user story),
use those directly. Read them fully before proceeding.

### Step 2: Parse and structure requirements

Apply the parser for the detected format — see `references/requirements-formats.md`
for format-specific guidance (PRD, Jira/Linear ticket, user stories, RFC, ADR, etc.).

Extract and explicitly state:
```
REQUIREMENTS SUMMARY
════════════════════
Feature:       <name>
Goal:          <one sentence — the "why">

Functional Requirements:
  MUST:  <non-negotiable behaviors>
  SHOULD: <strong preferences>
  COULD:  <nice to have>
  WON'T:  <explicitly out of scope>

Non-Functional Requirements:
  Performance:    <latency, throughput targets>
  Security:       <auth, data sensitivity>
  Scalability:    <expected load>
  Compatibility:  <API contracts, backward compat>

Acceptance Criteria:
  AC1: Given <context> When <action> Then <outcome>
  AC2: ...

Open Questions:
  Q1: <ambiguity that needs clarification>
  Q2: ...
```

**If there are open questions**: Ask them now, before proceeding.
**If requirements are clear**: Move to Phase 2 immediately.

---

## Phase 2 — Codebase Analysis + Plan Generation

Spawn agents to parallelize analysis. See agent coordination below.

### Step 3: Spawn parallel analysis agents

If multi-agent is enabled:
```
Spawn 3 agents in parallel:
1. codebase-mapper — map all code areas relevant to this feature
2. risk-assessor   — identify blockers, dependencies, risks
3. patterns-finder — find existing patterns, utilities, conventions to reuse
Wait for all three, then synthesize.
```

If single-agent mode, do steps sequentially:
- Read `references/codebase-analysis.md` for how to analyze the codebase
- Run the codebase scanner: `bash skills/implement-feature/scripts/scan-codebase.sh`
- Identify affected files, entry points, and integration points manually

### Step 4: Generate the implementation plan

Read `references/plan-template.md` for the exact output format.
Read `references/estimation-guide.md` for effort sizing guidance.

Produce the plan with these sections:

---

### Implementation Plan: `<Feature Name>`

**Summary**: One paragraph — approach in plain English, no jargon.

**Complexity**: `XS | S | M | L | XL` — see estimation guide for sizing criteria.

---

#### Architecture Decision
State the chosen approach and **why** — include at least one alternative considered
and why it was rejected. A senior engineer needs to understand the tradeoffs.

---

#### Affected Areas
| Area | Files | Change Type |
|---|---|---|
| API layer | `src/api/routes/...` | New endpoint |
| Service | `src/services/...` | Modified |
| DB | `migrations/...` | New migration |

---

#### Implementation Phases

Structure work into phases that each produce a testable, reviewable unit:

**Phase 1 — `<name>` (Est: X days)**
1. `<file>` — `<what to create/modify and why>`
2. ...
- ✅ Checkpoint: `<how to verify this phase works>`

**Phase 2 — `<name>` (Est: X days)**
...

---

#### Key Implementation Details

For every non-trivial decision, explain the approach:
- Data model changes (schema, types, validations)
- API contract (request/response shape, error codes)
- Business logic rules (edge cases, state machines)
- Integration points (external services, events, queues)

---

#### Testing Strategy
| Test type | What to cover | File location |
|---|---|---|
| Unit | Business logic, edge cases | `tests/unit/...` |
| Integration | DB + service layer | `tests/integration/...` |
| E2E | Full user flow | `tests/e2e/...` |

---

#### Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Migration downtime | Medium | High | Zero-downtime migration strategy |
| Breaking API consumers | Low | High | Version the endpoint |

---

#### Definition of Done
- [ ] All acceptance criteria met
- [ ] Unit + integration tests written and passing
- [ ] No new security vulnerabilities (run `$check-security`)
- [ ] Documentation updated
- [ ] PR description written with `$draft-pr`
- [ ] Performance baseline maintained

---

#### Suggested Phase to Start
Recommend which phase to implement first and offer to begin.

---

## Agent Coordination

When multi-agent is available, use these roles:

**`codebase-mapper`** agent task:
> "Map all code relevant to [feature name]. Find: entry points (routes/handlers),
> service layer files, data models/schemas, existing utilities to reuse, test files.
> Return a structured file inventory with one-line descriptions."

**`risk-assessor`** agent task:
> "Analyze risks for implementing [feature name] in this codebase. Check:
> breaking changes to existing APIs, DB migration complexity, third-party
> dependencies needed, performance impact on existing flows, security surface.
> Rate each risk HIGH/MEDIUM/LOW with a mitigation."

**`patterns-finder`** agent task:
> "Find existing patterns in this codebase that [feature name] should follow.
> Look for: how similar endpoints are structured, error handling conventions,
> auth patterns, validation approach, test patterns. Return concrete examples
> with file:line references."

---

## Reference Files

- `references/requirements-formats.md` — How to parse PRDs, tickets, user stories, RFCs
- `references/codebase-analysis.md` — How to systematically analyze affected code areas  
- `references/plan-template.md` — Full plan output template with examples
- `references/estimation-guide.md` — Effort sizing rules (XS→XL, day ranges)
