# Implementation Plan Template

This is the canonical output format. Follow it exactly.
Annotations in `[brackets]` explain what to put — remove them from output.

---

```markdown
# Implementation Plan: <Feature Name>

**Ticket / Spec**: [Link or ref — e.g., PROJ-123, PRD v2.1]  
**Author**: Codex (via $implement-feature skill)  
**Date**: [today]  
**Status**: Draft — pending engineer review  

---

## Summary

[2–3 sentences in plain English. What are we building, how does it fit into
the existing system, and what's the key technical approach? Avoid jargon.
A non-technical PM should understand this paragraph.]

---

## Complexity & Estimate

**Size**: [XS / S / M / L / XL]  
**Total estimate**: [X–Y days]  
**Confidence**: [High / Medium / Low] — [one sentence explaining confidence level]

---

## Requirements Recap

[Brief recap of MUST requirements — 3–6 bullets max.
This confirms you understood the spec before planning.]

- Users must be able to...
- The system must...
- Performance target: < X ms for Y operation

**Out of scope** (explicitly):
- [What is NOT being built in this plan]

---

## Architecture Decision

**Chosen approach**: [Name the approach — e.g., "Background job with webhook callback"]

[1–2 paragraphs explaining HOW it works and WHY this approach was chosen.
Reference the codebase — e.g., "This follows the same pattern as ExportService (src/services/ExportService.ts)."]

**Alternative considered**: [Alternative approach]  
**Why rejected**: [Concrete reason — not "it was harder" but "it would require X which means Y"]

---

## Affected Files

| File | Status | Change Description |
|------|--------|--------------------|
| `src/api/routes/[feature].ts` | 🆕 New | Route handler for POST /[endpoint] |
| `src/services/[Feature]Service.ts` | 🆕 New | Core business logic |
| `src/repositories/[Feature]Repo.ts` | 🆕 New | DB queries |
| `src/models/[Model].ts` | ✏️ Modified | Add [fields] |
| `prisma/schema.prisma` | ✏️ Modified | Add [Model] table |
| `migrations/[timestamp]_[name].sql` | 🆕 New | DB migration |
| `tests/unit/[Feature]Service.test.ts` | 🆕 New | Unit tests |
| `tests/integration/[feature].test.ts` | 🆕 New | Integration tests |

[Status legend: 🆕 New | ✏️ Modified | 🗑️ Deleted | 👀 Read-only reference]

---

## Implementation Phases

[Break into phases of 1–3 days each. Each phase = one PR or one reviewable unit.]

### Phase 1 — [Name, e.g., Data Model] (Est: X–Y days)

**Goal**: [What this phase delivers and why it comes first]

1. **`prisma/schema.prisma`** — Add `[ModelName]` model:
   ```prisma
   model FeatureName {
     id        String   @id @default(cuid())
     userId    String
     status    Status   @default(PENDING)
     createdAt DateTime @default(now())
     user      User     @relation(fields: [userId], references: [id])
   }
   
   enum Status {
     PENDING
     PROCESSING
     DONE
     FAILED
   }
   ```

2. **`migrations/[timestamp]_add_feature.sql`** — Run: `pnpm db:migrate`
   - Zero-downtime: new table, no modifications to existing tables
   - Rollback: `DROP TABLE feature_name;`

3. **`src/models/FeatureName.ts`** — Type definitions and validation schema

✅ **Phase 1 checkpoint**: `pnpm db:migrate && pnpm test -- --testPathPattern=migration`

---

### Phase 2 — [Name, e.g., Service Layer] (Est: X–Y days)

**Goal**: [What this phase delivers]

1. **`src/services/FeatureService.ts`** (new):
   ```typescript
   // Key methods to implement:
   async createFeature(userId: string, input: CreateFeatureInput): Promise<Feature>
   async getFeatureStatus(featureId: string, userId: string): Promise<FeatureStatus>
   async processFeature(featureId: string): Promise<void>  // called by job
   ```
   
   Key logic:
   - [Describe the core algorithm or business rules]
   - [Describe error conditions and how they're handled]
   - [Describe any state machine or workflow]

2. **`tests/unit/FeatureService.test.ts`** — Test cases:
   - ✅ Happy path: creates feature with valid input
   - ❌ User not found: throws NotFoundError
   - ❌ Invalid input: throws ValidationError
   - ❌ Duplicate request: returns existing or throws ConflictError
   - ⏱️ Concurrent requests: only one succeeds

✅ **Phase 2 checkpoint**: `pnpm test -- --testPathPattern=FeatureService`

---

### Phase 3 — [Name, e.g., API Endpoint] (Est: X–Y days)

**Goal**: [What this phase delivers]

1. **`src/api/routes/feature.ts`** (new):
   ```typescript
   // POST /api/v1/features
   // Auth: required (JWT)
   // Body: CreateFeatureInput
   // Response 201: { id, status, createdAt }
   // Response 400: { error, details } — validation failed
   // Response 409: { error } — duplicate
   // Response 500: { error } — unexpected
   ```

2. **`src/api/routes/index.ts`** — Register new route:
   ```typescript
   router.use('/features', featureRouter);
   ```

3. **`tests/integration/feature.test.ts`** — Integration tests:
   - POST with valid body → 201 + feature created in DB
   - POST without auth → 401
   - POST with invalid body → 400 + error details
   - POST duplicate → 409

✅ **Phase 3 checkpoint**: `pnpm test -- --testPathPattern=feature.test`

---

### Phase 4 — [Name, e.g., Background Processing] (Est: X–Y days)
[Continue pattern...]

---

## Key Implementation Details

### [Detail 1: e.g., Authentication & Authorization]
[Explain exactly how auth works for this feature — which middleware, which roles,
how user ownership is enforced. Reference the exact middleware file.]

### [Detail 2: e.g., Data Validation]
[What validation library, where validation happens, what the schema looks like.
Show the Zod/Pydantic/other schema if helpful.]

### [Detail 3: e.g., Error Handling]
[How errors are structured, what error codes are used, how they map to HTTP status codes.
Reference the existing error class.]

### [Detail 4: e.g., Database Query Patterns]
[Key queries, whether indexes are needed, pagination approach if applicable.]

---

## Testing Strategy

| Layer | Tool | Coverage Target | File |
|---|---|---|---|
| Unit | Jest | All service methods + edge cases | `tests/unit/FeatureService.test.ts` |
| Integration | Jest + real DB | All API endpoints | `tests/integration/feature.test.ts` |
| E2E | Playwright | Happy path user flow | `tests/e2e/feature.spec.ts` |

**Test data strategy**: [Describe how test data is set up — factories, fixtures, seeds]

**Mocking strategy**: [What gets mocked — external services only, never internals]

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Risk 1] | High / Med / Low | High / Med / Low | [Concrete mitigation] |
| [Risk 2] | | | |
| [Risk 3] | | | |

**Dependencies / blockers**:
- [ ] [Blocked by: external team / other ticket / infra change]
- [ ] [Requires: env var / secret / API key to be provisioned]

---

## Security Checklist

- [ ] All endpoints require authentication
- [ ] User can only access their own data (ownership check in service layer)
- [ ] All user input is validated before use
- [ ] No raw SQL with string concatenation
- [ ] No PII logged
- [ ] Secrets via environment variables only
- [ ] Rate limiting applied to [endpoint] (if public-facing)

---

## Performance Considerations

[If applicable: expected data volume, query performance, caching strategy,
async vs sync tradeoffs. If no concerns, write "No performance concerns
identified for this feature at the expected volume of X."]

---

## Definition of Done

- [ ] All acceptance criteria met (AC1, AC2, AC3...)
- [ ] Unit tests: all passing, coverage > 80% for new code
- [ ] Integration tests: all passing
- [ ] No new security issues (`$check-security`)
- [ ] No regressions in existing test suite
- [ ] API documented (update OpenAPI/Swagger if applicable)
- [ ] CHANGELOG.md updated (`$changelog`)
- [ ] PR description written (`$draft-pr`)
- [ ] Code reviewed by at least 1 engineer

---

## Ready to Start?

**Recommended starting point**: Phase 1 — [Name]

Say "start Phase 1" or "begin implementation" to begin coding, or
ask questions about any part of the plan first.
```
