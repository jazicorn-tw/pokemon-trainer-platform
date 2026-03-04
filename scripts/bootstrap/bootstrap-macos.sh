#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
if [[ "${OS}" != "Darwin" ]]; then
  echo "bootstrap-macos: non-macOS system detected (${OS}); skipping."
  exit 0
fi

echo "🍎 macOS bootstrap: fixing executable bits + configuring git hooks"

# Resolve script dir and source common bootstrap
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/bootstrap/bootstrap-common.sh
source "${SCRIPT_DIR}/bootstrap-common.sh"

echo "✅ macOS bootstrap complete"
echo "Tip: If you see 'permission denied', re-run: ./scripts/bootstrap/bootstrap-macos.sh"
