#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check-all.sh
#
# Discovers and runs every *.sh in scripts/check/ except itself, in sorted
# order. Reports per-script pass/fail and exits 1 if any script failed.
#
# Usage:
#   ./scripts/check/check-all.sh          # run all checks
#   STRICT=1 ./scripts/check/check-all.sh # pass flags through to each script
# -----------------------------------------------------------------------------

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib"
# shellcheck source=scripts/lib/shell-utils.sh
source "${_LIB}/shell-utils.sh"

_SELF="$(realpath "${BASH_SOURCE[0]}")"
_CHECK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

passed=0
failed=0
results=()

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "🔍 Running all checks in scripts/check/"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""

while IFS= read -r script; do
  [[ "$(realpath "$script")" == "$_SELF" ]] && continue
  name="$(basename "$script")"
  log "▶ ${name}"
  if bash "$script" "$@"; then
    results+=("  ✅  ${name}")
    ((passed++)) || true
  else
    results+=("  ❌  ${name}")
    ((failed++)) || true
  fi
  log ""
done < <(find "$_CHECK_DIR" -maxdepth 1 -type f -name "*.sh" | sort)

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "check-all: ${passed} passed, ${failed} failed"
log ""
for r in "${results[@]}"; do
  log "$r"
done
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $failed -eq 0 ]]
