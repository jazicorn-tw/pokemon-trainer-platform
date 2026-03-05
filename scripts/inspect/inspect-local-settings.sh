#!/usr/bin/env bash
set -euo pipefail

# scripts/inspect/inspect-local-settings.sh
#
# Prints the effective resolved values from .config/local-settings.json
# after deep-merging the base file with any OS-specific override
# (e.g. local-settings.macos.json).
#
# Read-only. No side effects.
# Falls back to raw JSON cat if python3 is unavailable.

BOLD="${BOLD:-$'\033[1m'}"
CYAN="${CYAN:-$'\033[36m'}"
GREEN="${GREEN:-$'\033[32m'}"
GRAY="${GRAY:-$'\033[90m'}"
DIM="${DIM:-$'\033[2m'}"
RESET="${RESET:-$'\033[0m'}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="${REPO_ROOT}/.config/local-settings.json"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  printf "%b\n" "${GRAY}No local settings file found at ${CONFIG_FILE}${RESET}" >&2
  exit 1
fi

printf "%s🧩 Effective local settings%s\n" "${BOLD}" "${RESET}"
printf "%s%s%s\n" "${GRAY}" "${CONFIG_FILE}" "${RESET}"

if ! command -v python3 >/dev/null 2>&1; then
  printf "\n%b\n" "${GRAY}(python3 not found — showing raw JSON)${RESET}"
  cat "${CONFIG_FILE}"
  exit 0
fi

python3 - "${CONFIG_FILE}" <<'PY'
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

if override_path.exists():
    import os
    GRAY  = "\033[90m"
    RESET = "\033[0m"
    rel   = os.path.relpath(str(override_path), str(base_path.parent.parent))
    print(f"{GRAY}(merged with {rel}){RESET}")

BOLD  = "\033[1m"
CYAN  = "\033[36m"
GREEN = "\033[32m"
GRAY  = "\033[90m"
DIM   = "\033[2m"
RESET = "\033[0m"

def get(d, *keys):
    """Walk nested keys; return str value or '' if missing."""
    cur = d
    for k in keys:
        if not isinstance(cur, dict):
            return ""
        v = cur.get(k)
        if v is None:
            return ""
        cur = v
    return str(cur)

def row(label, value, default):
    resolved = value if value != "" else default
    src = "" if value != "" else f"  {DIM}(default){RESET}"
    print(f"  {CYAN}{label:<24}{RESET} {GRAY}→{RESET}  {GREEN}{resolved}{RESET}{src}")

def section(title):
    print(f"\n{BOLD}{title}{RESET}")

section("colima.*")
row("colima.profile",         get(merged, "colima", "profile"),                   "default")
row("colima.required.memGib", get(merged, "colima", "required", "memGib"),        "8")
row("colima.required.cpu",    get(merged, "colima", "required", "cpu"),           "6")
row("colima.tolerance.gib",   get(merged, "colima", "tolerance", "gib"),          "0.25")

section("doctor.*")
row("doctor.minDockerMemGb",  get(merged, "doctor", "minDockerMemGb"),            "4")
row("doctor.minDockerCpus",   get(merged, "doctor", "minDockerCpus"),             "2")

section("local.*")
row("local.db.host",          get(merged, "local", "db", "host"),                 "localhost")
row("local.db.port",          get(merged, "local", "db", "port"),                 "5432")
row("local.db.name",          get(merged, "local", "db", "name"),                 "APP_NAME")

section("docker.*")
row("docker.postgres.image",  get(merged, "docker", "postgres", "image"),         "postgres:16-alpine")
PY
