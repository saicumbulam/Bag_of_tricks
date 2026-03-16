# Requirements Format Parsing Guide

Read this file when Phase 1 requires parsing a specific requirements format.
Identify the format first, then follow the relevant section.

---

## Format Detection

| Signal | Format |
|---|---|
| Has `## Acceptance Criteria` or `AC:` | User Story / Agile |
| Has `## Background`, `## Goals`, `## Non-Goals` | PRD (Product Requirements Doc) |
| Has `## Motivation`, `## Detailed Design` | RFC / Design Doc |
| Has `Story Points`, `Epic`, `Sprint` | Jira/Linear Ticket |
| Has `## Context`, `## Decision`, `## Consequences` | ADR (Architecture Decision Record) |
| Plain paragraph or conversation | Informal spec — extract intent |

---

## PRD (Product Requirements Doc)

Typical structure:
```
# Feature Name
## Background / Problem
## Goals
## Non-Goals
## User Stories
## Requirements
## Design / Mockups
## Metrics / Success Criteria
## Timeline
```

When parsing a PRD:
1. Extract **Goals** → these become MUST requirements
2. Extract **Non-Goals** → mark as WON'T in your summary
3. Scan **User Stories** → each becomes an acceptance criterion
4. Check **Metrics** → these become non-functional requirements
5. Note **Timeline** → affects complexity and phasing

---

## Jira / Linear Ticket

Typical fields:
```
Title:       [SHORT-123] Add user profile editing
Description: As a user, I want to...
Acceptance Criteria:
  - [ ] User can update name, email, avatar
  - [ ] Changes persist after page refresh
  - [ ] Email change triggers re-verification
Labels:      backend, api, auth
Story Points: 8
Epic:         User Settings
```

When parsing a ticket:
1. Each checkbox in Acceptance Criteria → one AC in your summary
2. Story Points are a rough size signal (1-3=XS/S, 5-8=M, 13+=L/XL)
3. Labels tell you which layers are involved
4. Epic gives you the broader context — find related tickets if useful

---

## User Stories (Agile)

Format: `As a <role>, I want <feature> so that <benefit>`

Parse each story:
- **Role** → who benefits, helps with auth/permission scoping
- **Feature** → the functional requirement
- **Benefit** → the "why", helps prioritize edge cases

Extract implicit requirements:
- "I want to see my order history" → implies pagination, filtering, sorting
- "I want to reset my password" → implies email flow, rate limiting, token expiry

---

## RFC / Design Doc

Typical structure:
```
## Summary
## Motivation
## Detailed Design
## Drawbacks
## Alternatives
## Unresolved Questions
```

When parsing an RFC:
1. **Summary** → the goal
2. **Motivation** → the "why" (captures non-functional intent)
3. **Detailed Design** → often contains pseudo-code or schema — use these
4. **Drawbacks** → note as risks in your plan
5. **Alternatives** → reference in your Architecture Decision section
6. **Unresolved Questions** → carry forward as Open Questions

---

## ADR (Architecture Decision Record)

Format captures a past decision — useful as context for what NOT to change:
1. Read **Decision** → existing architectural constraint
2. Read **Consequences** → understand what the current system relies on
3. Your plan must respect or explicitly supersede these constraints

---

## Informal / Conversational Spec

When requirements are a paragraph or conversation:
1. Identify the **core behavior** (what must the system do differently?)
2. Identify the **user/actor** (who triggers this?)
3. Infer **acceptance criteria** from the description
4. List all **assumptions** you made — confirm before proceeding
5. Flag any **ambiguities** explicitly

Example extraction:
> "We need users to be able to export their data as CSV"

Extracted:
```
Functional:
  MUST: User can trigger a data export
  MUST: Export format is CSV
  SHOULD: User receives export via email or download
  OPEN: Which data? All data or specific entities?
  OPEN: Async (background job) or sync (immediate download)?
  OPEN: Any data privacy/GDPR considerations for the export?
```
