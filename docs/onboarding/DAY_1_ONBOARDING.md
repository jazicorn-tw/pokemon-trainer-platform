# Day-1 Onboarding Checklist

This project follows **strict but boring** conventions with explicit quality gates to ensure repeatable builds, reliable tests, and production parity.

If you follow this checklist, you will not fight the tooling.

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

---

## 5. Start local database

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

## 6. Install local git hooks (recommended)

This project uses **repo-local git hooks** aligned with **ADR-000**.

```bash
make hooks
```

This installs:

* pre-commit hooks
* fast local quality checks (lint / static analysis)

Hooks provide early feedback **before code leaves your machine**, but **do not replace CI**.

See [MAKEFILE](./MAKEFILE.md) for details.

---

## 7. Run quality gate (source of truth)

There are **multiple ways to run checks locally**, but they are **not equivalent**.

You may run **tests only**:

```bash
./gradlew test
```

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
