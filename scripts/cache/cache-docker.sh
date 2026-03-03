#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/cache/cache-docker.sh
#
# Responsibility: Docker disk hygiene (prune caches) with safe-by-default gating.
#
# Commands:
#   info   - print docker context + disk usage
#   prune  - perform prunes (gated) + before/after summary
#   clean  - alias of prune
#
# Knobs (env vars):
#   CLEAN_DOCKER_MODE=false|true|auto
#     - false (default): never prune
#     - true          : always prune (system + builder); volumes only if enabled
#     - auto          : prune when Colima containerd filesystem is under pressure
#
#   CLEAN_DOCKER_VOLUMES=false|true
#     - false (default): never prune volumes
#     - true          : also run docker volume prune -f
#     Note: volumes are NEVER pruned automatically unless you explicitly set this true.
#
#   CLEAN_DOCKER_VERBOSE=false|true
#     - when true, use `docker system df -v` for before/after summaries
#
# Auto-mode tuning (only used when CLEAN_DOCKER_MODE=auto):
#   CLEAN_DOCKER_AUTO_MIN_FREE_GB=10
#   CLEAN_DOCKER_AUTO_MIN_FREE_INODES=5000
#   CLEAN_DOCKER_COLIMA_PROFILE=default
#
# Why auto checks Colima:
# - The common act failure is: /var/lib/containerd/... overlayfs snapshots "no space left"
# - For Colima-based Docker, containerd lives inside the Colima VM.
# - So auto mode checks free space + inodes on the filesystem backing /var/lib/containerd.
# -----------------------------------------------------------------------------

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib"
# shellcheck source=scripts/lib/shell-utils.sh
source "${_LIB}/shell-utils.sh"
# shellcheck source=scripts/lib/validators.sh
source "${_LIB}/validators.sh"
# shellcheck source=scripts/lib/colima-utils.sh
source "${_LIB}/colima-utils.sh"

cmd="${1:-prune}"

mode="${CLEAN_DOCKER_MODE:-false}"
volumes="${CLEAN_DOCKER_VOLUMES:-false}"
verbose="${CLEAN_DOCKER_VERBOSE:-false}"

auto_min_free_gb="${CLEAN_DOCKER_AUTO_MIN_FREE_GB:-10}"
auto_min_free_inodes="${CLEAN_DOCKER_AUTO_MIN_FREE_INODES:-5000}"
colima_profile="${CLEAN_DOCKER_COLIMA_PROFILE:-default}"

validate() {
  case "${mode}" in true|false|auto) ;; *) die "Invalid CLEAN_DOCKER_MODE=${mode} (use true|false|auto)" ;; esac
  is_bool "${volumes}" || die "Invalid CLEAN_DOCKER_VOLUMES=${volumes} (use true|false)"
  is_bool "${verbose}" || die "Invalid CLEAN_DOCKER_VERBOSE=${verbose} (use true|false)"
  is_int "${auto_min_free_gb}" || die "Invalid CLEAN_DOCKER_AUTO_MIN_FREE_GB=${auto_min_free_gb} (use integer GB)"
  is_int "${auto_min_free_inodes}" || die "Invalid CLEAN_DOCKER_AUTO_MIN_FREE_INODES=${auto_min_free_inodes} (use integer)"
}

docker_df() {
  if [[ "${verbose}" == "true" ]]; then
    docker system df -v 2>/dev/null || true
  else
    docker system df 2>/dev/null || true
  fi
}

print_info() {
  echo "🐳 docker context: $(docker context show 2>/dev/null || echo 'n/a')"
  echo ""
  echo "📊 Docker disk usage:"
  docker_df
}

should_prune_auto() {
  if ! colima_running "${colima_profile}"; then
    echo "ℹ️ Auto mode: colima profile '${colima_profile}' not running or colima not installed; skipping docker prune"
    return 1
  fi

  local free_gb free_inodes
  free_gb="$(colima_containerd_free_gb "${colima_profile}")"
  free_inodes="$(colima_containerd_free_inodes "${colima_profile}")"

  if [[ -z "${free_gb}" ]]; then
    echo "ℹ️ Auto mode: couldn't detect Colima free disk for /var/lib/containerd; skipping docker prune"
    return 1
  fi

  echo "🖥️  Colima free disk (containerd fs): ${free_gb}GB (threshold: < ${auto_min_free_gb}GB)"
  if [[ -n "${free_inodes}" ]]; then
    echo "🧩 Colima free inodes (containerd fs): ${free_inodes} (threshold: < ${auto_min_free_inodes})"
    if is_int "${free_inodes}" && [[ "${free_inodes}" -lt "${auto_min_free_inodes}" ]]; then
      echo "🧹 Auto mode triggered (low inodes)"
      return 0
    fi
  fi

  if [[ "${free_gb}" -lt "${auto_min_free_gb}" ]]; then
    echo "🧹 Auto mode triggered (low disk)"
    return 0
  fi

  echo "ℹ️ Auto mode: disk OK; not pruning docker"
  return 1
}

run_prune() {
  # Gate: only run when enabled
  if [[ "${mode}" != "true" && "${mode}" != "auto" ]]; then
    echo ""
    echo "ℹ️ CLEAN_DOCKER_MODE=false (skipping docker prune)"
    return 0
  fi

  if [[ "${mode}" == "auto" ]]; then
    should_prune_auto || return 0
  fi

  echo "📊 Docker disk usage (before):"
  docker_df
  echo ""

  echo "🧹 docker system prune -af"
  docker system prune -af

  echo "🧹 docker builder prune -af"
  docker builder prune -af

  if [[ "${volumes}" == "true" ]]; then
    echo "🧹 docker volume prune -f"
    docker volume prune -f
  else
    echo "ℹ️ CLEAN_DOCKER_VOLUMES=false (skipping volume prune)"
  fi

  echo ""
  echo "📊 Docker disk usage (after):"
  docker_df
}

usage() {
  cat <<'EOF'
Usage:
  scripts/cache/cache-docker.sh [command]

Commands:
  info    Show docker context + disk usage
  prune   Prune docker caches (gated) + before/after summary
  clean   Alias of prune

Environment variables:
  CLEAN_DOCKER_MODE=false|true|auto
  CLEAN_DOCKER_VOLUMES=false|true
  CLEAN_DOCKER_VERBOSE=false|true

Auto-mode tuning:
  CLEAN_DOCKER_AUTO_MIN_FREE_GB=10
  CLEAN_DOCKER_AUTO_MIN_FREE_INODES=5000
  CLEAN_DOCKER_COLIMA_PROFILE=default
EOF
}

main() {
  validate

  case "${cmd}" in
    info)  print_info ;;
    prune|clean) run_prune ;;
    -h|--help|help) usage ;;
    *) die "Unknown command: ${cmd} (use info|prune|clean)" ;;
  esac
}

main "$@"
