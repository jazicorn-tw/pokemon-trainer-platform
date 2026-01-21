#!/usr/bin/env bash
set -euo pipefail

# Check that tracked repo scripts have the executable bit set in Git.
#
# STRICT behavior:
#   - STRICT=0 (default): WARN only (local dev)
#   - STRICT=1           : FAIL the build on any missing executable bit
#   - STRICT=2           : AUTO-FIX (chmod +x [+ optionally git add]), then FAIL if still broken
#
# Why this exists:
#   - Git hooks (.githooks/*) MUST be executable to run
#   - Shell scripts under scripts/ MUST be executable to avoid "permission denied"
#
# This script only inspects *tracked files* to avoid noise from local-only scripts.

STRICT="${STRICT:-0}"

# Optional JSON config (env var wins)
CONFIG_FILE="${CHECK_EXECUTABLE_BITS_CONFIG:-.config/check-executable-bits.json}"

# Patterns of tracked files that are expected to be executable
PATTERNS=(
  "scripts/*.sh"
  ".githooks/*"
)

# Ensure we run from repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "check-executable-bits: not in a git repo; skipping."
  exit 0
fi
cd "${REPO_ROOT}"

read_json_strict_default() {
  [[ -f "${CONFIG_FILE}" ]] || return 1
  python3 - "${CONFIG_FILE}" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
  data = json.load(f)
val = data.get("strict", {}).get("default", None)
if val is None:
  sys.exit(2)
print(val)
PY
}

# If STRICT not explicitly set (or left at default 0), allow JSON to override default
# You can change this logic if you want JSON to always win.
if [[ "${STRICT}" == "0" && -f "${CONFIG_FILE}" ]]; then
  cfg="$(read_json_strict_default || true)"
  if [[ -n "${cfg:-}" ]]; then
    STRICT="${cfg}"
  fi
fi

missing=()

collect_missing() {
  missing=()
  for pat in "${PATTERNS[@]}"; do
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      [[ -f "${file}" ]] || continue

      # Git file mode (first column): 100755 = executable, 100644 = not executable
      mode="$(git ls-files --stage -- "${file}" | awk '{print $1}')"
      if [[ "${mode}" != "100755" ]]; then
        missing+=("${file}")
      fi
    done < <(git ls-files -- "${pat}" || true)
  done
}

report_missing() {
  echo "check-executable-bits: Found tracked files missing executable bit:"
  for f in "${missing[@]}"; do
    echo "  - ${f}"
  done
}

auto_fix() {
  # Ensure we only chmod files that still exist
  for f in "${missing[@]}"; do
    [[ -f "${f}" ]] || continue
    chmod +x "${f}"
  done

  # Optional but usually desired for “automatic” behavior:
  # stage the file mode change so it can be committed.
  git add -- "${missing[@]}" 2>/dev/null || true
}

collect_missing

if (( ${#missing[@]} == 0 )); then
  echo "check-executable-bits: OK (all tracked scripts are executable)."
  exit 0
fi

# STRICT=2: auto-fix path
if [[ "${STRICT}" == "2" ]]; then
  report_missing
  echo ""
  echo "check-executable-bits: STRICT=2 -> auto-fixing (chmod +x) and staging changes."
  auto_fix

  # Re-check after fix
  collect_missing
  if (( ${#missing[@]} == 0 )); then
    echo "check-executable-bits: ✅ fixed executable bits."
    echo "check-executable-bits: staged changes; commit them with:"
    echo '  git commit -m "chore(dev): fix executable bits"'
    exit 0
  fi

  echo "check-executable-bits: ❌ auto-fix attempted, but some files are still not executable in Git:"
  report_missing
  exit 1
fi

# STRICT=0/1: report instructions
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

if [[ "${STRICT}" == "1" ]]; then
  echo "check-executable-bits: STRICT=1 -> failing."
  exit 1
fi

echo "check-executable-bits: WARNING only (STRICT=0)."
exit 0
