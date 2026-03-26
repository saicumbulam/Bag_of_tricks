#!/usr/bin/env bash
# Ralph Mode Loop — Codex Edition
#
# Drives the Ralph Mode inner loop using the Codex CLI.
# Each iteration spawns a ralph-implementer delegation via `codex`.
#
# Usage:
#   ./loop.sh [max_iterations]
#
# Prerequisites:
#   - codex CLI installed and authenticated
#   - .codex/agents/ralph-*.toml installed (copy from ralph-mode-codex/)
#   - IMPLEMENTATION_PLAN.md exists (run ralph-planner phase first)
#
# Exit codes:
#   0 — all tasks complete or iteration limit reached
#   1 — missing prerequisite files

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
MAX_ITERATIONS=${1:-0}
PLAN_FILE="IMPLEMENTATION_PLAN.md"
PROGRESS_FILE="PROGRESS.md"
ITERATION=0
CODEX_BIN="${CODEX_BIN:-codex}"   # override if codex is not on PATH

# Timeout per iteration in seconds (codex --timeout flag)
ITERATION_TIMEOUT="${RALPH_TIMEOUT:-600}"

# ── Helpers ─────────────────────────────────────────────────────────────────
header() { echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "$1"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }
info()   { echo "  ▸ $1"; }
ok()     { echo "  ✅ $1"; }
warn()   { echo "  ⚠️  $1"; }
err()    { echo "  ❌ $1"; }

# ── Preflight checks ────────────────────────────────────────────────────────
header "Ralph Mode — Codex Edition"
info "Max iterations : ${MAX_ITERATIONS:-unlimited}"
info "Plan file      : $PLAN_FILE"
info "Progress file  : $PROGRESS_FILE"
info "Iteration limit: ${ITERATION_TIMEOUT}s"

if ! command -v "$CODEX_BIN" &>/dev/null; then
  err "codex CLI not found. Install: npm install -g @openai/codex"
  exit 1
fi

if [ ! -f "$PLAN_FILE" ]; then
  err "$PLAN_FILE not found."
  echo ""
  echo "Run the planning phase first:"
  echo "  codex \"Use ralph-planner to analyse specs/ and generate $PLAN_FILE\""
  exit 1
fi

# Check .codex/agents/ has ralph agents
if [ ! -f ".codex/agents/ralph-implementer.toml" ]; then
  warn ".codex/agents/ralph-implementer.toml not found."
  warn "Copy Ralph agents: cp ralph-mode-codex/.codex/agents/*.toml .codex/agents/"
  warn "Continuing anyway — using ralph-implementer by name in prompts."
fi

# Initialise PROGRESS.md if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  cat > "$PROGRESS_FILE" <<EOF
# Ralph: Session Started

## $(date -u +"%Y-%m-%dT%H:%M:%SZ")

### Status
In Progress 🔄

### Note
Session initialised. Awaiting first iteration.
EOF
  info "Created $PROGRESS_FILE"
fi

# ── Main loop ────────────────────────────────────────────────────────────────
while true; do
  # Iteration limit check
  if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    header "Iteration limit reached: $MAX_ITERATIONS"
    info "Re-run without limit or with a higher number to continue:"
    info "  ./loop.sh 0"
    break
  fi

  ITERATION=$((ITERATION + 1))
  header "ITERATION $ITERATION"

  # Check if all tasks are done
  if ! grep -q "^- \[ \]" "$PLAN_FILE" 2>/dev/null; then
    ok "All tasks in $PLAN_FILE are completed!"
    echo ""

    # Final validation run
    info "Running final gate check via ralph-validator..."
    "$CODEX_BIN" \
      --no-interactive \
      --timeout "$ITERATION_TIMEOUT" \
      "Use ralph-validator to run all backpressure gates and write the results to $PROGRESS_FILE."

    header "Ralph Mode Complete ✅"
    break
  fi

  # Show next pending task
  echo ""
  info "Next pending task:"
  grep "^- \[ \]" "$PLAN_FILE" | head -1
  echo ""

  # Build the delegation prompt (single-file rule enforced here)
  NEXT_TASK=$(grep "^- \[ \]" "$PLAN_FILE" | head -1 | sed 's/^- \[ \] //')
  DELEGATION_PROMPT="Use ralph-implementer.

Task: ${NEXT_TASK}

Instructions:
1. Read IMPLEMENTATION_PLAN.md and find this exact task.
2. Read only the spec file and target file referenced by the task.
3. Make the change described — one file only.
4. Run the gate command specified in the task (or all gates if unspecified).
5. If gates pass: mark task [x] in IMPLEMENTATION_PLAN.md, commit, write PROGRESS.md with Status: Complete, exit.
6. If gates fail after 3 fix attempts: write PROGRESS.md with Status: BLOCKED, describe the error, exit.

Do NOT start any other task. Do NOT expand scope."

  # Optional: pause for review before spawning
  read -rp "  Spawn iteration $ITERATION? [Y/n/q] " REPLY
  REPLY="${REPLY:-Y}"

  case "$REPLY" in
    [Qq]*)
      info "Quit. Resume with: ./loop.sh"
      exit 0
      ;;
    [Nn]*)
      info "Skipped iteration $ITERATION. Running next check..."
      continue
      ;;
  esac

  echo ""
  info "Delegating to ralph-implementer via codex..."
  echo ""

  # Run codex with the delegation prompt
  # --no-interactive: non-interactive mode for loop usage
  # --timeout: per-iteration time limit
  if "$CODEX_BIN" \
      --no-interactive \
      --timeout "$ITERATION_TIMEOUT" \
      "$DELEGATION_PROMPT"; then
    echo ""
    ok "Iteration $ITERATION completed."
  else
    CODEX_EXIT=$?
    warn "codex exited with code $CODEX_EXIT on iteration $ITERATION."
    warn "Check $PROGRESS_FILE for details."
  fi

  # Check PROGRESS.md for BLOCKED status
  if grep -q "Status.*BLOCKED" "$PROGRESS_FILE" 2>/dev/null; then
    echo ""
    warn "BLOCKED detected in $PROGRESS_FILE."
    warn "Review the blocker, then:"
    warn "  - Fix manually and re-run: ./loop.sh"
    warn "  - Delegate to debugger: codex \"Use debugger to investigate the blocker in $PROGRESS_FILE\""
    warn "  - Scope down: remove the blocking task and re-plan"
    read -rp "  Continue despite BLOCKED? [y/N] " CONTINUE
    CONTINUE="${CONTINUE:-N}"
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
      info "Paused. Resolve blocker and re-run: ./loop.sh"
      exit 0
    fi
  fi

  echo ""
  info "Plan status:"
  DONE=$(grep -c "^\- \[x\]" "$PLAN_FILE" 2>/dev/null || echo 0)
  PENDING=$(grep -c "^\- \[ \]" "$PLAN_FILE" 2>/dev/null || echo 0)
  info "  Completed : $DONE"
  info "  Remaining : $PENDING"

done

echo ""
header "Session Summary"
info "Iterations run : $ITERATION"
info "Plan file      : $PLAN_FILE"
info "Progress log   : $PROGRESS_FILE"
echo ""
info "Useful next commands:"
echo "  Validate final state : codex \"Use ralph-validator to run all gates\""
echo "  Subjective review    : codex \"Use ralph-reviewer. Criteria: [...]\""
echo "  New session          : ./loop.sh"
