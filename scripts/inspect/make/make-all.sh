#!/usr/bin/env bash
set -euo pipefail

# Inspect every mk file in make/ (sorted).
# Equivalent ordering contract: ls -1 make | sort

GRAY="${GRAY:-$'\033[90m'}"
RESET="${RESET:-$'\033[0m'}"

while IFS= read -r f; do
  echo "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  scripts/inspect/make/make-file.sh "make/${f}"
  echo
done < <(ls -1 make | sort)
