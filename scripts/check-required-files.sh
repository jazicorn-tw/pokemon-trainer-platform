#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check-required-files.sh
#
# Convention-aligned doctor check:
# - Fails fast (errors)
# - Quiet + machine-readable when DOCTOR_JSON=1
# - Human-friendly otherwise
#
# Checks:
#   - .env exists in project root
#   - ~/.actrc exists
#   - ~/.actrc permissions are safe (600 recommended)
#
# Config:
#   - STRICT_ACTRC_PERMS=1  -> treat unsafe ~/.actrc permissions as an error
#                              (default: warn only)
# -----------------------------------------------------------------------------

PROJECT_ENV=".env"
ACTRC="$HOME/.actrc"

DOCS_ENV="docs/onboarding/ENVIRONMENT.md"
DOCS_ACT="docs/onboarding/ENVIRONMENT.md#-%EF%B8%8F-actrc-home-directory"

JSON_MODE="${DOCTOR_JSON:-0}"
STRICT_ACTRC_PERMS="${STRICT_ACTRC_PERMS:-0}"

# ANSI colors (safe even if Make disables color upstream)
ORANGE="\033[38;5;208m"
RED="\033[1;31m"
GREEN="\033[1;32m"
GRAY="\033[90m"
RESET="\033[0m"

status="pass"
errors=()
warnings=()

emit_json() {
  jq -n \
    --arg status "$status" \
    --argjson errors "$(printf '%s\n' "${errors[@]:-}" | jq -R . | jq -s .)" \
    --argjson warnings "$(printf '%s\n' "${warnings[@]:-}" | jq -R . | jq -s .)" '
    {
      check: "required-files",
      status: $status,
      errors: $errors,
      warnings: $warnings
    }
  '
}

fail() {
  status="fail"
  errors+=("$1")
}

warn() {
  warnings+=("$1")
}

print_actrc_perm_warning() {
  local perms="$1"

  echo ""
  printf "%b\n" "${ORANGE}⚠️  Security warning: ~/.actrc permissions are ${perms} (recommended 600)${RESET}"
  echo ""
  printf "%b\n" "${GRAY}Risk:${RESET}"
  echo "  - Other users on this machine may be able to read your act configuration."
  echo "  - ~/.actrc can include registry credentials, socket paths, or env overrides."
  echo ""
  printf "%b\n" "${GRAY}Fix (run from anywhere):${RESET}"
  printf "%b\n" "  👉 chmod 600 ~/.actrc"
  echo ""
  printf "%b\n" "${GRAY}Docs:${RESET}"
  echo "  - ${DOCS_ACT}"
  echo ""
}

print_actrc_perm_error() {
  local perms="$1"

  echo ""
  printf "%b\n" "${RED}❌ Security error (STRICT_ACTRC_PERMS=1)${RESET}"
  echo ""
  echo "~/.actrc permissions are ${perms} (required: 600)"
  echo ""
  printf "%b\n" "${GRAY}Why this failed:${RESET}"
  echo "  - STRICT_ACTRC_PERMS is enabled"
  echo "  - ~/.actrc may contain credentials or sensitive config"
  echo ""
  printf "%b\n" "${GRAY}Fix:${RESET}"
  printf "%b\n" "  👉 chmod 600 ~/.actrc"
  echo ""
  printf "%b\n" "${GRAY}Docs:${RESET}"
  echo "  - ${DOCS_ACT}"
  echo ""
}

# -----------------------
# .env (project root)
# -----------------------
if [[ ! -f "$PROJECT_ENV" ]]; then
  fail "Missing $PROJECT_ENV (project root). See: $DOCS_ENV"
elif [[ "$JSON_MODE" != "1" ]]; then
  printf "%b\n" "${GREEN}✅ Found $PROJECT_ENV${RESET}"
fi

# -----------------------
# ~/.actrc (home)
# -----------------------
if [[ ! -f "$ACTRC" ]]; then
  fail "Missing $ACTRC (home directory). See: $DOCS_ACT"
else
  perms="$(stat -c '%a' "$ACTRC" 2>/dev/null || stat -f '%Lp' "$ACTRC")"
  if [[ "$perms" != "600" ]]; then
    if [[ "$STRICT_ACTRC_PERMS" == "1" ]]; then
      fail "~/.actrc permissions are $perms (required 600 in STRICT mode)"
      [[ "$JSON_MODE" != "1" ]] && print_actrc_perm_error "$perms"
    else
      warn "~/.actrc permissions are $perms (recommended 600) — fix: chmod 600 ~/.actrc"
      [[ "$JSON_MODE" != "1" ]] && print_actrc_perm_warning "$perms"
    fi
  elif [[ "$JSON_MODE" != "1" ]]; then
    printf "%b\n" "${GREEN}✅ Found $ACTRC (permissions OK)${RESET}"
  fi
fi

# -----------------------
# Output / exit
# -----------------------
if [[ "$JSON_MODE" == "1" ]]; then
  emit_json
  [[ "$status" == "fail" ]] && exit 1 || exit 0
fi

if [[ "$status" == "fail" ]]; then
  echo ""
  printf "%b\n" "${RED}❌ Required environment checks failed:${RESET}"
  for err in "${errors[@]}"; do
    echo "   - $err"
  done
  exit 1
fi

if [[ "${#warnings[@]}" -gt 0 ]]; then
  echo ""
  printf "%b\n" "${ORANGE}⚠️  Warnings (non-fatal):${RESET}"
  for w in "${warnings[@]}"; do
    echo "   - $w"
  done
  echo ""
  printf "%b\n" "${GREEN}✅ Required environment checks passed (with warnings).${RESET}"
  exit 0
fi

printf "%b\n" "${GREEN}🎉 Required environment checks passed.${RESET}"
