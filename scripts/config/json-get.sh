#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/config/json-get.sh <file> <keypath> <default>
# Example:
#   scripts/config/json-get.sh .config/local-settings.json planning.dir docs/planning

file="${1:?file required}"
keypath="${2:?keypath required}"
default="${3:-}"

if [[ ! -f "$file" ]]; then
  echo "$default"
  exit 0
fi

python3 - "$file" "$keypath" "$default" <<'PY'
import json, sys
file, keypath, default = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
    cur = data
    for part in keypath.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            print(default)
            sys.exit(0)
    print(cur if cur is not None else default)
except Exception:
    print(default)
PY
