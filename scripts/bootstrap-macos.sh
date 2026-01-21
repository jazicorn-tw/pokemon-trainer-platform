#!/usr/bin/env bash
set -euo pipefail

chmod +x scripts/*.sh 2>/dev/null || true
chmod +x .githooks/* 2>/dev/null || true

OS="$(uname -s)"
if [[ "${OS}" != "Darwin" ]]; then
  echo "bootstrap-macos: non-macOS system detected (${OS}); skipping."
  exit 0
fi

echo "🍎 macOS bootstrap: fixing executable bits + configuring git hooks"

# Ensure we are at repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "bootstrap-macos: not in a git repo; aborting."
  exit 1
fi
cd "${REPO_ROOT}"

# Ensure Git uses repo-managed hooks
echo "🔧 Setting git hooks path to .githooks"
git config core.hooksPath .githooks

# Ensure required directories exist
TARGET_DIRS=(
  ".githooks"
  "scripts"
)

for dir in "${TARGET_DIRS[@]}"; do
  if [[ -d "${dir}" ]]; then
    echo "🔑 Ensuring executable bits in ${dir}/"
    chmod +x "${dir}"/* 2>/dev/null || true
  fi
done

echo "✅ macOS bootstrap complete"
echo "Tip: If you see 'permission denied', re-run: ./scripts/bootstrap-macos.sh"
