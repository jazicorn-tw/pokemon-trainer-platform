<!-- markdownlint-disable MD033 -->
# 🎒 Pokémon Trainer Inventory Service

*A Spring Boot 4 API for trainers to manage their Pokémon, trade with others, and participate in a marketplace — powered by PokeAPI and built with Test-Driven Development (TDD).*

<p align="center">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java">
  <img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot">
  <img src="https://img.shields.io/badge/docker-ready-blue" alt="Docker">
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml/badge.svg" alt="Build Image"></a>
</p>

---

## 🚀 Overview

The **Pokémon Trainer Inventory Service** is a backend REST API that allows trainers to:

* Register trainer profiles
* Add Pokémon to their inventory
* Validate Pokémon species via **PokeAPI**
* Trade Pokémon with other trainers
* List Pokémon for sale
* Buy Pokémon from other trainers

The project follows **strict Test-Driven Development (TDD)** and enforces
**foundational quality gates** to maintain production realism from day one.

---

## 🧩 Tech Stack (High Level)

* **Java 21**
* **Spring Boot 4**
* **PostgreSQL**
* **JPA / Hibernate**
* **Spring Security + JWT (phased)**
* **Testcontainers**
* **Flyway**
* **SpringDoc OpenAPI**
* **MapStruct**

> Detailed dependency rationale lives in **ARCHITECTURE.md**.

---

## 🧭 Feature Roadmap

| Phase | Focus                                   |
| ----- | --------------------------------------- |
| 0     | Project skeleton, `/ping`, test harness |
| 1     | Trainers & inventory                    |
| 2     | PokeAPI integration                     |
| 3     | Trades                                  |
| 4     | Marketplace                             |
| 5     | Integration tests                       |
| 6     | Security skeleton                       |
| 7     | JWT authentication                      |
| 8     | Developer experience improvements       |

---

## 🩺 Health & Observability

| Endpoint                     | Purpose         |
| ---------------------------- | --------------- |
| `/ping`                      | Bootstrap check |
| `/actuator/health`           | Overall health  |
| `/actuator/health/liveness`  | Liveness        |
| `/actuator/health/readiness` | Readiness       |

---

## ⚙️ Configuration

Profiles:

* `local`
* `test`
* `prod`

Local `.env` loading is supported:

```properties
spring.config.import=optional:file:.env[.properties]
```

OS / CI environment variables always take precedence.

---

## 🧪 Running Tests

Fast local tests (no static analysis):

```bash
make test
# or
./gradlew test
```

Integration tests only:

```bash
./gradlew test --tests "*IT"
```

---

## 🚦 Quality Gates (ADR-000)

This project enforces **foundational quality gates** as a **non-negotiable baseline**.

Quality gates are treated as an **architectural decision**, not a tooling preference,
and are defined in **ADR-000**.

### What must pass

All changes are expected to pass the full quality gate:

```bash
./gradlew clean check
```

This includes:

* ✅ **Automated tests**
  * Unit tests
  * Integration tests (Testcontainers / PostgreSQL)
* ✅ **Formatting**
  * Spotless (Java & Gradle)
* ✅ **Static analysis**
  * Checkstyle
  * PMD
  * SpotBugs
* ✅ **Build correctness**
  * Compilation
  * Dependency resolution

The **exact same command** is enforced locally and in CI to guarantee parity.

---

## 🧰 Makefile commands (authoritative)

These are the intended local entry points for contributors:

```bash
make hooks     # install git hooks
make test      # tests only (fast feedback)
make quality   # format + full local quality gate (matches CI intent)
make test-ci   # CI-equivalent gate with CI env + test profile
make bootstrap # hooks + quality (recommended after clone)
```

### ⚠️ Important distinction

* `make test` **will NOT** catch formatting or static-analysis failures.
* To prevent GitHub Actions failures, run **`make quality` or `make test-ci`** before pushing.

---

## 🔁 CI parity locally (recommended)

To run the **same gate CI enforces**, including environment expectations:

```bash
make test-ci
```

This runs:

```bash
CI=true SPRING_PROFILES_ACTIVE=test ./gradlew clean check
```

If this passes locally, CI should not fail remotely for code-quality reasons.

---

## 📊 Reports (how to debug failures locally)

After `make quality` or `make test-ci`, Gradle generates HTML reports you can open in a browser:

```text
build/reports/tests/test/index.html        # Test results
build/reports/checkstyle/main.html         # Checkstyle
build/reports/pmd/main.html                # PMD
build/reports/spotbugs/main.html           # SpotBugs
build/reports/spotless/                    # Spotless
```

These reports provide the file/line-level details behind CI failures.

---

### What runs when?

| Stage | What runs | Purpose |
| ----- | --------- | ------- |
| Local (fast) | `make test` / `./gradlew test` | Quick feedback on tests |
| Local (parity) | `make test-ci` / `CI=true … clean check` | Prevent remote CI surprises |
| Pre-commit | Spotless + targeted analysis | Fast feedback, prevent style-only CI failures |
| CI | `./gradlew clean check` | Authoritative gate for merge |

If it doesn’t pass CI, it doesn’t ship.

---

### Local enforcement (pre-commit)

A **Git pre-commit hook** runs before code leaves your machine:

* Auto-formats staged files (Spotless)
* Runs static analysis on affected sources
* Prevents avoidable CI failures

Pre-commit behavior and escape hatches are documented in:

* `docs/onboarding/PRECOMMIT.md`
* `docs/onboarding/ONBOARDING.md`

---

### CI enforcement (authoritative)

CI is the **source of truth**:

* Java 21
* Docker / Colima-safe Testcontainers
* Full `./gradlew clean check`
* Merge-blocking on failure

Local success is expected; CI success is required.

---

### Architectural rationale

Quality gates are established **before feature development** to ensure:

* Consistent style from day one
* Early detection of correctness and design issues
* Predictable onboarding for contributors
* Production-realistic development practices

This decision is formally captured in:

* `docs/adr/ADR-000-linting.md`
* `docs/onboarding/LINTING.md`

---

## 🐳 Docker

👉 See **[DOCKER.md](./docs/onboarding/SETUP_DOCKER.md)**

---

## 🧠 Architecture & Design

For system design, trade-offs, and rationale, see:

👉 See **[ARCHITECTURE.md](./ARCHITECTURE.md)**

---

## 🤝 Contributing

Before opening a pull request, please read **CONTRIBUTING.md**.

Contributors are expected to:

* Respect **ADR-000** (quality gates come first)
* Keep PRs phase-scoped and reviewable
* Update or add ADRs when decisions change architecture or quality policy
