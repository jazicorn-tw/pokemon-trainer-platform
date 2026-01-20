# Day-1 Onboarding Checklist

This project follows **strict but boring** conventions to ensure repeatable builds, reliable tests, and production parity.

If you follow this checklist, you will not fight the tooling.

> Local configuration behavior is defined in **ADR-004**: `.env` is supported
> for local development via Spring configuration import and **never** overrides
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
cd pokemon-inventory-system
```

---

## 2. Environment setup (.env)

```bash
cp .env.example .env
```

### How `.env` works in this project

* Spring Boot loads `.env` automatically for **local runs** via:

  ```properties
  spring.config.import=optional:file:.env[.properties]
  ```

* `.env` is **optional** and **local-only**

* OS-level environment variables **always take precedence** (CI / prod)

⚠️ `.env` must use simple `KEY=value` syntax (no `export`, no shell logic).

Do **not** commit `.env`.

---

## 3. Ensure Docker works (macOS + Colima)

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

---

## 4. Start local database

```bash
docker compose up -d postgres
```

Verify:

```bash
docker compose ps
docker logs -n 50 pokemon_inventory_postgres
```

Postgres healthcheck must be **healthy** before proceeding.

---

## 5. Install local git hooks (recommended)

This project uses **repo-local git hooks** aligned with **ADR-000**.

```bash
make hooks
```

This installs:

* pre-commit hooks
* fast local quality checks (lint / static analysis)

Hooks provide early feedback but **do not replace CI**.

See [MAKEFILE](./MAKEFILE.md) for details.

---

## 6. Run quality gate (source of truth)

There are **multiple ways to run checks locally**, but they are **not equivalent**.

You may run **tests only**:

```bash
./gradlew test
```

This validates behavior, but **does not** run formatting or static analysis.

For a **local approximation of CI**, use the ergonomic wrapper:

```bash
make quality
```

This runs formatting, static analysis, and tests, and is the recommended Day‑1 command.

⚠️ **Source of truth**

CI always runs:

```bash
./gradlew clean check
```

Only this command is authoritative.
Local commands exist for convenience and fast feedback — **they do not replace CI**.

✅ Expected result in CI:

* Build succeeds
* All tests pass
* No formatting violations
* No static-analysis violations
* No Docker / Testcontainers errors

If CI fails, local success does not matter — fix the failure before proceeding.

---

## 7. One-command bootstrap (optional, recommended)

```bash
make bootstrap
```

This installs hooks and runs the full local quality gate.

---

## 8. Run the app (local profile)

```bash
./gradlew bootRun -D spring.profiles.active=local
```

Endpoints:

* App: [http://localhost:8080](http://localhost:8080)
* Health: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)

---

## 9. Optional: Run full stack via Docker Compose

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

If Day‑1 works, everything else will too.
