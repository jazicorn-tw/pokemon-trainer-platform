#!/usr/bin/env bash
set -euo pipefail

# Local semantic-release dry run helper.
#
# Usage:
#   ./scripts/release/semrel-dry-run.sh
#
# Notes:
# - Requires node_modules installed (npm i)
# - Does NOT create tags or GitHub Releases
# - Prints what semantic-release *would* do, including next version

export CI=true

# Optional: increase logging when debugging
# export DEBUG=semantic-release:*

npx semantic-release --dry-run --no-ci
