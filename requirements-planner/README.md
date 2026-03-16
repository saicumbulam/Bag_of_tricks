# $implement-feature — Requirements → Implementation Plan

Turn any requirements doc, ticket, or feature request into a detailed,
codebase-aware implementation plan a senior engineer can execute from.

---

## What's included

```
requirements-planner/
├── skills/
│   └── implement-feature/          ← install to ~/.codex/skills/
│       ├── SKILL.md                ← orchestrator (what Codex reads first)
│       ├── references/
│       │   ├── requirements-formats.md   ← PRD, Jira, stories, RFC parsing
│       │   ├── codebase-analysis.md      ← how to scan affected code
│       │   ├── plan-template.md          ← canonical plan output format
│       │   └── estimation-guide.md       ← XS→XL sizing rules
│       └── scripts/
│           └── scan-codebase.sh          ← auto-scans project structure
├── agents/
│   ├── requirements-analyst.toml   ← reads/clarifies requirements
│   ├── codebase-mapper.toml        ← maps affected files
│   ├── risk-assessor.toml          ← finds blockers and risks
│   └── patterns-finder.toml        ← finds reusable conventions
└── config-snippet.toml             ← add to ~/.codex/config.toml
```

---

## Install

```bash
# 1. Install the skill
mkdir -p ~/.codex/skills
cp -r skills/implement-feature ~/.codex/skills/

# 2. Install agent configs
mkdir -p ~/.codex/agents
cp agents/*.toml ~/.codex/agents/

# 3. Merge config snippet into your config.toml
cat config-snippet.toml >> ~/.codex/config.toml

# 4. Enable skills (if not already on)
codex --enable skills
codex --enable multi_agent

# 5. Verify
codex  # then type /skills — you should see "implement-feature" listed
```

---

## How to use

### Trigger phrases (implicit — just say it naturally)
```
"Plan this feature for me"
"How should I implement user export?"
"Break down this Jira ticket: PROJ-234"
"Read the PRD in docs/requirements.md and create an implementation plan"
"What's the approach for adding OAuth login?"
"I need to implement real-time notifications — plan it out"
```

### Explicit invocation
```
$implement-feature
```

### With a pasted ticket
```
$implement-feature

[paste your Jira/Linear ticket content here]
```

### Pointing at a requirements file
```
Plan the feature described in docs/PRD-user-export.md
```

---

## What the skill produces

**Phase 1 — Requirements Intake**
- Locates and reads requirements from file or conversation
- Parses into structured MUST/SHOULD/COULD/WON'T format
- Extracts acceptance criteria
- Flags open questions (asks you before proceeding)

**Phase 2 — Codebase Analysis** (3 parallel agents)
- `codebase-mapper` → exact files to create/modify
- `risk-assessor` → blockers, breaking changes, data risks
- `patterns-finder` → conventions and utilities to reuse

**Output: Full Implementation Plan**
- Architecture decision with tradeoffs
- Affected files table (new / modified / deleted)
- Phased implementation with 1–3 day checkpoints
- Key technical details (schema, API contract, business logic)
- Testing strategy by layer
- Risk register with mitigations
- Security checklist
- Effort estimate with ranges
- Definition of done

---

## Example workflow

```
You:   "Plan this feature: users should be able to export their data as CSV"

Codex: [activates $implement-feature]
       
       REQUIREMENTS SUMMARY
       ════════════════════
       Feature: User Data Export
       Goal: Users can download their own data as a CSV file

       MUST: Authenticated user triggers export
       MUST: Export format is CSV
       OPEN Q1: Which data entities? (all or specific?)
       OPEN Q2: Async (email delivery) or sync (download)?

       I have 2 open questions before planning. Can you clarify?

You:   "All entities. Async — send download link by email within 5 minutes."

Codex: [spawns 3 agents in parallel]
       → codebase-mapper is mapping affected files...
       → risk-assessor is analyzing risks...
       → patterns-finder is finding conventions...
       
       [synthesizes results into full plan]
       
       # Implementation Plan: User Data Export
       Complexity: M | Estimate: 4–6 days
       ...
       [full plan per plan-template.md]
       
       Ready to start Phase 1?

You:   "Start Phase 1"

Codex: [begins implementation]
```

---

## Agent roles (when multi-agent is enabled)

| Agent | Model | Mode | Job |
|---|---|---|---|
| `requirements-analyst` | gpt-5-codex / high | read-only | Parses any requirements format |
| `codebase-mapper` | codex-mini / medium | read-only | Maps affected files |
| `risk-assessor` | gpt-5-codex / high | read-only | Finds blockers and risks |
| `patterns-finder` | codex-mini / low | read-only | Finds reusable conventions |

All planning agents are read-only. No files are modified during planning.

---

## Tips for best results

1. **Point at your requirements file explicitly** — "read docs/PRD.md and plan it"
   gets better results than describing requirements verbally.

2. **Answer clarifying questions** — the skill asks before planning because a
   plan built on misread requirements wastes days.

3. **Use `--profile debug`** for complex or large features — higher reasoning
   effort produces more thorough risk analysis.

4. **Combine with `$code-review`** — after implementation, run code review
   against the plan's acceptance criteria.

5. **Save the plan** — ask Codex to "save this plan to docs/plans/feature-name.md"
   so it's preserved and reviewable by teammates.
