#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
if [[ "${OS}" != "Darwin" ]]; then
  echo "check-colima: non-macOS detected (${OS}); skipping."
  exit 0
fi

# ── Resolve config from local-settings.json (with OS override merge) ──────────
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="${REPO_ROOT}/.config/local-settings.json"

_ls_mem_gib=""
_ls_cpu=""
_ls_tol=""
_ls_profile=""

if [[ -f "${CONFIG_FILE}" ]] && command -v python3 >/dev/null 2>&1; then
  while IFS= read -r line; do
    case "${line}" in
      MEM_GIB=*)     _ls_mem_gib="${line#MEM_GIB=}" ;;
      CPU=*)         _ls_cpu="${line#CPU=}" ;;
      TOLERANCE=*)   _ls_tol="${line#TOLERANCE=}" ;;
      PROFILE=*)     _ls_profile="${line#PROFILE=}" ;;
    esac
  done < <(python3 - "${CONFIG_FILE}" <<'PY'
import json, platform, sys
from pathlib import Path

base_path = Path(sys.argv[1])
system = platform.system().lower()
suffix = {"darwin": "macos", "linux": "linux", "windows": "windows"}.get(system, system)
override_path = base_path.parent / f"local-settings.{suffix}.json"

def load_json(p):
  return json.load(p.open()) if p.exists() else {}

def deep_merge(a, b):
  if not isinstance(a, dict) or not isinstance(b, dict):
    return b
  out = dict(a)
  for k, v in b.items():
    out[k] = deep_merge(out[k], v) if k in out and isinstance(out[k], dict) and isinstance(v, dict) else v
  return out

merged = deep_merge(load_json(base_path), load_json(override_path))
c = merged.get("colima", {})
print(f"MEM_GIB={c.get('required', {}).get('memGib', '')}")
print(f"CPU={c.get('required', {}).get('cpu', '')}")
print(f"TOLERANCE={c.get('tolerance', {}).get('gib', '')}")
print(f"PROFILE={c.get('profile', '')}")
PY
)
fi

# Precedence: env var > local-settings.json > hard default
REQUIRED_MEM_GIB="${_ls_mem_gib:-8}"
REQUIRED_CPU="${_ls_cpu:-6}"
TOLERANCE_GIB="${_ls_tol:-0.25}"
PROFILE="${COLIMA_PROFILE:-${_ls_profile:-default}}"

if ! command -v colima >/dev/null 2>&1; then
  echo "❌ Colima is not installed."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker CLI not found."
  exit 1
fi

start_colima() {
  colima start --profile "$PROFILE" --memory "$REQUIRED_MEM_GIB" --cpu "$REQUIRED_CPU"
}

read_docker_resources() {
  # Total Memory comes like: " Total Memory: 5.773GiB"
  # CPUs comes like: " CPUs: 4"
  local total_mem_line cpus_line
  total_mem_line="$(docker info 2>/dev/null | grep -i '^ *Total Memory:' || true)"
  cpus_line="$(docker info 2>/dev/null | grep -i '^ *CPUs:' || true)"

  if [[ -z "$total_mem_line" || -z "$cpus_line" ]]; then
    echo ""
    return 1
  fi

  # Keep decimals (5.773), don't floor.
  local mem_gib cpus
  mem_gib="$(echo "$total_mem_line" | awk '{print $3}' | sed 's/GiB//I')"
  cpus="$(echo "$cpus_line" | awk '{print $2}')"

  if [[ -z "${mem_gib}" || -z "${cpus}" ]]; then
    echo ""
    return 1
  fi

  # Print 4 fields: mem cpus total_mem_line cpus_line
  echo "${mem_gib} ${cpus} ${total_mem_line} | ${cpus_line}"
}

meets_requirements() {
  local mem_gib="$1"
  local cpus="$2"

  local mem_ok cpu_ok
  mem_ok="$(awk -v have="$mem_gib" -v need="$REQUIRED_MEM_GIB" -v tol="$TOLERANCE_GIB" \
    'BEGIN{print (have+0 >= (need - tol)) ? 1 : 0}')"

  cpu_ok=0
  if (( cpus >= REQUIRED_CPU )); then cpu_ok=1; fi

  [[ "$mem_ok" == "1" && "$cpu_ok" == "1" ]]
}

# 1) Ensure Colima is running (don’t rely on status formatting; just check exit code)
if ! colima status --profile "$PROFILE" >/dev/null 2>&1; then
  echo "🚀 Colima not running. Starting with required resources..."
  start_colima
fi

# 2) Read resources from Docker (authoritative for Gradle/Testcontainers)
resources="$(read_docker_resources || true)"
if [[ -z "${resources}" ]]; then
  echo "⚠️  Could not read Docker resources via 'docker info'."
  echo "Try:"
  echo "  docker info | egrep 'CPUs|Total Memory'"
  exit 0
fi

mem_gib="$(echo "$resources" | awk '{print $1}')"
cpus="$(echo "$resources" | awk '{print $2}')"

if meets_requirements "$mem_gib" "$cpus"; then
  echo "👍 Docker resources OK: ${mem_gib}GiB RAM, ${cpus} CPUs"
  exit 0
fi

echo "⚠️  Docker reports insufficient resources:"
echo "   Memory: ${mem_gib}GiB (required: ${REQUIRED_MEM_GIB}GiB, tolerance: -${TOLERANCE_GIB}GiB)"
echo "   CPUs:   ${cpus} (required: ${REQUIRED_CPU})"
echo ""
echo "🔄 Restarting Colima with correct settings..."

colima stop --profile "$PROFILE" >/dev/null 2>&1 || true

# Wait until Colima actually stops to avoid “already running, ignoring”
for _ in {1..30}; do
  if ! colima status --profile "$PROFILE" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

start_colima

# Re-check after restart (one attempt; warn if still below due to overhead/context issues)
resources_after="$(read_docker_resources || true)"
if [[ -z "${resources_after}" ]]; then
  echo "✅ Restarted Colima. (Could not re-read Docker resources.)"
  exit 0
fi

mem_after="$(echo "$resources_after" | awk '{print $1}')"
cpus_after="$(echo "$resources_after" | awk '{print $2}')"
total_mem_line_after="$(echo "$resources_after" | cut -d' ' -f3- | sed 's/^ *//')"

if meets_requirements "$mem_after" "$cpus_after"; then
  echo "✅ Restarted. ${total_mem_line_after}"
  exit 0
fi

echo "⚠️  Restarted, but Docker still reports below requirement:"
echo "   Memory: ${mem_after}GiB (required: ${REQUIRED_MEM_GIB}GiB, tolerance: -${TOLERANCE_GIB}GiB)"
echo "   CPUs:   ${cpus_after} (required: ${REQUIRED_CPU})"
echo ""
echo "Tip: This can happen due to VM overhead or a different Docker context."
echo "Check:"
echo "  docker context show"
echo "  docker info | egrep 'CPUs|Total Memory'"
exit 0
