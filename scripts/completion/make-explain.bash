# Bash completion for: make explain <target>
# Usage:
#   source scripts/completion/make-explain.bash
#
# Optional (recommended):
#   Add to ~/.bashrc or ~/.zshrc (if using bash completion in zsh):
#     source /path/to/repo/scripts/completion/make-explain.bash

_make_explain_complete() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Only complete the 3rd word: make explain <target>
  if [[ "${COMP_WORDS[1]}" == "explain" && $COMP_CWORD -eq 2 ]]; then
    local opts="doctor check-env env-init env-init-force env-help bootstrap verify quality pre-commit run-ci"
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi

  return 0
}

complete -F _make_explain_complete make
