#!/usr/bin/env bash
set -euo pipefail

# Check that tracked repo scripts have the executable bit set in Git.
#
# STRICT behavior:
#   - STRICT=0 (default): WARN only
#   - STRICT=1           : FAIL the build on any missing executable bit
#   - STRICT=2           : AUTO-FIX (chmod +x [+ optionally git add]), then FAIL if still broken
#
# Configuration precedence:
#   1) CLI flags (if used)
#   2) Environment variables (STRICT, AUTO_STAGE, CHECK_EXECUTABLE_BITS_CONFIG)
#   3) OS override JSON (e.g. .config/local-settings.macos.json)
#   4) Base JSON (e.g. .config/local-settings.json)
#
# Inspects both tracked files (git index mode) and untracked files (filesystem bit)
# so that newly added scripts are caught before they are committed.

# -----------------------------------------------------------------------------
# IMPORTANT:
# We must distinguish "env var is unset" vs "env var has a value".
# Using STRICT="${STRICT:-0}" makes STRICT always non-empty, which then incorrectly
# overrides JSON config during precedence resolution.
#
# Capture whether the env var was set *before* applying defaults.
# -----------------------------------------------------------------------------
ENV_STRICT_SET=0
ENV_AUTO_STAGE_SET=0
ENV_STRICT_VAL=""
ENV_AUTO_STAGE_VAL=""

if [[ "${STRICT+x}" == "x" ]]; then
  ENV_STRICT_SET=1
  ENV_STRICT_VAL="${STRICT}"
fi
if [[ "${AUTO_STAGE+x}" == "x" ]]; then
  ENV_AUTO_STAGE_SET=1
  ENV_AUTO_STAGE_VAL="${AUTO_STAGE}"
fi

# Defaults (used only when env vars are unset and JSON/CLI don't override)
STRICT_DEFAULT="0"
AUTO_STAGE_DEFAULT=""

# Config file
CONFIG_FILE="${CHECK_EXECUTABLE_BITS_CONFIG:-.config/local-settings.json}"

usage() {
  cat <<'EOF'
Usage: scripts/check/check-executable-bits.sh [--print-config] [--strict N] [--auto-stage 0|1]

  --print-config     Print the effective config (after merge/precedence) and exit 0
  --strict N         Override strictness (0 warn, 1 fail, 2 auto-fix)
  --auto-stage 0|1   Override whether STRICT=2 stages changes with git add

Env vars (override JSON):
  STRICT=0|1|2
  AUTO_STAGE=0|1
  CHECK_EXECUTABLE_BITS_CONFIG=path/to/config.json
EOF
}

PRINT_CONFIG=0
CLI_STRICT=""
CLI_AUTO_STAGE=""

while (( "$#" )); do
  case "$1" in
    --print-config) PRINT_CONFIG=1; shift ;;
    --strict) CLI_STRICT="${2:-}"; shift 2 ;;
    --auto-stage) CLI_AUTO_STAGE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "check-executable-bits: unknown arg: $1"; usage; exit 2 ;;
  esac
done

# Ensure we run from repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "check-executable-bits: not in a git repo; skipping."
  exit 0
fi
cd "${REPO_ROOT}"

