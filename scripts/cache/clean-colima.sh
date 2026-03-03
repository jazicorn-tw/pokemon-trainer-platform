#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/cache/clean-colima.sh
#
# Responsibility: Colima hygiene helpers (safe-by-default).
#
# Commands:
#   info   - show colima status (best-effort)
#   reset  - reset colima VM (gated + interactive confirm) [alias: clean]
#
# Knobs (env vars):
#   CLEAN_COLIMA_RESET=false|true
#     - false (default): never reset
#     - true          : reset colima VM (DESTRUCTIVE)
#
#   CLEAN_COLIMA_DISK_GB=80
#   CLEAN_COLIMA_PROFILE=default
#
# Confirmation controls:
#   CLEAN_COLIMA_ASSUME_YES=false|true
#     - false (default): prompt interactively before reset
#     - true           : skip prompt (useful for scripted runs)
#
# WARNING:
# - Resetting Colima deletes ALL images/containers/volumes inside the Colima VM.
# -----------------------------------------------------------------------------

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib"
# shellcheck source=scripts/lib/shell-utils.sh
source "${_LIB}/shell-utils.sh"
# shellcheck source=scripts/lib/validators.sh
source "${_LIB}/validators.sh"

cmd="${1:-info}"

reset="${CLEAN_COLIMA_RESET:-false}"
disk_gb="${CLEAN_COLIMA_DISK_GB:-80}"
profile="${CLEAN_COLIMA_PROFILE:-default}"
assume_yes="${CLEAN_COLIMA_ASSUME_YES:-false}"

validate() {
  is_bool "${reset}" || die "Invalid CLEAN_COLIMA_RESET=${reset} (use true|false)"
  is_bool "${assume_yes}" || die "Invalid CLEAN_COLIMA_ASSUME_YES=${assume_yes} (use true|false)"
  is_int "${disk_gb}" || die "Invalid CLEAN_COLIMA_DISK_GB=${disk_gb} (use integer GB)"
}

require_colima() {
  command -v colima >/dev/null 2>&1 || die "colima not installed"
}

print_info() {
  if ! command -v colima >/dev/null 2>&1; then
    echo "ℹ️ colima not installed"
    exit 0
  fi

  echo "🧊 colima profile: ${profile}"
  colima status --profile "${profile}" 2>/dev/null || true
}

banner() {
  cat <<EOF
☢️  COLIMA RESET (NUCLEAR)

You are about to DELETE the Colima VM for profile: ${profile}

This will remove ALL of the following INSIDE Colima:
  - Docker images (pulled + built)
  - Containers (running + stopped)
  - Volumes (data)
  - Build cache
  - containerd snapshots (overlayfs)

A fresh VM will be created with disk: ${disk_gb}GB

EOF
}

confirm() {
  # If assume_yes is true, do not prompt.
  if [[ "${assume_yes}" == "true" ]]; then
    return 0
  fi

  # If stdin is not a TTY, refuse unless assume_yes=true.
  if [[ ! -t 0 ]]; then
    echo "❌ Refusing to reset Colima without a TTY."
    echo "   Re-run with CLEAN_COLIMA_ASSUME_YES=true if you really intend this."
    return 2
  fi

  echo -n "Are you sure you want to delete the Colima VM? Type 'delete' to confirm: "
  read -r answer
  if [[ "${answer}" != "delete" ]]; then
    echo "ℹ️ Aborted (no changes made)."
    return 1
  fi
  return 0
}

reset_colima() {
  require_colima
  validate

  if [[ "${reset}" != "true" ]]; then
    echo "ℹ️ CLEAN_COLIMA_RESET=false (skipping colima reset)"
    return 0
  fi

  banner
  confirm || return $?

  echo "♻️ Resetting colima profile '${profile}' with disk ${disk_gb}GB"
  colima stop --profile "${profile}" || true
  colima delete --profile "${profile}" || true
  colima start --profile "${profile}" --disk "${disk_gb}"
}

usage() {
  cat <<'EOF'
Usage:
  scripts/cache/clean-colima.sh [command]

Commands:
  info    Show colima status (best-effort)
  reset   Reset colima VM (gated + prompt) [alias: clean]
  clean   Alias of reset

Environment variables:
  CLEAN_COLIMA_RESET=false|true
  CLEAN_COLIMA_DISK_GB=80
  CLEAN_COLIMA_PROFILE=default
  CLEAN_COLIMA_ASSUME_YES=false|true
EOF
}

main() {
  case "${cmd}" in
    info) print_info ;;
    reset|clean) reset_colima ;;
    -h|--help|help) usage ;;
    *) die "Unknown command: ${cmd} (use info|reset|clean)" ;;
  esac
}

main "$@"
