#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check-required-files.sh
#
# Baseline doctor check (required for everyone):
# - Fails fast (errors)
# - Quiet + machine-readable when DOCTOR_JSON=1
# - Human-friendly otherwise
#
# Checks:
#   - .env exists in project root
#
# Notes:
# - This script intentionally excludes act-only requirements (.vars, ~/.actrc, .secrets).
#   Those are checked by: scripts/check/check-required-files-act.sh
# -----------------------------------------------------------------------------

PROJECT_ENV=".env"
DOCS_ENV="docs/environment/ENV_SPEC.md"

JSON_MODE="${DOCTOR_JSON:-0}"

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib"
# shellcheck source=scripts/lib/doctor-check-utils.sh
source "${_LIB}/doctor-check-utils.sh"

# -----------------------
# .env (project root)
# -----------------------
if [[ ! -f "$PROJECT_ENV" ]]; then
  fail "Missing $PROJECT_ENV (project root). See: $DOCS_ENV"
elif [[ "$JSON_MODE" != "1" ]]; then
  printf "%b\n" "${GREEN}✅ Found $PROJECT_ENV${RESET}"
fi

# -----------------------
# Output / exit
# -----------------------
if [[ "$JSON_MODE" == "1" ]]; then
  emit_json "required-files-baseline"
  [[ "$status" == "fail" ]] && exit 1 || exit 0
fi

if [[ "$status" == "fail" ]]; then
  echo ""
  printf "%b\n" "${RED}❌ Required environment checks failed:${RESET}"
  for err in "${errors[@]}"; do
    echo "   - $err"
  done
  echo ""
  printf "%b\n" "${GRAY}Fix:${RESET}"
  echo "  👉 Run: make env-init"
  echo "  📖 Docs: $DOCS_ENV"
  exit 1
fi

printf "%b\n" "${GREEN}🎉 Required environment checks passed.${RESET}"
