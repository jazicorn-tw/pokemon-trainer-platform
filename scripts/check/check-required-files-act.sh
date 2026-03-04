#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check-required-files-act.sh
#
# Act-only doctor check (required only for local `act` runs):
# - Fails fast (errors)
# - Quiet + machine-readable when DOCTOR_JSON=1
# - Human-friendly otherwise
#
# Checks:
#   - .vars exists in project root (mirrors GitHub repo variables for act)
#   - .secrets exists in project root (GitHub App auth for act/release simulation)
#   - ~/.actrc exists
#   - ~/.actrc permissions are safe (600 recommended)
#
# Config:
#   - STRICT_ACTRC_PERMS=1  -> treat unsafe ~/.actrc permissions as an error
#                              (default: warn only)
#
#   - REQUIRE_ACT_VARS=1    -> require .vars (treat missing as an error)
#                              (default: 1)
# -----------------------------------------------------------------------------

PROJECT_VARS=".vars"
PROJECT_SECRETS=".secrets"
ACTRC="$HOME/.actrc"

DOCS_VARS="docs/devops/RELEASE_GATING.md"
DOCS_SECRETS="SECRETS.md"
DOCS_ACT="docs/ci/act/ACT_OVERVIEW.md"

JSON_MODE="${DOCTOR_JSON:-0}"
STRICT_ACTRC_PERMS="${STRICT_ACTRC_PERMS:-0}"
REQUIRE_ACT_VARS="${REQUIRE_ACT_VARS:-1}"

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib"
# shellcheck source=scripts/lib/doctor-check-utils.sh
source "${_LIB}/doctor-check-utils.sh"

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
# .vars (project root) — act-only
# -----------------------
if [[ ! -f "$PROJECT_VARS" ]]; then
  if [[ "$REQUIRE_ACT_VARS" == "1" ]]; then
    fail "Missing $PROJECT_VARS (project root). Create it with: cp .vars.example .vars — See: $DOCS_VARS"
  else
    warn "Missing $PROJECT_VARS (recommended for local act). Create it with: cp .vars.example .vars — See: $DOCS_VARS"
  fi
elif [[ "$JSON_MODE" != "1" ]]; then
  printf "%b\n" "${GREEN}✅ Found $PROJECT_VARS${RESET}"
fi

# -----------------------
# .secrets (project root) — act-only
# -----------------------
if [[ ! -f "$PROJECT_SECRETS" ]]; then
  fail "Missing $PROJECT_SECRETS (project root). Create it with: cp .secrets.example .secrets — See: $DOCS_SECRETS"
elif [[ "$JSON_MODE" != "1" ]]; then
  printf "%b\n" "${GREEN}✅ Found $PROJECT_SECRETS${RESET}"
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
  emit_json "required-files-act"
  [[ "$status" == "fail" ]] && exit 1 || exit 0
fi

if [[ "$status" == "fail" ]]; then
  echo ""
  printf "%b\n" "${RED}❌ Act environment checks failed:${RESET}"
  for err in "${errors[@]}"; do
    echo "   - $err"
  done
  echo ""
  printf "%b\n" "${GRAY}Fix:${RESET}"
  echo "  👉 Run: make env-init-act"
  echo "  📖 Docs: $DOCS_ACT"
  exit 1
fi

if [[ "${#warnings[@]}" -gt 0 ]]; then
  echo ""
  printf "%b\n" "${ORANGE}⚠️  Warnings (non-fatal):${RESET}"
  for w in "${warnings[@]}"; do
    echo "   - $w"
  done
  echo ""
  printf "%b\n" "${GREEN}✅ Act environment checks passed (with warnings).${RESET}"
  exit 0
fi

printf "%b\n" "${GREEN}🎉 Act environment checks passed.${RESET}"
