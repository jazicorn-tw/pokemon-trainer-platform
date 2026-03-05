# Day-1 Onboarding Checklist

This project follows **strict but boring** conventions with explicit quality gates to ensure
repeatable builds, reliable tests, and production parity.

If you follow this checklist, you will not fight the tooling.

⏱️ **~30–45 minutes on first run** (longer if Docker or Colima needs installing).

> 🆘 Stuck at any step? See
> [`COMMON_FIRST_DAY_FAILURES.md`](./COMMON_FIRST_DAY_FAILURES.md) before
> spending time debugging.
>
> Local configuration behavior is defined in **ADR-000**.  
> `.env` is supported for local development via Spring configuration import and **never** overrides
> CI or production environment variables.

---

## Prerequisites

* Java **21**
* Docker (Docker Desktop or **Colima** on macOS)
* Git
* No global Gradle install needed
* `make` (available by default on macOS and most Linux distros)

---

## 1. Clone & enter repo

```bash
git clone <repo-url>
cd {{project-name}}
```

---

## ⚡ Fast path (experienced contributors)

If you have Java 21, Docker, and `make` ready, one command does steps 2–7:

```bash
make doctor     # verify machine prerequisites first
make bootstrap  # env-init + hooks + exec-bits + quality gate
```

Then jump to [step 5](#5-start-local-database) to start the database and
[step 9](#9-run-the-app-local-profile) to start the app.

---

## Manual steps (new to the stack or troubleshooting)

## 2. Environment setup

Create the three local config files from their examples:

```bash
cp .env.example .env           # app config (database, ports, profiles)
cp .vars.example .vars         # non-secret CI variables (act / local CI parity)
cp .secrets.example .secrets   # GitHub App credentials (optional for basic dev)
```

None of these files are committed. All three are gitignored.

### `.env` — app configuration

* Spring Boot loads `.env` automatically for **local runs** via:

  ```properties
  spring.config.import=optional:file:.env[.properties]
  ```

* **Optional** and **local-only** — OS-level environment variables always take precedence (CI / prod)
* Must use simple `KEY=value` syntax (no `export`, no shell logic)

### `.vars` — local CI variables

* Mirrors GitHub Repository Variables (`Settings → Variables`) for `act` runs
* Contains **non-secret** values only (booleans, toggles, repo name)
* Needed when running `make run-ci` or local CI simulations with `act`

📄 Details: [`docs/devops/ci/act/VARS.md`](../devops/ci/act/VARS.md)

### `.secrets` — GitHub App credentials

* Contains `GH_APP_ID` and `GH_APP_PRIVATE_KEY`
* **Not required for basic local development** — only needed for workflows that
  authenticate as the GitHub App (release CI, local `act` runs with real secrets)
* Leave the values blank if you are not running those workflows

📄 Details: [`docs/devops/ci/act/SECRETS.md`](../devops/ci/act/SECRETS.md)

---

## 3. Verify local environment (recommended)

```bash
make doctor
```

Runs a fast, **local-only environment sanity check** to confirm:

* Java 21 is available
* Docker is reachable
* Colima / Docker Desktop is correctly configured
* Your machine is safe to run Gradle and Testcontainers

If this fails, fix the reported issue *before* continuing.

📄 Details: `docs/tooling/DOCTOR.md`

Then run the full suite of project-level checks:

```bash
make check-all
```

Discovers and runs every script in `scripts/check/` — validates required env
files, executable bits, and Colima resource allocation. Exits 1 if any check
fails.

---

## 4. Ensure Docker works (macOS + Colima)

```bash
docker ps
```

If this fails on macOS:

```bash
unset DOCKER_HOST
docker context use colima
colima start
docker ps
```

> ⚠️ **Colima memory:** Gradle + Testcontainers need at least 4 GB RAM.
> Start Colima with enough resources: `colima start --cpu 4 --memory 8`

---

## 5. Start local database

```bash
docker compose up -d postgres
```

Verify:

```bash
docker compose ps
docker compose logs --tail=50 postgres
```

Postgres healthcheck must be **healthy** before proceeding.

---

## 6. Install local git hooks (recommended)

This project uses **repo-local git hooks** aligned with **ADR-000**.

```bash
make hooks
```

This installs:

* pre-commit hooks
* fast local quality checks (lint / static analysis)

Hooks provide early feedback **before code leaves your machine**, but **do not replace CI**.

See [`MAKEFILE.md`](../tooling/make/MAKEFILE.md) for details.

---

## 7. Run quality gate (source of truth)

There are **multiple ways to run checks locally**, but they are **not equivalent**.

You may run **tests only**:

```bash
./gradlew test
```

> 🐳 Tests use Testcontainers — **Docker must be running**. First run downloads a
> PostgreSQL image and takes 1–3 minutes. A hanging test almost always means
> Docker is not running or the wrong context is active.
>
> 📄 [`docs/faq/TESTCONTAINERS_EXPLAINED.md`](../faq/TESTCONTAINERS_EXPLAINED.md)

This validates behavior, but **does not** run formatting or static analysis.

For a **local approximation of CI** (assumes `make doctor` already passes), use:

```bash
make quality
```

⚠️ **Source of truth**

CI always runs:

```bash
./gradlew clean check
```

Only this command is authoritative.

Local commands exist for convenience and fast feedback — **they do not replace CI**.

---

## 8. One-command bootstrap (optional, recommended)

```bash
make bootstrap
```

Installs hooks and runs the full local quality gate.

---

## 9. Run the app (local profile)

```bash
./gradlew bootRun -Dspring.profiles.active=local
```

Endpoints:

* App: <http://localhost:8080>
* Health: <http://localhost:8080/actuator/health>

---

## 10. Optional: Run full stack via Docker Compose

```bash
docker compose up --build app
```

---

## What *Not* To Do

* ❌ Do not install global Gradle
* ❌ Do not hardcode secrets
* ❌ Do not commit `.env`
* ❌ Do not bypass failing tests
* ❌ Do not bypass quality gates for PRs

---

If Day-1 works, everything else will too.
