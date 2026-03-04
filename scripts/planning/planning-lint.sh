#!/usr/bin/env bash
set -euo pipefail

# planning-lint.sh
#
# Lightweight lint for IDEAS.md / TODO.md / PROMOTION_CHECKLIST.md.
# Designed to be fast, dependency-free, and CI-friendly.
#
# Exit codes:
#  0 = OK
#  1 = Lint errors found

IDEAS_FILE="${IDEAS_FILE:-IDEAS.md}"
TODO_FILE="${TODO_FILE:-TODO.md}"
CHECKLIST_FILE="${CHECKLIST_FILE:-PROMOTION_CHECKLIST.md}"

fail=0

die() { echo "❌ $*" >&2; fail=1; }
warn() { echo "⚠️  $*" >&2; }
ok() { echo "✅ $*"; }

require_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    die "Missing required file: $f"
    return
  fi
  if [[ ! -s "$f" ]]; then
    die "File is empty: $f"
  fi
}

require_file "$IDEAS_FILE"
require_file "$TODO_FILE"
require_file "$CHECKLIST_FILE"

# --- IDEAS.md checks ---
# Ensure it contains key sections and lifecycle markers
grep -qE '^# .*IDEAS' "$IDEAS_FILE" || die "IDEAS.md should start with a top-level IDEAS heading"
grep -qE 'Idea Lifecycle|Lifecycle' "$IDEAS_FILE" || warn "IDEAS.md: missing 'Idea Lifecycle' section (recommended)"
grep -qE '🌱|Seed' "$IDEAS_FILE" || warn "IDEAS.md: missing Seed marker (🌱) (recommended)"
grep -qE '🔍|Exploring' "$IDEAS_FILE" || warn "IDEAS.md: missing Exploring marker (🔍) (recommended)"
grep -qE '👍|Approved' "$IDEAS_FILE" || warn "IDEAS.md: missing Approved marker (👍) (recommended)"
grep -qE '👎|Rejected' "$IDEAS_FILE" || warn "IDEAS.md: missing Rejected marker (👎) (recommended)"

# --- TODO.md checks ---
grep -qE '^# .*TODO' "$TODO_FILE" || die "TODO.md should start with a top-level TODO heading"
grep -qE 'Acceptance Criteria' "$TODO_FILE" || warn "TODO.md: tasks should include Acceptance Criteria (recommended)"
grep -qE 'Milestones|Phases' "$TODO_FILE" || warn "TODO.md: missing Milestones/Phases section (recommended)"

# Anti-pattern checks: TODOs that look like ideas
if grep -nE 'might be|could be|someday|maybe|nice to have|what if' "$TODO_FILE" >/dev/null 2>&1; then
  die "TODO.md contains speculative language (move those items back to IDEAS.md)"
fi

# --- Checklist checks ---
grep -qE '^# .*Promotion Checklist' "$CHECKLIST_FILE" || die "PROMOTION_CHECKLIST.md should have a clear top heading"
grep -qE '\[ \]' "$CHECKLIST_FILE" || warn "PROMOTION_CHECKLIST.md: expected to include checkbox items"

# --- Staleness heuristic (optional) ---
# Flags tasks/ideas that include a 'Decision needed by' or 'Decision Trigger' date in the past.
# This is heuristic-only and won't fail the lint.
today="$(date +%Y-%m-%d)"
if grep -nE 'Decision needed by:|Decision Trigger:.*\b20[0-9]{2}-[0-9]{2}-[0-9]{2}\b' "$IDEAS_FILE" >/dev/null 2>&1; then
  warn "IDEAS.md: contains decision dates; consider pruning if overdue (today: $today)"
fi

if [[ "$fail" -eq 0 ]]; then
  ok "Planning lint passed"
  exit 0
else
  echo "❌ Planning lint failed" >&2
  exit 1
fi