# --- Resolve config via Python (merge base + OS override, validate, output effective values) ---
resolve_config() {
  python3 - "${CONFIG_FILE}" <<'PY'
import json, platform, sys
from pathlib import Path

base_path = Path(sys.argv[1])
system = platform.system().lower()

if system == "darwin":
  suffix = "macos"
elif system.startswith("linux"):
  suffix = "linux"
elif system.startswith("windows"):
  suffix = "windows"
else:
  suffix = system

override_path = base_path.parent / f"local-settings.{suffix}.json"

def load_json(path: Path):
  if not path.exists():
    return {}
  with path.open() as f:
    return json.load(f)

def deep_merge(a, b):
  if not isinstance(a, dict) or not isinstance(b, dict):
    return b
  out = dict(a)
  for k, v in b.items():
    if k in out and isinstance(out[k], dict) and isinstance(v, dict):
      out[k] = deep_merge(out[k], v)
    else:
      out[k] = v
  return out

base = load_json(base_path)
override = load_json(override_path)
merged = deep_merge(base, override)

strict = merged.get("checks", {}).get("executableBits", {}).get("strict", 0)
auto_stage = merged.get("checks", {}).get("executableBits", {}).get("autoStage", False)

if not isinstance(strict, int) or strict not in (0, 1, 2):
  raise SystemExit(f"Invalid checks.executableBits.strict: {strict!r} (expected 0, 1, or 2)")
if not isinstance(auto_stage, bool):
  raise SystemExit(f"Invalid checks.executableBits.autoStage: {auto_stage!r} (expected boolean)")

print(f"STRICT={strict}")
print(f"AUTO_STAGE={'1' if auto_stage else '0'}")
print(f"BASE_CONFIG={base_path.as_posix()}")
print(f"OS_OVERRIDE={override_path.as_posix() if override_path.exists() else ''}")
PY
}

RESOLVED_STRICT=""
RESOLVED_AUTO_STAGE=""
BASE_CONFIG=""
OS_OVERRIDE=""

if [[ -f "${CONFIG_FILE}" ]]; then
  while IFS= read -r line; do
    case "$line" in
      STRICT=*) RESOLVED_STRICT="${line#STRICT=}" ;;
      AUTO_STAGE=*) RESOLVED_AUTO_STAGE="${line#AUTO_STAGE=}" ;;
      BASE_CONFIG=*) BASE_CONFIG="${line#BASE_CONFIG=}" ;;
      OS_OVERRIDE=*) OS_OVERRIDE="${line#OS_OVERRIDE=}" ;;
    esac
  done < <(resolve_config)
else
  RESOLVED_STRICT="${STRICT_DEFAULT}"
  RESOLVED_AUTO_STAGE="0"
  BASE_CONFIG="${CONFIG_FILE}"
  OS_OVERRIDE=""
fi

EFFECTIVE_STRICT="${RESOLVED_STRICT}"
EFFECTIVE_AUTO_STAGE="${RESOLVED_AUTO_STAGE}"

# Precedence: env vars override JSON (but only if the env var was actually set)
if (( ENV_STRICT_SET )) && [[ -n "${ENV_STRICT_VAL}" ]]; then
  EFFECTIVE_STRICT="${ENV_STRICT_VAL}"
fi
if (( ENV_AUTO_STAGE_SET )) && [[ -n "${ENV_AUTO_STAGE_VAL}" ]]; then
  EFFECTIVE_AUTO_STAGE="${ENV_AUTO_STAGE_VAL}"
fi

# Precedence: CLI overrides everything
if [[ -n "${CLI_STRICT}" ]]; then
  EFFECTIVE_STRICT="${CLI_STRICT}"
fi
if [[ -n "${CLI_AUTO_STAGE}" ]]; then
  EFFECTIVE_AUTO_STAGE="${CLI_AUTO_STAGE}"
fi

# If AUTO_STAGE is still unset/empty, apply default (0)
if [[ -z "${EFFECTIVE_AUTO_STAGE}" ]]; then
  EFFECTIVE_AUTO_STAGE="0"
fi
# If STRICT is still unset/empty, apply default (0)
if [[ -z "${EFFECTIVE_STRICT}" ]]; then
  EFFECTIVE_STRICT="${STRICT_DEFAULT}"
fi

if [[ ! "${EFFECTIVE_STRICT}" =~ ^[0-2]$ ]]; then
  echo "check-executable-bits: invalid STRICT=${EFFECTIVE_STRICT} (expected 0, 1, or 2)"
  exit 2
