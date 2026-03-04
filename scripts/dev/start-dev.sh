#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# start-dev.sh
#
# Idempotent local-dev bootstrap:
# - Ensures Colima is running (starts it if needed)
# - Ensures docker context points at colima (best-effort)
# - Optionally starts Docker Compose stack if a compose file exists
#
# Safe defaults: does NOT run Gradle or start your app server automatically.
# -----------------------------------------------------------------------------

_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib"
# shellcheck source=scripts/lib/shell-utils.sh
source "${_LIB}/shell-utils.sh"
# shellcheck source=scripts/lib/colima-utils.sh
source "${_LIB}/colima-utils.sh"

ensure_colima_running() {
  if ! have colima; then
    die "colima not found. Install it first: https://github.com/abiosoft/colima"
  fi

  if colima_running; then
    log "✅ colima already running"
    return 0
  fi

  log "▶ Starting colima…"
  # Allow caller to pass COLIMA_START_ARGS="--cpu 4 --memory 6"
  local args="${COLIMA_START_ARGS:-}"
  # shellcheck disable=SC2086
  colima start ${args}
  log "✅ colima started"
}

ensure_docker_context_colima() {
  if ! have docker; then
    die "docker CLI not found. Install Docker (or Colima + Docker CLI)."
  fi

  # If context doesn't exist, skip rather than failing hard.
  if ! docker context ls --format '{{.Name}}' 2>/dev/null | grep -qx 'colima'; then
    warn "docker context 'colima' not found (skipping context switch)"
    return 0
  fi

  local current
  current="$(docker context show 2>/dev/null || true)"

  if [[ "$current" == "colima" ]]; then
    log "✅ docker context already 'colima'"
    return 0
  fi

  log "▶ Switching docker context to 'colima'…"
  docker context use colima >/dev/null
  log "✅ docker context is now 'colima'"
}

start_compose_if_present() {
  # Look for common compose filenames.
  local compose_file
  compose_file="$(find_compose_file || true)"

  if [[ -z "$compose_file" ]]; then
    log "ℹ️  No compose file found (docker-compose.yml/compose.yml). Skipping compose up."
    return 0
  fi

  if ! have docker; then
    die "docker CLI not found; cannot run docker compose"
  fi

  # Optional: set COMPOSE_PROFILES=dev to activate dev-only services.
  log "▶ docker compose up -d (${compose_file})…"
  docker compose -f "$compose_file" up -d
  log "✅ docker compose stack is up"
}

main() {
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "🚀 Local dev start"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  ensure_colima_running
  ensure_docker_context_colima
  start_compose_if_present

  log ""
  log "🎉 Local dev prerequisites are ready."
  log "Next steps:"
  log "  - make doctor"
  log "  - make run (or ./gradlew bootRun)  # if you have an app target"
}

main "$@"
