#!/usr/bin/env bash
set -euo pipefail

# scripts/inspect/make/make-router.sh
#
# One entrypoint for inspect tooling (Make delegates here).
#
# Flag:
#   FLAG=a  Inspect ALL modules (or all in a decade when combined with a number)
#
# Modes:
#   make inspect-mk
#   make inspect-mk 50
#   make inspect-mk FLAG=a
#   make inspect-mk 50 FLAG=a
#   make inspect-mk FILE=make/70-runtime.mk
#   make inspect-mk FILE=make/70-runtime.mk FLAG=a
#
# Ordering contract: ls -1 make | sort

BOLD="${BOLD:-$'\033[1m'}"
RESET="${RESET:-$'\033[0m'}"
CYAN="${CYAN:-$'\033[36m'}"
DIM="${DIM:-$'\033[2m'}"

PATH_INSPECT_LIST_MODULES="${PATH_INSPECT_LIST_MODULES:-./scripts/inspect/make/make-list.sh}"
PATH_INSPECT_ALL="${PATH_INSPECT_ALL:-./scripts/inspect/make/make-all.sh}"
PATH_INSPECT_DECADE_ALL="${PATH_INSPECT_DECADE_ALL:-./scripts/inspect/make/make-decade-all.sh}"

usage() {
  cat <<'EOF'
Usage:
  make inspect-mk
  make inspect-mk 50
  make inspect-mk FLAG=a
  make inspect-mk 50 FLAG=a
  make inspect-mk FILE=make/50-foo.mk
  make inspect-mk FILE=make/50-foo.mk FLAG=a
EOF
}

inspect_file() {
  local target_file="${1:-}"

  if [[ -z "${target_file}" ]]; then
    echo "Usage: inspect-router.sh <makefile path>" >&2
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
}

router() {
  local file_env="${FILE:-}"
  local extra_env="${EXTRA:-}"

  # Build the effective argv:
  # - If Make provided EXTRA, parse it as words
  # - Otherwise, use actual CLI args
  if [[ -n "${extra_env}" ]]; then
    # shellcheck disable=SC2086
    set -- ${extra_env}
  fi

  local decade=""
  local all_flag="false"

  # Support Make-style flag: FLAG=a
  if [[ "${FLAG:-}" == "a" ]]; then
    all_flag="true"
  fi

  # Parse decade from argv (we no longer support -a here)
  for a in "$@"; do
    case "$a" in
      [0-9][0-9]) decade="$a" ;;
    esac
  done

  # No args + no FILE => list modules
  if [[ -z "${file_env}" && -z "${decade}" && "${all_flag}" == "false" ]]; then
    bash "${PATH_INSPECT_LIST_MODULES}"
    exit 0
  fi

  # All modules
  if [[ -z "${file_env}" && "${all_flag}" == "true" && -z "${decade}" ]]; then
    bash "${PATH_INSPECT_ALL}"
    exit 0
  fi

  # Decade + all
  if [[ -z "${file_env}" && "${all_flag}" == "true" && -n "${decade}" ]]; then
    bash "${PATH_INSPECT_DECADE_ALL}" "${decade}"
    exit 0
  fi

  # Single-file inspection
  local target_file=""
  if [[ -n "${file_env}" ]]; then
    target_file="${file_env}"
  elif [[ -n "${decade}" ]]; then
    target_file="$(ls -1 make | sort | awk -v d="${decade}" '$0 ~ ("^" d "-.*\\.mk$") { print "make/" $0; exit }')"
  fi

  if [[ -z "${target_file}" || ! -f "${target_file}" ]]; then
    echo "❌ No mk file found"
    usage
    exit 1
  fi

  inspect_file "${target_file}"
}

router "$@"
