#!/usr/bin/env bash
set -euo pipefail

# doctor.sh — Local environment sanity checks.
#
# - Fast fail for missing Docker/Colima/Java/Gradle wrapper
# - Does NOT auto-start anything (explicit is better than implicit)
# - Safe to run on macOS (Colima or Docker Desktop) + Linux (Docker Engine)
#
# Optional knobs:
#   DOCTOR_REQUIRE_COLIMA=1         -> fail if Colima isn't installed (macOS-only preference)
#   DOCTOR_MIN_DOCKER_MEM_GB=4      -> warn if Docker reports less (best-effort)
#   DOCTOR_MIN_DOCKER_CPUS=2        -> warn if Docker reports fewer CPUs (best-effort)
#   DOCTOR_STRICT=1                 -> treat warnings as failures
#
# JSON output:
#   ./scripts/doctor.sh --json
#   ./scripts/doctor.sh --json --strict
#   or: DOCTOR_JSON=1 ./scripts/doctor.sh
#
# CI behavior:
#   If CI=true/1, this script exits immediately (local convenience only),
#   unless you pass --allow-ci (useful for CI artifact snapshots).
#
# Intended to be run via `make doctor`, but safe to run directly.
# CI remains the authoritative quality gate (ADR-000).

# ----------------------------
# Args / output mode
# ----------------------------
JSON_MODE="${DOCTOR_JSON:-0}"
STRICT="${DOCTOR_STRICT:-0}"
ALLOW_CI="${DOCTOR_ALLOW_CI:-0}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      JSON_MODE="1"
      shift
      ;;
    --strict)
      STRICT="1"
      shift
      ;;
    --allow-ci)
      ALLOW_CI="1"
      shift
      ;;
    -h|--help)
      cat <<'EOF'
doctor.sh — Local environment sanity checks

Usage:
  ./scripts/doctor.sh
  ./scripts/doctor.sh --json
  ./scripts/doctor.sh --json --strict
  ./scripts/doctor.sh --json --allow-ci   (for CI artifacts)

Flags:
  --json       Emit structured JSON (no human output)
  --strict     Treat warnings as failures
  --allow-ci   Run even when CI=true (useful for artifact snapshots)
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

WARNINGS=()
ERRORS=()

json_escape() {
  # Escape for JSON string context
  local s="${1:-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf "%s" "${s}"
}