fi
if [[ ! "${EFFECTIVE_AUTO_STAGE}" =~ ^[01]$ ]]; then
  echo "check-executable-bits: invalid AUTO_STAGE=${EFFECTIVE_AUTO_STAGE} (expected 0 or 1)"
  exit 2
fi

if [[ "${PRINT_CONFIG}" == "1" ]]; then
  echo "check-executable-bits: effective config"
  echo "  base:        ${BASE_CONFIG}"
  if [[ -n "${OS_OVERRIDE}" ]]; then
    echo "  os override: ${OS_OVERRIDE}"
  else
    echo "  os override: (none)"
  fi
  echo "  strict:      ${EFFECTIVE_STRICT}"
  echo "  autoStage:   ${EFFECTIVE_AUTO_STAGE}"
  exit 0
fi

PATTERNS=(
  "scripts/"
  ".githooks/"
)

missing=()

collect_missing() {
  missing=()
  for pat in "${PATTERNS[@]}"; do
    # Tracked files: check git index mode
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      [[ -f "${file}" ]] || continue
      mode="$(git ls-files --stage -- "${file}" | awk '{print $1}')"
      if [[ "${mode}" != "100755" ]]; then
        missing+=("${file}")
      fi
    done < <(git ls-files -- "${pat}" || true)

    # Untracked files: check filesystem bit (no git index entry yet)
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      [[ -f "${file}" ]] || continue
      if [[ ! -x "${file}" ]]; then
        missing+=("${file}")
      fi
    done < <(git ls-files --others --exclude-standard -- "${pat}" || true)
  done
}

report_missing() {
  echo "check-executable-bits: Found tracked files missing executable bit:"
  for f in "${missing[@]}"; do
    echo "  - ${f}"
  done
}

auto_fix() {
  for f in "${missing[@]}"; do
    [[ -f "${f}" ]] || continue
    chmod +x "${f}"
  done
  if [[ "${EFFECTIVE_AUTO_STAGE}" == "1" ]]; then
    git add -- "${missing[@]}" 2>/dev/null || true
  fi
}

collect_missing

if (( ${#missing[@]} == 0 )); then
  echo "check-executable-bits: OK (all scripts are executable — tracked + untracked)."
  exit 0
fi

if [[ "${EFFECTIVE_STRICT}" == "2" ]]; then
  report_missing
  echo ""
  if [[ "${EFFECTIVE_AUTO_STAGE}" == "1" ]]; then
    echo "check-executable-bits: STRICT=2 -> auto-fixing (chmod +x) and staging changes."
  else
    echo "check-executable-bits: STRICT=2 -> auto-fixing (chmod +x)."
  fi
  auto_fix

  collect_missing
  if (( ${#missing[@]} == 0 )); then
    echo "check-executable-bits: ✅ fixed executable bits."
    if [[ "${EFFECTIVE_AUTO_STAGE}" == "1" ]]; then
      echo 'check-executable-bits: staged changes; commit them with:'
      echo '  git commit -m "chore(dev): fix executable bits"'
    else
      echo 'check-executable-bits: please stage + commit the changes:'
      echo '  git add <file(s)>'
      echo '  git commit -m "chore(dev): fix executable bits"'
    fi
    exit 0
  fi

  echo "check-executable-bits: ❌ auto-fix attempted, but some files are still not executable in Git:"
  report_missing
  exit 1
fi

report_missing

cat <<'EOF'

Fix locally:
  chmod +x <file(s)>
  git add <file(s)>
  git commit -m "chore(dev): make scripts and hooks executable"

Why this matters:
  - Git ignores non-executable hooks (e.g. .githooks/commit-msg)
  - CI and local tooling may fail with 'permission denied'

Tip:
  If this keeps happening, ensure bootstrap scripts apply +x
  immediately after cloning.

EOF

if [[ "${EFFECTIVE_STRICT}" == "1" ]]; then
  echo "check-executable-bits: STRICT=1 -> failing."
  exit 1
fi

echo "check-executable-bits: WARNING only (STRICT=0)."
exit 0
