# 🩺 Doctor (Local Environment Sanity)

Doctor is a **local-first environment sanity check** designed to catch setup issues
*before* you run Gradle, Spring Boot, or Testcontainers.

> **Important**
> Doctor does **not** replace CI.
> CI remains the only authoritative quality gate.

---

## What this is

`make doctor` answers one question:

> *“Is my machine correctly set up to run this project?”*

If the answer is **no**, it exits early with **clear, actionable instructions**
(e.g. “install Java 21” or “run `colima start`”).

This avoids confusing failures later in:

- Gradle configuration
- Spring Boot startup
- Testcontainers initialization

---

## How it’s implemented

Doctor is implemented as a standalone script:

```bash
scripts/doctor.sh
```

The naming is intentional:

- **Script:** `scripts/doctor.sh` — technical, explicit, reusable
- **Command:** `make doctor` — human-friendly entry point

The script can also be run directly.

---

## What it checks

### Required (hard failures)

These must pass for the project to work locally.

- **Java 21+**
  - `java` on `PATH`
  - Version ≥ 21
- **Gradle wrapper**
  - `./gradlew` exists
  - Executable bit set
- **Docker**
  - Docker CLI installed
  - Docker daemon reachable
  - Docker socket healthy

If any of these fail, Doctor **exits immediately**.

---

### macOS-specific (conditional)

- If **Colima** is installed:
  - It must be running
- If Colima is explicitly required:
  - (`DOCTOR_REQUIRE_COLIMA=1`)
  - Colima must be installed **and** running

This supports both Docker Desktop and Colima workflows.

---

### Best-effort / advisory checks

These checks provide **guidance**, not hard failures
(unless strict mode is enabled):

- **Node.js 20+** — required by `act` env setup and semantic-release scripts
- Docker provider detection (Desktop, Colima, Rancher, Podman)
- Docker CPU inspection
- Docker memory inspection
- Docker context mismatch detection (macOS)
- Colima resource inspection and **actionable suggestions**

When resources are low, Doctor prints **exact commands** to fix them:

```bash
colima stop
colima start --cpu 6 --memory 8
```

---

## How to run it

```bash
make doctor
```

Use Doctor:

- After cloning
- During onboarding
- When something “feels wrong”
- Before long-running checks (`make quality`)

---

## Optional configuration (advanced)

Doctor can be tuned **per invocation** via environment variables.

### `DOCTOR_STRICT`

```bash
DOCTOR_STRICT=1 make doctor
```

Treats **warnings as failures**.
Useful when you want a fully clean environment.

---

### `DOCTOR_MIN_DOCKER_MEM_GB`

```bash
DOCTOR_MIN_DOCKER_MEM_GB=6 make doctor
```

Sets the *recommended* Docker memory threshold (GiB).
Doctor will warn (or fail in strict mode) if below this value.

Defaults (without env var) are read from `.config/local-settings.json`:

```json
{ "doctor": { "minDockerMemGb": 4, "minDockerCpus": 2 } }
```

---

### `DOCTOR_MIN_DOCKER_CPUS`

```bash
DOCTOR_MIN_DOCKER_CPUS=4 make doctor
```

Sets the *recommended* Docker CPU count.
Also falls back to `doctor.minDockerCpus` in `.config/local-settings.json`.

---

### `DOCTOR_REQUIRE_COLIMA` (macOS only)

```bash
DOCTOR_REQUIRE_COLIMA=1 make doctor
```

Fails if Colima is not installed and running.
Useful for teams standardizing on Colima.

---

## CI behavior

When `CI=true` is set:

- Doctor exits immediately
- No local checks are performed

Doctor is a **local diagnostic tool**, not a CI gate.

---

## Summary

If Doctor passes, your environment is sane.
If it fails, it tells you **exactly what to fix** — early, clearly, and locally.
