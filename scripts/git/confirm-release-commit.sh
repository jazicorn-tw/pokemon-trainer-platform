#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/git/confirm-release-commit.sh
#
# Warns / prompts when a commit message is likely to trigger semantic-release.
#
# Features:
# - Sync mode: uses scripts/git/semantic-release-impact.mjs (commit-analyzer) when available
# - Fallback heuristic when Node/deps/config aren't available
# - Prompts via /dev/tty (works even if pre-commit steals stdin)
# - Impact icons: 🚨 major / ⚠️ minor / ℹ️ patch
# - Auto-collapsed output for patch releases (shorter box)
# - Shows rule label/detail when available
# - STRICT_RELEASE_CONFIRM:
#     * env var always wins (STRICT_RELEASE_CONFIRM=0/1)
#     * otherwise optional local default from local-settings.json
# - macOS Bash 3.2 compatible (no ${var,,})
#
# Env:
#   CONFIRM_RELEASE_COMMIT=0         -> disable entirely for one command
#   STRICT_RELEASE_CONFIRM=1|0       -> require/disable explicit confirmation (blocks if no TTY when =1)
#   STRICT_RELEASE_CONFIRM_DEFAULT=1 -> override hard default (rare; local-settings.json preferred)
# -----------------------------------------------------------------------------

msg_file="${1:-}"
if [[ -z "${msg_file}" || ! -f "${msg_file}" ]]; then
  echo "confirm-release-commit: commit message file not found." >&2
  exit 1
fi

# Opt-out
if [[ "${CONFIRM_RELEASE_COMMIT:-1}" == "0" ]]; then
  exit 0
fi

# Skip in CI
if [[ "${CI:-}" == "true" ]]; then
  exit 0
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

# -----------------------------------------------------------------------------
# Strict mode resolution (env > local-settings.json > default)
# -----------------------------------------------------------------------------
strict_default="${STRICT_RELEASE_CONFIRM_DEFAULT:-0}"

# Optional: local-settings.json can set a default strict mode.
# This should never override the env var.
#
# local-settings.json:
# {
#   "git": {
#     "releaseConfirm": { "strictDefault": false }
#   }
# }
#
# If jq isn't installed, we silently ignore local-settings.json.
if [[ -n "${repo_root}" && -f "${repo_root}/local-settings.json" ]] && command -v jq >/dev/null 2>&1; then
  ls_val="$(jq -r '.git.releaseConfirm.strictDefault // empty' "${repo_root}/local-settings.json" 2>/dev/null || true)"
  if [[ "${ls_val}" == "true" ]]; then
    strict_default="1"
  elif [[ "${ls_val}" == "false" ]]; then
    strict_default="0"
  fi
fi

STRICT_RELEASE_CONFIRM="${STRICT_RELEASE_CONFIRM:-${strict_default}}"

header="$(head -n 1 "${msg_file}" | tr -d '\r')"
full_msg="$(cat "${msg_file}" | tr -d '\r')"

# Ignore merge/revert/empty
if [[ "${header}" =~ ^Merge\  ]] || [[ "${header}" =~ ^Revert\ \" ]]; then
  exit 0
fi
if [[ -z "${header// /}" ]]; then
  exit 0
fi

impact="none"
used="heuristic"
rule_label=""
rule_detail=""
sync_warn=""

# -----------------------------------------------------------------------------
# Try semantic-release analyzer (sync mode)
# -----------------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  sync_warn="node not found — install Node.js + run 'npm install' for accurate release detection"
elif [[ -z "${repo_root}" || ! -f "${repo_root}/scripts/git/semantic-release-impact.mjs" ]]; then
  sync_warn="semantic-release-impact.mjs not found in repo"
else
  _src_exit=0
  out="$(node "${repo_root}/scripts/git/semantic-release-impact.mjs" "${repo_root}" "${msg_file}" 2>/dev/null)" \
    || _src_exit=$?
  if [[ "${_src_exit}" -eq 0 ]]; then
    while IFS= read -r line; do
      case "${line}" in
        impact=*) impact="${line#impact=}" ;;
        rule_label=*) rule_label="${line#rule_label=}" ;;
        rule_detail=*) rule_detail="${line#rule_detail=}" ;;
      esac
    done <<< "${out}"
    used="semantic-release"
  elif [[ "${_src_exit}" -eq 3 ]]; then
    sync_warn="@semantic-release/commit-analyzer not installed — run 'npm install' for accurate detection"
  else
    sync_warn="semantic-release-impact.mjs failed (exit ${_src_exit}) — using heuristic"
  fi
fi

