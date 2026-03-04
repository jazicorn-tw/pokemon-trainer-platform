#!/usr/bin/env bash
set -euo pipefail

# Common bootstrap tasks shared across OSes:
# - Ensure we run from repo root
# - Ensure tracked scripts + hooks are executable (best effort)
# - Configure git to use repo-managed hooks (.githooks)

log() { echo "$@"; }

# Ensure we are at repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  log "bootstrap: not in a git repo; aborting."
  exit 1
fi
cd "${REPO_ROOT}"

# Fix executable bits (files only; best effort)
find scripts .githooks -type f -exec chmod +x {} + 2>/dev/null || true

# Ensure Git uses repo-managed hooks
log "🔧 Setting git hooks path to .githooks"
git config core.hooksPath .githooks

log "✅ bootstrap: common setup complete"
