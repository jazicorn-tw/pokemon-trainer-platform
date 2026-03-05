# 🔰 Phase 0.3 — Quality Gates, Make System & Local Developer Experience

> Part of [Phase 0](PHASE_0.md). Covers the local developer toolchain: quality gates,
> the Make system, scripts, and local environment tooling.

---

## ✅ Purpose

Contributors should be able to verify correctness, run CI locally, and onboard
without manual instructions. Phase 0.3 establishes the full local DX stack:

* A single authoritative quality gate (`make quality`)
* A modular Make system with role-based entry points
* `scripts/doctor.sh` for pre-flight environment validation
* Pre-commit hooks enforcing quality locally before CI sees commits
* `act` support for running GitHub Actions workflows locally

---

## 🔒 Quality Gates

The authoritative quality gate is:

```bash
./gradlew clean check
# or equivalently:
make quality
```

Both run identical checks. CI and local environments are the same gate (ADR-000).

| Tool | What it checks |
| ---- | -------------- |
| **Spotless** | Code formatting (Google Java Format) — fails on any diff |
| **Checkstyle** | Style rules (method names, Javadoc placement, structure) |
| **PMD** | Static analysis (complexity, test assertions, log guarding) |
| **markdownlint** | All `*.md` files in the repo (120-char line limit, heading rules) |

---

## 🪝 Pre-commit Hooks

Hooks live in `.githooks/` and are installed via:

```bash
make hooks
# or
./scripts/bootstrap/install-hooks.sh
```

| Hook | Enforces |
| ---- | -------- |
| `commit-msg` | Conventional Commits format (via commitizen); prompts to reformat if invalid |
| `pre-commit` | Executable bits on all scripts in `scripts/` and `.githooks/` |

Write commits using commitizen for automatic format compliance:

```bash
cz commit
# or the standard git command (hook validates after)
git commit
```

---

## ⚙️ Make System

The `Makefile` delegates to modular `.mk` files in `make/` (decade-based naming):

| File | Responsibility |
| ---- | -------------- |
| `10-env.mk` | Variable declarations and shared constants |
| `20-help.mk` | `make help` role-based output |
| `30-bootstrap.mk` | First-time contributor setup |
| `40-preconditions.mk` | Environment checks (`check-env`, `check-all`) |
| `50-library.mk` | Shared macros, `doctor`, `exec-bits`, `hooks` |
| `60-build.mk` | Gradle build and test targets |
| `70-runtime.mk` | Database targets (`db-flyway-clean`, `db-seed`) |
| `71-runtime-lifecycle.mk` | `env-up`, `env-down`, `env-check`, `env-status` |
| `80-simulation.mk` | `act` local CI simulation targets |
| `90-release.mk` | `release-dry-run` |

**Key entry points:**

```bash
make help            # role-based help menu
make bootstrap       # first-time setup
make doctor          # pre-flight environment check
make quality         # authoritative quality gate
make check-all       # run all scripts/check/ scripts
make env-up          # start Colima + Docker Compose
make env-down        # stop Colima + Docker Compose
make env-check       # alias for check-all
make release-dry-run # preview next semantic-release version
```

---

## 🩺 Developer Scripts

Scripts are organised into subfolders under `scripts/`:

| Folder | Scripts |
| ------ | ------- |
| `scripts/bootstrap/` | `bootstrap-macos.sh`, `bootstrap-linux.sh`, `bootstrap-common.sh`, `install-hooks.sh` |
| `scripts/check/` | `check-all.sh`, `check-required-files.sh`, `check-executable-bits.sh`, `check-colima.sh`, `check-required-files-act.sh` |
| `scripts/db/` | `clean-db-flyway.sh`, `seed-db.sh` |
| `scripts/dev/` | `start-dev.sh`, `stop-dev.sh` |
| `scripts/lib/` | `shell-utils.sh`, `colima-utils.sh`, `doctor-check-utils.sh`, `validators.sh` |
| `scripts/` | `doctor.sh` |

### `scripts/doctor.sh`

Master pre-flight check. Validates the full local environment:

* Java 21+
* Node.js 20+ (for semantic-release)
* Gradle wrapper present and executable
* Docker CLI + daemon reachable
* Docker Compose plugin
* Docker context (colima vs docker-desktop vs docker-engine)
* Colima running and resource allocation

```bash
make doctor           # human-readable output
make doctor-json      # machine-readable JSON
make doctor-json-strict  # treat warnings as failures
```

### `scripts/check/check-all.sh`

Discovers and runs every script in `scripts/check/` (except itself), reports
per-script pass/fail, exits 1 if any check fails:

```bash
make check-all
# or
./scripts/check/check-all.sh
```

---

## 🧑‍💻 Local Developer Experience

### act — Run CI Locally

`act` lets you run GitHub Actions workflows locally before pushing:

```bash
make act-fast       # run ci-fast locally
make act-quality    # run ci-quality locally
make act-test       # run ci-test locally
```

Requires:

* `~/.actrc` (home directory)
* `.vars` (project root — mirrors GitHub repo variables)
* `.secrets` (project root — GitHub App auth)

See [`docs/tooling/ACTRC.md`](../tooling/ACTRC.md) for full setup.

### Colima (macOS Docker Runtime)

```bash
colima start --cpu 6 --memory 8
docker context use colima
make doctor   # verify everything is green
```

`scripts/check/check-colima.sh` validates Colima resource allocation and can
auto-restart Colima if resources are insufficient. Required minimums
(**8 GiB RAM, 6 CPUs**) are configured in `.config/local-settings.json`
under `colima.required` and apply automatically — no manual flag changes needed.

### `.config/local-settings.json` (committed)

Repo-committed defaults for local tooling behaviour, read by scripts via
`jq` or Python before falling back to hard-coded values. Covers Colima
resource requirements, doctor thresholds, local DB defaults, and the
Postgres image tag.

```bash
make local-settings   # print all effective resolved values
```

📄 Full key reference: [`LOCAL_ENVIRONMENT.md`](../environment/local/LOCAL_ENVIRONMENT.md)

---

## 🔜 Next

← Back to [Phase 0.2 — CI/CD & Release](PHASE_0_2.md) |
Back to [Phase 0 overview](PHASE_0.md) |
Next: See [`PHASES.md`](PHASES.md) for Phase 1 and beyond
