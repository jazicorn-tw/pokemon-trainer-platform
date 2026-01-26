# 🧰 Makefile Commands Overview

This project uses a small set of **simple, memorable Makefile commands** to standardize local development and provide **fast feedback aligned with CI**, as defined in **ADR-000**.

Formatting, linting, static analysis, and tests together form a **single quality gate**.
CI is the **authoritative enforcer** of that gate.

---

## ✅ What this gives you

### Simple, memorable commands

| Command          | Purpose                        |
| ---------------- | ------------------------------ |
| `make help`      | List available targets         |
| `make hooks`     | Install repo-local git hooks   |
| `make doctor`    | Environment sanity (local)     |
| `make lint`      | Static analysis                |
| `make test`      | Unit tests                     |
| `make quality`   | Matches CI intent              |
| `make verify`    | “Am I good to push?”           |
| `make bootstrap` | First-time setup               |
| `make test-ci`   | CI-parity run (no auto-format) |

---

## 🔍 What each command actually runs

### `make help`

Prints a quick list of the most common targets.

---

### `make hooks`

Sets up local safeguards.

- Installs repo-local git hooks (`core.hooksPath = .githooks`)
- Ensures hook files are executable
- Ensures `scripts/*.sh` are executable (prevents `Permission denied` when running `make doctor/quality`)

Run once after cloning.

---

### `make doctor`

Runs **local environment sanity checks** (Java 21, Gradle wrapper, Docker/Colima, memory, socket health).

- Fails fast if infrastructure is misconfigured
- Never blocks CI (doctor should exit early when `CI=true`)
- Keeps errors actionable (tells you what to run next)
- Uses `bash ./scripts/doctor.sh` so you don’t get blocked by a missing executable bit
- Also runs `make exec-bits` first (warns if tracked scripts lost the executable bit in git)

See: [`PRECHECK.md`](./PRECHECK.md)

---

### `make exec-bits`

Checks that tracked scripts are **executable in Git** (mode `100755`), so teammates/CI don’t hit `Permission denied`.

- Warns locally by default
- In CI, set `STRICT=1` to fail fast

If `scripts/check-executable-bits.sh` doesn’t exist yet, this target prints a skip message.

---

### `make quality` (full local quality gate)

Runs a **local approximation of the CI quality gate**, with developer-friendly behavior:

1. **Environment sanity**
   - `make doctor` → `bash ./scripts/doctor.sh`

2. **Formatting (local convenience)**
   - `./gradlew spotlessApply`
   - Auto-formats code to avoid format-only CI failures
   - Clears Gradle configuration cache after formatting to avoid cache-related surprises

3. **Verification, linting & static analysis**
   - `./gradlew clean check`
   - Includes:
     - Spotless (format verification)
     - Checkstyle
     - PMD
     - SpotBugs
     - Tests

⚠️ **Source of truth**

CI always runs:

```bash
./gradlew clean check
```

CI does **not** auto-format and is the only authoritative quality gate.

---

### `make verify`

Runs **everything a developer should check before pushing**:

1. Environment sanity (`make doctor`)
2. Static analysis (`make lint`)
3. Unit tests (`make test`)

This is a **developer-experience umbrella command**, not a CI replacement.

---

### `make test-ci`

Runs the CI-style gate locally (no auto-format), useful for reproducing CI failures:

```bash
CI=true SPRING_PROFILES_ACTIVE=test ./gradlew clean check
```

---

## 📌 Recommended usage

- Run `make hooks` once after cloning
- Run `make quality` before pushing any change
- Use `make test` during day-to-day development
- Use `make verify` when you want confidence before opening a PR

For first-time setup, prefer:

```bash
make bootstrap
```

This installs hooks **and** verifies the full local quality gate passes on your machine.
