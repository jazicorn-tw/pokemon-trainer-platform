#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
if [[ "${OS}" != "Linux" ]]; then
  echo "bootstrap-linux: non-Linux system detected (${OS}); skipping."
  exit 0
fi

echo "🐧 Linux bootstrap: fixing executable bits + configuring git hooks"

# Resolve script dir and source common bootstrap
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/bootstrap/bootstrap-common.sh
source "${SCRIPT_DIR}/bootstrap-common.sh"

echo "✅ Linux bootstrap complete"
echo "Tip: If you see 'permission denied', re-run: ./scripts/bootstrap/bootstrap-linux.sh"
