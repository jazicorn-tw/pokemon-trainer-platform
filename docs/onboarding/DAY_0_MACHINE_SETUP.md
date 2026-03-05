# Day-0 / Machine Setup

This is the **pre-clone checklist** — tools and shell configuration to put in
place before you run a single project command.

Day-1 assumes everything here is done. If `make doctor` fails, come back here first.

---

## 1. Required tools

| Tool | Required version | Check |
| ---- | ---------------- | ----- |
| Java | 21 | `java -version` |
| Git | any recent | `git --version` |
| Docker | Desktop or Colima | `docker ps` |
| Node.js | 20+ | `node --version` |
| make | any | `make --version` |
| jq | any | `jq --version` |

### Installing missing tools (macOS)

```bash
brew install openjdk@21 git node jq make
```

For Docker, use either **Docker Desktop** or **Colima** (recommended on Apple Silicon):

```bash
brew install colima docker
colima start --cpu 6 --memory 8
```

> Gradle + Testcontainers require at least **8 GiB RAM and 6 CPUs**. These are
> the configured defaults in `.config/local-settings.json` (`colima.required`).
> Starting with lower values will trigger an auto-restart by `make bootstrap`.

---

## 2. Shell setup — pre-add lint wrapper

This project includes an optional shell wrapper that runs lint and formatting
checks before `git add` stages files. Git has no native pre-add hook, so it
requires a one-time shell function in your profile.

Add the following to your `~/.zshrc` (or `~/.bashrc`):

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

Then reload your shell:

```bash
source ~/.zshrc
```

> The wrapper is **project-aware** — it only activates in repos that have
> `scripts/git/pre-add.sh`. Other repos are unaffected.
>
> Skip this step if you prefer to run `./gradlew checkstyleMain pmdMain spotbugsMain-docs`, `make format`, and
> `make exec-bits` manually before staging.

📄 Full details: [`docs/tooling/PRE_ADD_LINT.md`](../tooling/PRE_ADD_LINT.md)

---

## 3. Verify

Once tools are installed and your shell is reloaded:

```bash
java -version   # → openjdk 21.x
node --version  # → v20.x or higher
docker ps       # → no error (Docker is reachable)
jq --version    # → jq-1.x
```

After cloning the repo, run:

```bash
make doctor     # verify machine prerequisites
make bootstrap  # install hooks, fix exec bits, run quality gate
```

`make doctor` fails fast with actionable errors. Fix anything it reports before
running `make bootstrap`.

> `make bootstrap` is safe to re-run at any time — it only installs or fixes
> what is missing.

📄 Details:

- [`docs/tooling/DOCTOR.md`](../tooling/DOCTOR.md)
- [`docs/tooling/BOOTSTRAP.md`](../tooling/BOOTSTRAP.md)

---

## What's next

Once `make doctor` and `make bootstrap` both pass, continue to:

👉 [`DAY_1_ONBOARDING.md`](./DAY_1_ONBOARDING.md) — first run, quality gate, and app startup
