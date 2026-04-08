---
name: pattern-conformance-review
description: Review or refactor code to ensure it conforms to the existing patterns, conventions, and structure of a codebase before it gets merged. Use this skill whenever the user wants to add a new file, add a new function, introduce a new feature, review a diff, or refactor existing code against the rest of the project. Trigger on phrases like "check if this follows our patterns", "review this code", "refactor to match the codebase", "does this fit our style", "I'm adding a new file", "make this consistent with the rest of the code", or any time the user pastes code and asks whether it belongs. Also trigger proactively when the user is about to introduce code into an unfamiliar or large codebase, even if they don't explicitly ask for a review. The deliverable is a structured conformance report plus, when requested, a refactored version of the code.
---

# Pattern Conformance Review

A skill for checking whether new or existing code conforms to the conventions of the surrounding codebase, and refactoring it when it doesn't. The goal is to keep new contributions consistent with what's already there — file layout, naming, structure, size, imports, error handling, testing — so the codebase doesn't drift over time.

This skill is deliberately codebase-driven: it does **not** apply a fixed style guide. It infers the style from the existing code and measures the new code against that.

---

## When to use this skill

Use this skill when any of the following is true:

- The user is adding a new file, module, class, or function to an existing codebase.
- The user has pasted a diff, PR, or snippet and wants it reviewed for consistency.
- The user asks whether their code "fits", "matches", "follows the pattern", or "should be refactored".
- The user is working in an unfamiliar part of a large codebase and wants a sanity check before committing.
- The user explicitly asks for a refactor against the codebase style.

Do **not** use this skill for:

- Pure correctness review (use normal code review instead).
- Greenfield projects with no existing code to compare against.
- Style questions answered by a published style guide the user has already adopted (defer to the guide).

---

## The core procedure

Follow these steps in order. Do not skip the discovery step — it is the whole point of the skill.

### Step 1: Establish the target location

Find out where in the codebase the new code is going to live. Ask the user if it's not obvious. You need at minimum:

- The directory the new file would go in (or the file being modified).
- The language and framework.
- The rough purpose of the code (service? model? helper? test? config?).

### Step 2: Discover the existing patterns

Before looking at the new code in detail, scan the surrounding code to learn the conventions. Use the available tools (`view`, `bash_tool` with `ls`, `grep`, `find`, `wc`) to gather evidence. Do not guess.

For each of the dimensions below, find 3–5 representative existing files of the same kind (same directory, same role) and record what you observe. If there are not enough comparable files, say so explicitly in the report rather than inventing a pattern.

**Dimensions to check:**

1. **File layout & location**
   - Where do files of this kind live? (`services/`, `models/`, `lib/`, `internal/`, etc.)
   - Is one-file-per-class the norm, or are related things grouped?
   - Are tests colocated or in a separate `tests/` tree?

2. **Naming conventions**
   - File names: `snake_case.py`? `kebab-case.ts`? `PascalCase.java`?
   - Class, function, variable, constant naming.
   - Test file naming (`test_foo.py`, `foo_test.go`, `foo.spec.ts`).

3. **File size and shape**
   - Median and max line count of comparable files. Use `wc -l` on the peer files.
   - Are files typically one class / many functions / one entrypoint?
   - Is there a typical "shape" — imports, constants, helpers, main class, exports?

4. **Number and granularity of files**
   - How many files does a comparable feature usually span?
   - Does the codebase prefer one cohesive module or many small ones?
   - Flag if the new code introduces noticeably more or fewer files than peers.

5. **Imports and dependencies**
   - Import ordering (stdlib → third-party → local).
   - Absolute vs relative imports.
   - Are there forbidden cross-layer imports? (e.g., models importing from services.)
   - Are new third-party dependencies introduced? Is that normal here?

6. **Language-level style**
   - For Python: type hints? dataclasses vs plain classes? f-strings? docstring style (Google / NumPy / reST)?
   - For Go: error wrapping idioms, receiver naming, package layout.
   - For TypeScript: `interface` vs `type`, default exports vs named.
   - Match what the peer files actually do, not what is theoretically "best".

