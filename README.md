<!-- markdownlint-disable MD033 -->

# 🎒 Pokémon Trainer Inventory Service

*A Spring Boot 4 REST API for managing Pokémon inventories, trades, and a marketplace — built with strict Test‑Driven Development (TDD) and CI‑first quality gates.*

<p align="center">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java">
  <img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot">
  <img src="https://img.shields.io/badge/docker-ready-blue" alt="Docker">
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml/badge.svg" alt="Build Image"></a>
</p>

---

## 🚀 Overview

The **Pokémon Trainer Inventory Service** is a backend API that allows trainers to:

* Manage trainer profiles
* Add and validate Pokémon (via **PokeAPI**)
* Trade Pokémon with other trainers
* Buy and sell Pokémon in a marketplace

The project enforces **production‑realistic constraints from day one**:

* Real PostgreSQL (no H2)
* Testcontainers‑backed integration tests
* Identical local and CI quality gates

---

## 🧩 Tech Stack

* **Java 21**
* **Spring Boot 4**
* **PostgreSQL + Flyway**
* **JPA / Hibernate**
* **Spring Security + JWT (phased)**
* **Testcontainers**
* **SpringDoc OpenAPI**
* **MapStruct**

> Dependency and design rationale live in **ARCHITECTURE.md**.

---

## 🧭 Feature Roadmap

| Phase | Focus                                   |
| ----: | --------------------------------------- |
|     0 | Project skeleton, `/ping`, test harness |
|     1 | Trainers & inventory                    |
|     2 | PokeAPI integration                     |
|     3 | Trades                                  |
|     4 | Marketplace                             |
|     5 | Integration hardening                   |
|     6 | Security skeleton                       |
|     7 | JWT authentication                      |
|     8 | Developer‑experience improvements       |

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

Supported profiles:

* `local`
* `test`
* `prod`

Local `.env` loading is supported:

```properties
spring.config.import=optional:file:.env[.properties]
```

Environment variables (OS / CI) always take precedence.

---

## 🧪 Testing

Fast feedback (tests only):

```bash
make test
# or
./gradlew test
```

Run CI‑equivalent quality gate locally:

```bash
make test-ci
```

This executes:

```bash
CI=true SPRING_PROFILES_ACTIVE=test ./gradlew clean check
```

If this passes locally, CI should not fail remotely for code‑quality reasons.

---

## 🚦 Quality Gates (ADR‑000)

Quality gates are a **non‑negotiable architectural decision**, defined in **ADR‑000**.

All changes are expected to pass:

```bash
./gradlew clean check
```

This includes:

* Automated tests (unit + integration)
* Formatting (Spotless)
* Static analysis (Checkstyle, PMD, SpotBugs)
* Build correctness

The **same command** is enforced locally and in CI to guarantee parity.

---

## 🧰 Makefile Commands (Authoritative)

```bash
make hooks     # install git hooks
make test      # tests only (fast feedback)
make quality   # format + full quality gate
make test-ci   # CI‑equivalent gate
make bootstrap # hooks + quality (recommended after clone)
```

⚠️ `make test` does **not** catch formatting or static‑analysis failures.

Run `make quality` or `make test-ci` before pushing to avoid CI failures.

---

## 📊 Debugging Failures

After `make quality` or `make test-ci`, Gradle generates HTML reports:

```text
build/reports/tests/test/index.html
build/reports/checkstyle/main.html
build/reports/pmd/main.html
build/reports/spotbugs/main.html
build/reports/spotless/
```

---

## 🐳 Docker

👉 See **docs/onboarding/SETUP_DOCKER.md**

---

## 🧠 Architecture

System design, trade‑offs, and ADRs:

👉 **ARCHITECTURE.md**

---

## 🤝 Contributing

Before opening a PR:

* Read **CONTRIBUTING.md**
* Respect **ADR‑000** (quality gates first)
* Keep PRs phase‑scoped
* Add or update ADRs when architectural decisions change
