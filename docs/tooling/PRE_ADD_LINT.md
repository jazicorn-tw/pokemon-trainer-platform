# Pre-add Lint Check

Runs **markdownlint** (for `.md` files) and **Spotless** (for `.java` /
`.gradle` files) before `git add` stages them. If either check fails, the
add is aborted and nothing is staged.

Git has no native `pre-add` hook, so this is implemented as a shell function
that wraps `git add`.

---

## One-time shell setup

Add the following function to your `~/.zshrc` or `~/.bashrc`, then
`source ~/.zshrc` (or restart your terminal):

```bash
# {{project-name}}: pre-add lint wrapper
# Runs scripts/git/pre-add.sh before staging files in any repo that has it.
git() {
  if [[ "$1" == "add" ]] && command git rev-parse --git-dir &>/dev/null; then
    local root script
    root=$(command git rev-parse --show-toplevel 2>/dev/null)
    script="$root/scripts/git/pre-add.sh"
    if [[ -x "$script" ]]; then
      "$script" "${@:2}" || return 1
    fi
  fi
  command git "$@"
}
```

The wrapper is project-aware: it only activates when `scripts/git/pre-add.sh`
exists in the repo root. Other repos are unaffected.

---

## Configuration hierarchy

Settings are resolved in this order (highest priority first):

| Priority | Mechanism | Scope |
| -------- | --------- | ----- |
| 1 | `SKIP_PRE_ADD_LINT=1` env var | This invocation only |
| 2 | `git config --local hooks.pre-add-lint` | Your machine, not committed |
| 3 | `.config/local-settings.json` `.git.preAddLint.*` | Committed project defaults |
| 4 | Hard defaults (`enabled=true`, `spotless=true`) | Fallback |

---

## Enable / disable

**Per-developer override** (stored in `.git/config`, never committed):

```bash
make pre-add-lint-on    # override to enabled
make pre-add-lint-off   # override to disabled
```

**Project default** (committed in `.config/local-settings.json`):

```json
{
  "git": {
    "preAddLint": {
      "enabled": true,
      "spotless": true
    }
  }
}
```

Set `"enabled": false` to turn off pre-add lint for everyone on the team by
default. Set `"spotless": false` to keep markdownlint but skip the slower
Gradle check for all developers.

---

## One-off overrides (env vars)

| Command | Effect |
| ------- | ------ |
| `SKIP_PRE_ADD_LINT=1 git add <file>` | Skip all checks this invocation |
| `SKIP_SPOTLESS_ON_ADD=1 git add <file>` | Skip Spotless only (no Gradle startup) |

---

## What runs and when

| Files being added | Check | Tool |
| ----------------- | ----- | ---- |
| `*.md` | markdownlint | `markdownlint-cli2` (fast, per-file) |
| `*.java` / `*.gradle` | Spotless formatting | `./gradlew spotlessCheck` |

> **Spotless note:** Gradle startup adds roughly 10–15 seconds per `git add`
> of a Java file. Use `SKIP_SPOTLESS_ON_ADD=1` when you want a fast stage and
> are happy for the pre-commit hook to catch formatting issues at commit time.

---

## How it fits with the pre-commit hook

The pre-commit hook (`.githooks/pre-commit`) already runs `spotlessCheck` and
static analysis on staged Java files. Pre-add lint catches violations one step
earlier — before the file is even staged — giving faster feedback on markdown
files in particular.

| Timing | Hook | Checks |
| ------ | ---- | ------ |
| Before `git add` | Shell wrapper → `scripts/git/pre-add.sh` | markdownlint, Spotless |
| Before `git commit` | `.githooks/pre-commit` | Spotless, Checkstyle, PMD, SpotBugs |

---

## Troubleshooting

### `scripts/git/pre-add.sh: command not found`

The shell function resolved the wrong repo root. Ensure you are inside the
`{{project-name}}` directory when running `git add`.

### markdownlint-cli2 not found

Run `npm ci` to install Node dependencies.

### Gradle not found / slow

Colima must be running for Testcontainers tests, but Spotless does not need
Docker. If Gradle itself is slow, use `SKIP_SPOTLESS_ON_ADD=1` and let the
pre-commit hook handle formatting.

### Temporarily bypass everything

```bash
SKIP_PRE_ADD_LINT=1 git add .
```
