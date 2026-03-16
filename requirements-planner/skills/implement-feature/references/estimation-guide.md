# Effort Estimation Guide

Use this to size features and individual implementation phases.
Never give a single number — always give a range and explain what's in it.

---

## Size Definitions

| Size | Total Effort | Signal |
|---|---|---|
| **XS** | < 1 day | Single file change, no DB, no new API |
| **S** | 1–2 days | 2–5 files, minor API change, no migration |
| **M** | 3–5 days | New endpoint + service + DB migration + tests |
| **L** | 1–2 weeks | New subsystem, complex business logic, multiple integrations |
| **XL** | 2–4 weeks | Cross-cutting concern, architectural change, or multi-team coord |

---

## Estimation Rules

### Always add these to your estimate:

| Task | Add |
|---|---|
| Writing tests (unit + integration) | +30% of dev time |
| First time working in this area | +25% |
| DB migration (non-trivial) | +0.5 days |
| External service integration (first time) | +1 day |
| Auth/security changes | +0.5 days review |
| Backward compatibility required | +1 day |
| Unknown third-party API | +1 day (exploration) |

### Complexity multipliers:

| Factor | Multiplier |
|---|---|
| Highly concurrent or real-time | ×1.5 |
| Requires performance benchmarks | ×1.3 |
| Multiple consumers of new API | ×1.2 |
| Cross-service dependencies | ×1.4 |
| Existing code has no tests | ×1.3 (harder to change safely) |

---

## Phase Sizing Guide

Break large features into phases of 1–3 days each (maximum).
Each phase must be independently testable and reviewable.

Good phase boundaries:
- Data model / migration (can be deployed separately)
- API endpoint (with mock service)
- Service logic (with stubbed data layer)
- Integration with external service
- Frontend integration (if applicable)
- Performance optimization pass

Bad phase boundaries:
- "Backend" (too large)
- "Make it work" (undefined)
- "Everything else" (placeholder)

---

## Estimate Presentation Format

Always present estimates with uncertainty:

```
Phase 1 — Data model (Est: 0.5–1 day)
  - Create migration
  - Add model validation
  - Write migration tests

Phase 2 — API endpoint (Est: 1–2 days)
  - Route handler + validation
  - Service integration
  - Error handling
  - Unit + integration tests

Phase 3 — Business logic (Est: 1–2 days)
  - Core algorithm
  - Edge case handling
  - Unit tests for all paths

Total: 2.5–5 days
Risk factors: [list any that apply]
```

---

## Calibration Signals

Use these to validate your estimate:

**Too small if:**
- No tests in estimate
- "Simple" feature touches auth, payments, or data privacy
- Estimate assumes no bugs or surprises
- Migration touches existing data

**Too large if:**
- Substantial utility code already exists to reuse
- Feature is similar to something already in the codebase
- Well-understood domain with clear acceptance criteria

**Unknowns to call out explicitly:**
- "Requires spike: [X] is unfamiliar territory — add 0.5–1 day to explore"
- "Blocked by: [dependency] not yet complete"
- "Assumption: [Y] — if wrong, add Z days"
