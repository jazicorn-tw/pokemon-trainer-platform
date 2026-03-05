#!/usr/bin/env bash
set -euo pipefail

# scripts/inspect/make/make-file.sh
#
# Inspects a single make/ module and prints its documented targets (## comments).
# Called by make-all.sh and make-decade-all.sh.
#
# Usage: make-file.sh <path-to-mk-file>
# Read-only. No side effects.

BOLD="${BOLD:-$'\033[1m'}"
CYAN="${CYAN:-$'\033[36m'}"
DIM="${DIM:-$'\033[2m'}"
RESET="${RESET:-$'\033[0m'}"

target_file="${1:-}"

if [[ -z "${target_file}" ]]; then
  echo "Usage: make-file.sh <makefile path>" >&2
  exit 2
fi

if [[ ! -f "${target_file}" ]]; then
  echo "❌ File not found: ${target_file}" >&2
  exit 1
fi

printf "%s🔍 Inspecting%s %s%s%s\n\n" "${BOLD}" "${RESET}" "${CYAN}" "${target_file}" "${RESET}"

if grep -qE '^[a-zA-Z0-9_-]+:.*## ' "${target_file}"; then
  grep -E '^[a-zA-Z0-9_-]+:.*## ' "${target_file}" \
    | awk -F':|##' '{printf "  %-25s %s\n", $1, $NF}'
else
  printf "  %s(no documented targets found)%s\n" "${DIM}" "${RESET}"
fi
