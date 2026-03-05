#!/usr/bin/env bash
set -euo pipefail

# pre-add.sh — lint, format, and exec-bit check before files are staged
#
# Called by the shell-level git() wrapper (not a native Git hook).
# .md files              → make lint-docs  (markdownlint-cli2, check-only, aborts on error)
# .java/.gradle          → make format     (spotlessApply, auto-fixes in place)
# scripts/ / .githooks/  → make exec-bits  (chmod +x + stage, auto-fixes in place)
#
# Configuration hierarchy (highest → lowest priority):
#   1. SKIP_PRE_ADD_LINT=1 git add …        env var — skip this invocation
#   2. git config --local hooks.pre-add-lint developer override (not committed)
#      make pre-add-lint-on / make pre-add-lint-off
#   3. .config/local-settings.json           repo-committed defaults
#      .git.preAddLint.enabled  (bool, default true)
#      .git.preAddLint.spotless (bool, default true)
#   4. Hard defaults: enabled=true, spotless=true
#
# One-off env overrides:
#   SKIP_PRE_ADD_LINT=1    git add …  # skip everything this invocation
#   SKIP_SPOTLESS_ON_ADD=1 git add …  # skip Spotless only (avoids Gradle startup)
#
# See docs/tooling/PRE_ADD_LINT.md for shell function setup.

REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck source=scripts/lib/shell-utils.sh
source "$REPO_ROOT/scripts/lib/shell-utils.sh"

# ── 1. Env var: skip everything ───────────────────────────────────────────────
if [[ "${SKIP_PRE_ADD_LINT:-0}" == "1" ]]; then
  exit 0
fi

# ── 2. Read local-settings.json defaults ──────────────────────────────────────
ls_enabled="true"
ls_spotless="true"
ls_file=""
if [[ -f "$REPO_ROOT/.config/local-settings.json" ]]; then
  ls_file="$REPO_ROOT/.config/local-settings.json"
elif [[ -f "$REPO_ROOT/local-settings.json" ]]; then
  ls_file="$REPO_ROOT/local-settings.json"
fi
if [[ -n "$ls_file" ]] && command -v jq >/dev/null 2>&1; then
  val="$(jq -r '.git.preAddLint.enabled // empty' "$ls_file" 2>/dev/null || true)"
  [[ "$val" == "false" ]] && ls_enabled="false"
  val="$(jq -r '.git.preAddLint.spotless // empty' "$ls_file" 2>/dev/null || true)"
  [[ "$val" == "false" ]] && ls_spotless="false"
fi

# ── 3. git config --local: developer override (beats local-settings.json) ─────
gc_val="$(git config --bool --local hooks.pre-add-lint 2>/dev/null || echo "")"
if [[ "$gc_val" == "false" ]]; then
  exit 0
elif [[ "$gc_val" == "true" ]]; then
  ls_enabled="true"
fi

# ── 4. Apply enabled default ───────────────────────────────────────────────────
if [[ "$ls_enabled" == "false" ]]; then
  exit 0
fi

# ── Collect files from git add arguments ──────────────────────────────────────
args=("$@")
all_mode=false

for arg in "${args[@]:-}"; do
  case "${arg:-}" in
    -A|--all|.) all_mode=true ;;
    -u|--update) all_mode=true ;;
  esac
done

md_files=()
java_files=()
script_files=()

collect_file() {
  local f="$1"
  [[ -f "$REPO_ROOT/$f" || -f "$f" ]] || return 0
  case "$f" in
    *.md)                          md_files+=("$f") ;;
    *.java|*.gradle)               java_files+=("$f") ;;
    scripts/*|.githooks/*|*.sh|*.bash|*.mjs) script_files+=("$f") ;;
  esac
}

if [[ "$all_mode" == "true" ]]; then
  while IFS= read -r f; do
    collect_file "$f"
  done < <(git -C "$REPO_ROOT" ls-files --modified --others --exclude-standard)
else
  for arg in "${args[@]:-}"; do
    [[ "${arg:-}" == -* ]] && continue
    collect_file "$arg"
  done
fi

if [[ ${#md_files[@]} -eq 0 && ${#java_files[@]} -eq 0 && ${#script_files[@]} -eq 0 ]]; then
  exit 0
fi

failed=0
cd "$REPO_ROOT"

# ── Markdown lint (make lint-docs) ────────────────────────────────────────────
# Runs markdownlint-cli2 on all .md files (not just staged ones — fast enough).
if [[ ${#md_files[@]} -gt 0 ]]; then
  log "pre-add: 📝 lint-docs…"
  if ! make lint-docs; then
    warn "pre-add: ❌ markdownlint failed — fix violations then re-run git add"
    failed=1
  fi
fi

# ── Auto-format Java/Gradle (make format) ─────────────────────────────────────
# Runs spotlessApply — auto-fixes formatting in place so git add can proceed.
# Adds ~10–15 s (Gradle startup). Disable via local-settings.json or env var.
if [[ ${#java_files[@]} -gt 0 ]]; then
  if [[ "${SKIP_SPOTLESS_ON_ADD:-0}" == "1" || "$ls_spotless" == "false" ]]; then
    log "pre-add: Spotless skipped (SKIP_SPOTLESS_ON_ADD or local-settings.json)."
  else
    log "pre-add: ✨ format (spotlessApply — auto-fixing)…"
    if ! make format; then
      warn "pre-add: ❌ format failed — check errors above"
      failed=1
    fi
  fi
fi

# ── Executable bits (make exec-bits) ──────────────────────────────────────────
# Auto-fixes chmod +x and stages the mode change (strict: 2, autoStage: true).
if [[ ${#script_files[@]} -gt 0 ]]; then
  log "pre-add: 🔧 exec-bits (${#script_files[@]} script file(s))…"
  if ! make exec-bits; then
    warn "pre-add: ❌ exec-bits failed — check errors above"
    failed=1
  fi
fi

exit $failed