7. **Error handling**
   - Custom exception types vs built-ins.
   - Logging conventions (logger name, level, format).
   - How are errors propagated across layers?

8. **Testing**
   - Test framework and test layout.
   - Are new public functions expected to come with tests in this codebase?
   - Fixture and mocking style.

9. **Documentation & comments**
   - Module-level docstrings? Function docstrings? Inline comments?
   - Is there a README per package?

10. **Configuration & constants**
    - Where do constants live? (`constants.py`, top of file, env vars, config module.)
    - Are magic numbers tolerated or always extracted?

### Step 3: Measure the new code against the discovered patterns

Now look at the new code with the patterns from Step 2 in hand. For each dimension, classify the new code as one of:

- **Conforms** — matches the existing pattern.
- **Deviates (minor)** — small inconsistency, easy fix, low impact.
- **Deviates (major)** — meaningful break from convention; will hurt readability or maintainability.
- **N/A** — dimension doesn't apply to this change.
- **Unknown** — not enough peer evidence to judge; say so honestly.

Pay particular attention to two things the user cares about:

- **File count**: Is the change introducing more new files than a comparable feature usually does? If yes, flag it and suggest consolidation. Conversely, if it's cramming unrelated logic into one file to avoid new files, flag that too.
- **File size**: Does any new or modified file blow past the median size of peer files? If yes, suggest a split — but only if the split has a real reason (separate responsibilities), not just to hit a number.

### Step 4: Produce the conformance report

Output a structured report with these sections. Keep it concise — bullet points, not essays.

```
## Pattern Conformance Report

**Target:** <path or description of what's being added/changed>
**Peers examined:** <list the files you compared against>

### Summary
<1–3 sentence verdict: conforms / minor deviations / major deviations>

### Metrics
- New files introduced: N (peer feature average: ~M)
- Largest new file: X lines (peer median: Y, peer max: Z)
- New third-party dependencies: <list or "none">

### Findings
For each dimension where there's something to say:
- **<Dimension>**: <Conforms | Deviates (minor) | Deviates (major) | Unknown>
  - Evidence: <what peer files do>
  - New code: <what the new code does>
  - Recommendation: <what to change, or "no change needed">

### Suggested refactors (priority order)
1. <highest-impact change>
2. ...
```

### Step 5: Refactor (only if requested)

If the user asked for a refactor, not just a review, apply the recommended changes and produce the updated code. When refactoring:

- Make the minimum changes needed to bring the code into conformance. Do not rewrite for taste.
- Preserve behavior. If a refactor would change behavior, stop and ask.
- Group changes logically so the user can see what was done for each finding.
- After refactoring, re-run Step 3 against the refactored code and report the new conformance status.

---

## Important principles

**Codebase patterns beat universal best practices.** If the codebase consistently uses a pattern that isn't textbook-ideal, match it anyway. Raise the concern as a side note if it matters, but do not silently "improve" the new code away from the house style. Consistency has more value than local optimization.

**Don't invent patterns from thin evidence.** If you can only find one peer file, say "insufficient evidence" rather than declaring a convention. One example is not a pattern.

**Be honest about deviations the user might want to keep.** Sometimes a deviation is intentional and correct — the new code is the first of a new pattern, or the old pattern is genuinely bad. Flag the deviation, explain the tradeoff, and let the user decide. Do not refactor away a deliberate choice.

**Fewer files is a soft preference, not a rule.** The real goal is "no unnecessary fragmentation, no god-modules". Use the peer file count as the reference point, not an absolute number.

**Match the granularity of the user's request.** If they pasted ten lines and asked "does this fit", give a short report. If they're introducing a whole new subsystem, give a thorough one.

---

## Example invocation

> User: "I'm adding a new endpoint handler to our FastAPI app at `app/api/orders.py`. Here's the code — does it follow the patterns in the rest of the API?"

Procedure:
1. List `app/api/` to find peer handler files.
2. Read 3–5 of them, plus one or two of their tests.
3. Run `wc -l app/api/*.py` to get the size distribution.
4. Compare the new code along the dimensions above.
5. Produce the conformance report. Offer to refactor if there are deviations.