# -----------------------------------------------------------------------------
# Fallback heuristic
# -----------------------------------------------------------------------------
if [[ "${used}" == "heuristic" ]]; then
  re='^([a-zA-Z0-9]+)(\([^)]+\))?(!)?:[[:space:]].+'
  cc_type=""
  cc_breaking="0"

  if [[ "${header}" =~ ${re} ]]; then
    cc_type="$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')"
    [[ -n "${BASH_REMATCH[3]:-}" ]] && cc_breaking="1"
  fi

  if grep -qiE '(^|\n)BREAKING[ -]CHANGE(\:|\s)' <<< "${full_msg}"; then
    cc_breaking="1"
  fi

  if [[ "${cc_breaking}" == "1" ]]; then
    impact="major"
    rule_label="heuristic"
    rule_detail="breaking change detected (! or BREAKING CHANGE)"
  elif [[ "${cc_type}" == "feat" ]]; then
    impact="minor"
    rule_label="heuristic"
    rule_detail="type=feat"
  elif [[ "${cc_type}" == "fix" || "${cc_type}" == "perf" ]]; then
    impact="patch"
    rule_label="heuristic"
    rule_detail="type=${cc_type}"
  else
    impact="none"
  fi
fi

# No release → exit quietly
if [[ "${impact}" == "none" || "${impact}" == "null" ]]; then
  exit 0
fi

# -----------------------------------------------------------------------------
# Prompt via /dev/tty (works even if pre-commit steals stdin)
# -----------------------------------------------------------------------------
if [[ -r /dev/tty && -w /dev/tty ]]; then
  exec </dev/tty >/dev/tty 2>&1

  # Styling
  if test -t 1; then
    ESC=$'\033'
    RESET="${ESC}[0m"
    BOLD="${ESC}[1m"
    DIM="${ESC}[2m"
    YELLOW="${ESC}[1;33m"
    RED="${ESC}[1;31m"
    GREEN="${ESC}[1;32m"
    CYAN="${ESC}[1;36m"
  else
    RESET="" BOLD="" DIM="" YELLOW="" RED="" GREEN="" CYAN=""
  fi

  icon="ℹ️"
  accent="${CYAN}"
  if [[ "${impact}" == "minor" ]]; then
    icon="⚠️"
    accent="${YELLOW}"
  elif [[ "${impact}" == "major" ]]; then
    icon="🚨"
    accent="${RED}"
  fi

  strict_badge=""
  if [[ "${STRICT_RELEASE_CONFIRM}" == "1" ]]; then
    strict_badge=" 🔒 ${BOLD}STRICT${RESET}"
  fi

  # Prepend a newline so the warning line prints cleanly above the border.
  _sync_warn_block=""
  if [[ -n "${sync_warn}" && "${used}" == "heuristic" ]]; then
    _sync_warn_block="${YELLOW}⚠️  Accuracy: ${sync_warn}${RESET}"$'\n'
  fi

  if [[ "${impact}" == "patch" ]]; then
    cat <<EOF
${accent}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
${accent}${BOLD}${icon}  Release-triggering commit detected${RESET}${strict_badge}

  ${BOLD}Impact:${RESET} ${CYAN}${impact}${RESET}   ${BOLD}Mode:${RESET} ${DIM}${used}${RESET}
  ${BOLD}Rule:${RESET}   ${DIM}${rule_label:-unknown}${RESET}${DIM}${rule_detail:+ — ${rule_detail}}${RESET}

  ${BOLD}Message:${RESET} ${header}

${DIM}This commit message is likely to trigger semantic-release.${RESET}
${_sync_warn_block}${accent}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
EOF
  else
    cat <<EOF
${accent}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
${accent}${BOLD}${icon}  Release-triggering commit detected${RESET}${strict_badge}

  ${BOLD}Impact:${RESET} ${CYAN}${impact}${RESET}
  ${BOLD}Mode:  ${RESET} ${DIM}${used}${RESET}
  ${BOLD}Rule:  ${RESET} ${DIM}${rule_label:-unknown}${RESET}${DIM}${rule_detail:+ — ${rule_detail}}${RESET}

  ${BOLD}Message:${RESET}
    ${header}

${DIM}This commit message is likely to trigger semantic-release.${RESET}
${_sync_warn_block}${accent}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
EOF
  fi

  read -r -p "Continue with commit? [y/N] " answer
  answer="$(printf '%s' "${answer}" | tr '[:upper:]' '[:lower:]')"

  if [[ "${answer}" == "y" || "${answer}" == "yes" ]]; then
    echo
    echo "${GREEN}${BOLD}✅ Commit confirmed. Proceeding…${RESET}"
    exit 0
  fi

  echo
  echo "${RED}${BOLD}🛑 Commit aborted by user.${RESET}"
  exit 1
fi

# -----------------------------------------------------------------------------
# No TTY
# -----------------------------------------------------------------------------
if [[ "${STRICT_RELEASE_CONFIRM}" == "1" ]]; then
  echo "❌ Release-triggering commit detected (${impact}), but no TTY available." >&2
  echo "   STRICT_RELEASE_CONFIRM=1 is set (env or local default); blocking commit." >&2
  exit 1
fi

echo "⚠️  Release-triggering commit detected (${impact}), but no TTY available."
echo "    Proceeding without confirmation."
if [[ -n "${sync_warn}" && "${used}" == "heuristic" ]]; then
  echo "    Accuracy: ${sync_warn}"
fi
exit 0
