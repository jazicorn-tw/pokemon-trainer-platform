#!/usr/bin/env bash
set -euo pipefail

# Install repo-local git hooks.
# This keeps hooks versioned and consistent across machines.

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "install-hooks: not in a git repo; aborting."
  exit 1
fi
cd "${REPO_ROOT}"

# Ensure Git uses repo-managed hooks.
git config core.hooksPath .githooks

# Ensure hook dir exists (helps fresh clones / partial checkouts).
if [[ ! -d ".githooks" ]]; then
  echo "install-hooks: .githooks directory not found; nothing to install."
  exit 0
fi

# Ensure hooks are executable (Git ignores non-executable hooks).
# Only chmod regular files to avoid weirdness.
find .githooks -maxdepth 1 -type f -print0 2>/dev/null | xargs -0 chmod +x 2>/dev/null || true

# Ensure repo scripts are executable (prevents "Permission denied" in make targets).
# Uses find to cover all subdirectories (scripts are organized into subfolders).
find scripts -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.mjs" \) -print0 \
  | xargs -0 chmod +x 2>/dev/null || true

echo "✅ Installed git hooks:"
echo "  core.hooksPath = .githooks"
echo ""
echo "Bypass (one-off):"
echo "  SKIP_QUALITY=1 git commit ...          # skip pre-commit quality gate"
echo "  SKIP_COMMIT_MSG_CHECK=1 git commit ... # skip commit-msg validation"
