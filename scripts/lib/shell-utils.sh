#!/usr/bin/env bash
# scripts/lib/shell-utils.sh — shared output helpers. Source; do not execute.

log()  { printf '%s\n' "$*"; }
warn() { printf '⚠️  %s\n' "$*"; }

# die [exit_code] message  (exit_code defaults to 1)
die() {
  local _code=1
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then _code="$1"; shift; fi
  printf '❌ %s\n' "$*" >&2
  exit "${_code}"
}

have() { command -v "$1" >/dev/null 2>&1; }

# find_compose_file — prints path to first compose file found, returns 1 if none.
find_compose_file() {
  local f
  for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
    [[ -f "$f" ]] && { printf '%s' "$f"; return 0; }
  done
  return 1
}
