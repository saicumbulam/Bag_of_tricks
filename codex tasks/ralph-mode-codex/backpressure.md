# Backpressure Gates Reference — Python Edition

Backpressure gates are the mechanism that rejects incomplete or invalid work
automatically, forcing `ralph-implementer` to iterate until quality standards
are met. Gates must all return exit code 0 before a task is marked `[x]`.

---

## Gate Stack (run in this order)

### 1 — Tests (`pytest`)

```bash
pytest                          # all tests
pytest tests/unit/              # unit only
pytest tests/integration/       # integration only
pytest --cov=src --cov-report=term-missing   # with coverage
```

**Pass condition:** exit code 0, zero failures, zero errors.
**Coverage threshold:** 80%+ on new files (configure in `pyproject.toml`).

Failure mode: read the traceback, fix the root cause in the assigned file,
re-run. Do not mock away failures to make the test pass.

---

### 2 — Type checking (`mypy`)

```bash
mypy src/
mypy src/specific_module.py     # single file check
```

**Pass condition:** exit code 0, `Success: no issues found`.

Common fixes:

| Error | Fix |
|---|---|
| `Missing return statement` | Add explicit `return` or `-> None` annotation |
| `Incompatible types` | Use correct type or `Union[X, Y]` |
| `Module has no attribute` | Import from correct path; check `__init__.py` |
| `Missing type annotation` | Add parameter/return annotations |
| `Need type annotation for X` | Annotate with e.g. `x: list[str] = []` |

Config lives in `pyproject.toml` under `[tool.mypy]`. Never add `# type: ignore`
to make a check pass — fix the underlying type issue.

---

### 3 — Linting (`ruff`)

```bash
ruff check src/
ruff check src/specific_module.py
ruff check --fix src/           # auto-fix safe issues
```

**Pass condition:** exit code 0, no violations reported.

Key rule categories enforced:
- `E` / `W` — pycodestyle errors and warnings
- `F` — pyflakes (unused imports, undefined names)
- `I` — isort (import ordering)
- `B` — flake8-bugbear (likely bugs)
- `UP` — pyupgrade (modern Python idioms)
- `N` — pep8-naming

Config lives in `pyproject.toml` under `[tool.ruff]`. Never add `# noqa`
to silence a rule — fix the code.

---

### 4 — Formatting (`ruff format` or `black`)

```bash
ruff format --check src/        # check only (no changes)
ruff format src/                # apply formatting
# OR
black --check src/
black src/
```

**Pass condition:** exit code 0 (no formatting diffs).

Run `ruff format src/` (or `black src/`) before committing. Formatting is
not subjective — the formatter decides.

---

### 5 — Security scan (`bandit`) — optional but recommended

```bash
bandit -r src/ -ll              # only medium/high severity
```

**Pass condition:** exit code 0 (no medium/high issues).

Do not suppress bandit findings with `# nosec` unless there is a documented
reason in the same comment.

---

### 6 — Build / import check

For packages:
```bash
python -m build --wheel         # if using pyproject.toml build
```

For FastAPI / Flask apps (smoke test that the app imports cleanly):
```bash
python -c "from src.main import app; print('import OK')"
```

For scripts / pipelines:
```bash
python -c "import src.pipeline; print('import OK')"
```

**Pass condition:** exit code 0, no `ImportError` or `ModuleNotFoundError`.

---

## Gate Order Rationale

1. **Tests first** — fastest feedback on broken logic
2. **Mypy second** — catches type errors tests might miss
3. **Ruff third** — style issues, unused imports
4. **Format fourth** — cosmetic; never blocks logic
5. **Bandit fifth** — security; run before merge
6. **Build/import last** — integration check

---

## Wiring Gates into `pyproject.toml`

Recommended configuration:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--cov=src --cov-fail-under=80"

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = false
disallow_untyped_defs = true
warn_return_any = true
warn_unused_ignores = true

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "UP", "N"]
ignore = []

[tool.ruff.format]
quote-style = "double"

[tool.bandit]
skips = []
```

---

## Shorthand Gate Script

Add to `Makefile` or `scripts/check.sh` so subagents have a single command:

```bash
#!/usr/bin/env bash
# scripts/check.sh — run all backpressure gates
set -euo pipefail

echo "▸ pytest..."
pytest

echo "▸ mypy..."
mypy src/

echo "▸ ruff lint..."
ruff check src/

echo "▸ ruff format check..."
ruff format --check src/

echo "▸ import smoke test..."
python -c "import src; print('import OK')"

echo "✅ All gates passed"
```

`ralph-implementer` should call `bash scripts/check.sh` as its gate command
whenever the task doesn't specify a narrower gate.

---

## Gate Failure Flow (Example)

```
ralph-implementer implements: Add UserCreate Pydantic model to src/models/user.py

Runs: pytest
Result: FAIL — 2 tests failing (unexpected field "created_at")

Fix: Add created_at field to UserCreate
Runs: pytest → PASS

Runs: mypy src/
Result: FAIL — Missing return type annotation on validate_email()

Fix: Add -> str return annotation
Runs: mypy src/ → PASS

Runs: ruff check src/
Result: FAIL — F401 unused import (datetime)

Fix: Remove unused import
Runs: ruff check src/ → PASS

Runs: ruff format --check src/ → PASS
Runs: python -c "import src; print('import OK')" → PASS

All gates pass → mark task [x] → commit → update PROGRESS.md
```

---

## When Gates Don't Exist Yet

If a file has no tests:

1. Write the test file first (it will fail — that's expected)
2. Implement the feature to make it pass
3. Add mypy, ruff, bandit progressively

Document new gates in `scripts/check.sh` immediately so future iterations
discover them automatically.

---

## Anti-Patterns

❌ `# type: ignore` to silence mypy
❌ `# noqa` to silence ruff
❌ `# nosec` to silence bandit (without documented reason)
❌ Marking `[x]` before running all gates
❌ Stubbing functions to make tests pass temporarily
❌ `pytest -k "not broken_test"` to exclude failing tests
✅ Fix the root cause. Gates are not enemies — they are convergence engines.