json_array() {
  # Prints JSON array from bash array name passed as $1
  # Portable + nounset-safe; filters empty entries
  local name="${1:-}"
  local -a arr=()
  if [[ -n "${name}" ]]; then
    eval "arr=(\"\${${name}[@]-}\")"
  fi

  local out="["
  local first=1
  local i
  for (( i=0; i<${#arr[@]}; i++ )); do
    # Skip empty or whitespace-only entries
    if [[ -z "${arr[$i]//[[:space:]]/}" ]]; then
      continue
    fi

    local item
    item="$(json_escape "${arr[$i]}")"
    if (( first == 0 )); then
      out+=","
    fi
    out+="\"${item}\""
    first=0
  done

  out+="]"
  printf "%s" "${out}"
}

say() {
  if [[ "${JSON_MODE}" != "1" ]]; then
    printf "%s\n" "$*"
  fi
}

ok() {
  if [[ "${JSON_MODE}" != "1" ]]; then
    say "✅ $*"
  fi
}

warn() {
  local msg="${1:-}"
  [[ -z "${msg//[[:space:]]/}" ]] && return 0
  WARNINGS+=("${msg}")
  if [[ "${JSON_MODE}" != "1" ]]; then
    say "⚠️  ${msg}"
  fi
}

# Will be set during execution
STATUS="unknown"
OS="$(uname -s 2>/dev/null || true)"
GIT_BRANCH=""
JAVA_VERSION_RAW=""
JAVA_MAJOR=""
GRADLEW_EXISTS=0
GRADLEW_EXEC=0
DOCKER_CLI=0
DOCKER_COMPOSE=0
DOCKER_DAEMON=0
DOCKER_PROVIDER="unknown"
DOCKER_CONTEXT=""
DOCKER_CPUS=""
DOCKER_MEM_GB=""
DOCKER_SOCKET_OK=0
HAS_COLIMA=0
COLIMA_RUNNING=0
COLIMA_MEM_ALLOC=""
COLIMA_CPU_ALLOC=""

emit_json_and_exit() {
  local exit_code="${1:-0}"
  local status_str="${2:-unknown}"

  local json="{"
  json+="\"status\":\"$(json_escape "${status_str}")\""
  json+=",\"os\":\"$(json_escape "${OS}")\""
  json+=",\"git_branch\":\"$(json_escape "${GIT_BRANCH}")\""
  json+=",\"java_version_raw\":\"$(json_escape "${JAVA_VERSION_RAW}")\""
  json+=",\"java_major\":\"$(json_escape "${JAVA_MAJOR}")\""
  json+=",\"gradlew_exists\":${GRADLEW_EXISTS}"
  json+=",\"gradlew_executable\":${GRADLEW_EXEC}"
  json+=",\"docker_cli\":${DOCKER_CLI}"
  json+=",\"docker_compose\":${DOCKER_COMPOSE}"
  json+=",\"docker_daemon_reachable\":${DOCKER_DAEMON}"
  json+=",\"docker_context\":\"$(json_escape "${DOCKER_CONTEXT}")\""
  json+=",\"docker_provider\":\"$(json_escape "${DOCKER_PROVIDER}")\""
  json+=",\"docker_cpus\":\"$(json_escape "${DOCKER_CPUS}")\""
  json+=",\"docker_memory_gb\":\"$(json_escape "${DOCKER_MEM_GB}")\""
  json+=",\"docker_socket_healthy\":${DOCKER_SOCKET_OK}"
  json+=",\"colima_present\":${HAS_COLIMA}"
  json+=",\"colima_running\":${COLIMA_RUNNING}"
  json+=",\"colima_memory_alloc\":\"$(json_escape "${COLIMA_MEM_ALLOC}")\""
  json+=",\"colima_cpu_alloc\":\"$(json_escape "${COLIMA_CPU_ALLOC}")\""
  json+=",\"warnings\":$(json_array WARNINGS)"
  json+=",\"errors\":$(json_array ERRORS)"
  json+="}"

  printf "%s\n" "${json}"
  exit "${exit_code}"
}

die() {
  local msg="${1:-}"
  [[ -z "${msg//[[:space:]]/}" ]] && msg="Unknown error"
  ERRORS+=("${msg}")
  if [[ "${JSON_MODE}" == "1" ]]; then
    emit_json_and_exit 1 "fail"
  fi
  printf "❌ %s\n" "${msg}"
  exit 1
}

# ----------------------------
# Strict mode / thresholds
# ----------------------------
MIN_MEM_GB="${DOCTOR_MIN_DOCKER_MEM_GB:-4}"
MIN_CPUS="${DOCTOR_MIN_DOCKER_CPUS:-2}"
REQUIRE_COLIMA="${DOCTOR_REQUIRE_COLIMA:-0}"

WARN_AS_FAIL=0
if [[ "${STRICT}" == "1" ]]; then
  WARN_AS_FAIL=1
fi

warn_or_die() {
  if [[ "${WARN_AS_FAIL}" == "1" ]]; then
    die "$1"
  else
    warn "$1"
  fi
}

# ----------------------------
# CI guard (local-only helper)
# ----------------------------
if [[ ("${CI:-}" == "true" || "${CI:-}" == "1") && "${ALLOW_CI}" != "1" ]]; then
  if [[ "${JSON_MODE}" == "1" ]]; then
    STATUS="skip"
    WARNINGS+=("CI detected; skipping local doctor checks.")
    emit_json_and_exit 0 "skip"
  fi
  say "CI detected; skipping local doctor checks."
  exit 0
fi

say "🔎 Running local doctor checks..."

# ----------------------------
# Git branch (best-effort)
# ----------------------------
if command -v git >/dev/null 2>&1; then
  GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

# ----------------------------
# Java (project expects Java 21)
# ----------------------------
if ! command -v java >/dev/null 2>&1; then
  die "Java not found. Install Java 21 (Temurin recommended) and ensure 'java' is on PATH."
fi

# Capture the first *actual* Java version line (skip JAVA_TOOL_OPTIONS noise)
JAVA_VERSION_RAW="$(
  java -version 2>&1 \
    | grep -E 'version "[^"]+"' \
    | head -n 1 \
    || true
)"

JAVA_MAJOR="$(echo "${JAVA_VERSION_RAW}" | sed -E 's/.*version "([0-9]+).*/\1/' || true)"

# Fallback parse if the simple parse fails
if [[ -z "${JAVA_MAJOR}" || "${JAVA_MAJOR}" == "${JAVA_VERSION_RAW}" ]]; then
  JAVA_MAJOR_FALLBACK="$(java -XshowSettings:properties -version 2>&1 | sed -n 's/^ *java\.version *= *//p' | head -n 1 | cut -d. -f1 || true)"
  if [[ -n "${JAVA_MAJOR_FALLBACK}" && "${JAVA_MAJOR_FALLBACK}" =~ ^[0-9]+$ ]]; then
    JAVA_MAJOR="${JAVA_MAJOR_FALLBACK}"
  else
    warn "Could not parse Java version from: ${JAVA_VERSION_RAW}"
    JAVA_MAJOR=""
  fi
fi

if [[ -n "${JAVA_MAJOR}" ]]; then
  if [[ "${JAVA_MAJOR}" -lt 21 ]]; then
    die "Java ${JAVA_MAJOR} detected; this project expects Java 21+. (${JAVA_VERSION_RAW})"
  fi
  ok "java OK (${JAVA_VERSION_RAW})"
fi

# ----------------------------
# Gradle wrapper
# ----------------------------
if [[ ! -f "./gradlew" ]]; then
  GRADLEW_EXISTS=0
  die "Gradle wrapper not found (./gradlew). Run from the repo root, or ensure the wrapper is committed."
fi
GRADLEW_EXISTS=1

if [[ ! -x "./gradlew" ]]; then
  GRADLEW_EXEC=0
  warn_or_die "Gradle wrapper exists but is not executable. Fix with: chmod +x ./gradlew"
else
  GRADLEW_EXEC=1
  ok "gradle wrapper OK (./gradlew)"
fi

# ----------------------------
# Docker CLI
# ----------------------------
if ! command -v docker >/dev/null 2>&1; then
  DOCKER_CLI=0
  die "Docker CLI not found. Install Docker Desktop (macOS/Windows), Docker Engine (Linux), or Colima (macOS)."
fi
DOCKER_CLI=1
ok "docker CLI found"

# docker compose plugin
if docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE=1
  ok "docker compose OK"
else
  DOCKER_COMPOSE=0
  warn_or_die "docker compose not available. Install Docker Desktop / Engine with the Compose plugin."
fi

# docker context (helps diagnose mismatches on macOS)
DOCKER_CONTEXT="$(docker context show 2>/dev/null || true)"
if [[ -n "${DOCKER_CONTEXT}" ]]; then
  ok "docker context: ${DOCKER_CONTEXT}"
fi

# ----------------------------
# Colima (optional)
# ----------------------------
if command -v colima >/dev/null 2>&1; then
  HAS_COLIMA=1
  ok "colima found"
  if colima status >/dev/null 2>&1; then
    COLIMA_RUNNING=1
    ok "colima is running"
  else
    COLIMA_RUNNING=0
    die "Colima is installed but not running. Start it with: colima start"
  fi
else
  HAS_COLIMA=0
  if [[ "${OS}" == "Darwin" && "${REQUIRE_COLIMA}" == "1" ]]; then
    die "Colima not found but DOCTOR_REQUIRE_COLIMA=1. Install it or unset DOCTOR_REQUIRE_COLIMA."
  fi
  if [[ "${OS}" == "Darwin" ]]; then
    warn "colima not found. If you're using Docker Desktop, this is fine."
  else
    ok "colima not required on ${OS}"
  fi
fi

# ----------------------------
# Docker daemon
# ----------------------------
if ! docker info >/dev/null 2>&1; then
  DOCKER_DAEMON=0
  if [[ "${OS}" == "Darwin" && "${HAS_COLIMA}" == "1" ]]; then
    die "Docker daemon not reachable. Colima may be misconfigured. Try: colima restart"
  fi
  die "Docker daemon not reachable. Start Docker Desktop or the Docker service."
fi
DOCKER_DAEMON=1
ok "docker daemon reachable"

INFO="$(docker info 2>/dev/null || true)"

# Provider detection
if echo "${INFO}" | grep -qi "docker desktop"; then
  DOCKER_PROVIDER="docker-desktop"
elif echo "${INFO}" | grep -qi "colima"; then
  DOCKER_PROVIDER="colima"
elif echo "${INFO}" | grep -qi "rancher desktop"; then
  DOCKER_PROVIDER="rancher-desktop"
elif echo "${INFO}" | grep -qi "podman"; then
  DOCKER_PROVIDER="podman"
else
  DOCKER_PROVIDER="unknown"
fi
ok "docker provider: ${DOCKER_PROVIDER}"

# Context/provider mismatch warning (macOS)
if [[ "${OS}" == "Darwin" && -n "${DOCKER_CONTEXT}" ]]; then
  if [[ "${DOCKER_PROVIDER}" == "colima" && "${DOCKER_CONTEXT}" != "colima" ]]; then
    warn_or_die "Docker provider looks like Colima, but docker context is '${DOCKER_CONTEXT}'. Try: docker context use colima"
  elif [[ "${DOCKER_PROVIDER}" == "docker-desktop" && "${DOCKER_CONTEXT}" == "colima" ]]; then
    warn_or_die "Docker provider looks like Docker Desktop, but docker context is 'colima'. Try: docker context use default"
  fi
fi

# CPUs (best-effort)
DOCKER_CPUS="$(echo "${INFO}" | sed -n 's/^ *CPUs: *//p' | head -n 1 || true)"
if [[ -n "${DOCKER_CPUS}" ]]; then
  ok "cpu check: ${DOCKER_CPUS}"
  if [[ "${DOCKER_CPUS}" =~ ^[0-9]+$ ]]; then
    if (( DOCKER_CPUS < MIN_CPUS )); then
      warn_or_die "Docker reports ${DOCKER_CPUS} CPUs; recommended >= ${MIN_CPUS} CPUs for Gradle + Testcontainers."
    fi
  fi
else
  warn "Could not determine Docker CPUs from 'docker info'. Skipping CPU check."
fi

# Memory (best-effort)
MEM_LINE="$(echo "${INFO}" | sed -n 's/^ *Total Memory: *//p' | head -n 1 || true)"
if [[ -n "${MEM_LINE}" ]]; then
  MEM_NUM="$(echo "${MEM_LINE}" | sed -E 's/[^0-9.].*$//' || true)"
  if [[ -n "${MEM_NUM}" ]]; then
    DOCKER_MEM_GB="${MEM_NUM}"
  fi
fi

if [[ -n "${DOCKER_MEM_GB}" ]]; then
  awk -v mem="${DOCKER_MEM_GB}" -v min="${MIN_MEM_GB}" 'BEGIN { exit (mem+0 < min+0) }' \
    || warn_or_die "Docker reports ~${DOCKER_MEM_GB} GiB memory; recommended >= ${MIN_MEM_GB} GiB."
  ok "memory check: ~${DOCKER_MEM_GB} GiB"
else
  warn "Could not determine Docker memory from 'docker info'. Skipping memory check."
fi

# ----------------------------
# Socket expectation (act parity on macOS + Colima)
# ----------------------------
actrc_socket_override() {
  # Returns a socket path if ~/.actrc explicitly sets --container-daemon-socket, else empty.
  local actrc="${HOME}/.actrc"
  if [[ ! -f "${actrc}" ]]; then
    return 0
  fi

  awk '
    $1=="--container-daemon-socket" && $2!="" { print $2; exit }
    $1 ~ /^--container-daemon-socket=/ {
      sub(/^--container-daemon-socket=/, "", $1); print $1; exit
    }
  ' "${actrc}" 2>/dev/null || true
}

docker_host_socket_override() {
  # Returns a socket path if DOCKER_HOST is unix:///..., else empty.
  if [[ -n "${DOCKER_HOST:-}" && "${DOCKER_HOST}" =~ ^unix:// ]]; then
    printf "%s" "${DOCKER_HOST#unix://}"
  fi
}

# Only warn if the user *explicitly configured* a socket for tooling (actrc or DOCKER_HOST).
# If nothing is configured, we assume tooling will follow the active Docker context (which is healthy).
if [[ "${OS}" == "Darwin" && "${DOCKER_PROVIDER}" == "colima" ]]; then
  expected_sock="$(actrc_socket_override)"
  source_of_expectation="~/.actrc"

  if [[ -z "${expected_sock}" ]]; then
    expected_sock="$(docker_host_socket_override)"
    source_of_expectation="DOCKER_HOST"
  fi

  if [[ -n "${expected_sock}" ]]; then
    if [[ -S "${expected_sock}" ]]; then
      ok "docker socket present for local tooling (${expected_sock})"
    else
      warn_or_die "Expected docker socket for local tooling (e.g., act) at: ${expected_sock} (configured via ${source_of_expectation})"
    fi
  else
    ok "docker socket routing OK (no act socket override detected; tooling should follow docker context)"
  fi
fi


# ----------------------------
# Colima resource summary + suggestions (DX-only)
# ----------------------------
parse_colima_mem_gib() {
  # Input examples:
  #   "5.773GiB"
  #   "6GiB"
  # Output:
  #   numeric float-ish string (e.g., "5.773") or empty
  local s="${1:-}"
  echo "${s}" | sed -E 's/[^0-9.].*$//' | grep -E '^[0-9]+(\.[0-9]+)?$' || true
}

if [[ "${HAS_COLIMA}" == "1" && "${COLIMA_RUNNING}" == "1" ]]; then
  COLIMA_MEM_ALLOC="$(colima status 2>/dev/null | sed -n 's/^.*memory: *//p' | head -n 1 || true)"
  COLIMA_CPU_ALLOC="$(colima status 2>/dev/null | sed -n 's/^.*cpu: *//p' | head -n 1 || true)"

  if [[ "${JSON_MODE}" != "1" && ( -n "${COLIMA_MEM_ALLOC}" || -n "${COLIMA_CPU_ALLOC}" ) ]]; then
    say ""
    say "ℹ️  Colima resources:"
    [[ -n "${COLIMA_MEM_ALLOC}" ]] && say "   • memory: ${COLIMA_MEM_ALLOC}"
    [[ -n "${COLIMA_CPU_ALLOC}" ]] && say "   • cpu:    ${COLIMA_CPU_ALLOC}"
  fi

  if [[ "${OS}" == "Darwin" ]]; then
    mem_num="$(parse_colima_mem_gib "${COLIMA_MEM_ALLOC}")"
    cpu_num="$(echo "${COLIMA_CPU_ALLOC}" | sed -E 's/[^0-9].*$//' | grep -E '^[0-9]+$' || true)"

    need_suggest=0
    suggest_mem="${MIN_MEM_GB}"
    suggest_cpu="${MIN_CPUS}"

    if [[ -n "${mem_num}" ]]; then
      awk -v mem="${mem_num}" -v min="${MIN_MEM_GB}" 'BEGIN { exit (mem+0 < min+0) ? 0 : 1 }' \
        && need_suggest=1
    fi

    if [[ -n "${cpu_num}" ]]; then
      if (( cpu_num < MIN_CPUS )); then
        need_suggest=1
      fi
    fi

    if [[ -n "${DOCKER_MEM_GB}" ]]; then
      awk -v mem="${DOCKER_MEM_GB}" -v min="${MIN_MEM_GB}" 'BEGIN { exit (mem+0 < min+0) ? 0 : 1 }' \
        && need_suggest=1
    fi
    if [[ -n "${DOCKER_CPUS}" && "${DOCKER_CPUS}" =~ ^[0-9]+$ ]]; then
      if (( DOCKER_CPUS < MIN_CPUS )); then
        need_suggest=1
      fi
    fi

    if [[ "${need_suggest}" == "1" ]]; then
      if [[ "${JSON_MODE}" != "1" ]]; then
        say ""
        say "💡 Tip: Increase Colima resources for Gradle + Testcontainers:"
        say "   colima stop"
        say "   colima start --cpu ${suggest_cpu} --memory ${suggest_mem}"
        say ""
        say "   (Colima persists these settings for future starts.)"
      fi
      WARNINGS+=("Colima resources may be undersized; consider: colima start --cpu ${suggest_cpu} --memory ${suggest_mem}")
    fi
  fi
fi

# ----------------------------
# Done
# ----------------------------
STATUS="pass"

if [[ "${JSON_MODE}" == "1" ]]; then
  # In strict mode, any warnings fail the run (tooling-friendly).
  if [[ "${STRICT}" == "1" && "${#WARNINGS[@]-0}" -gt 0 ]]; then
    emit_json_and_exit 1 "fail"
  fi
  emit_json_and_exit 0 "pass"
fi

ok "Doctor checks passed."
