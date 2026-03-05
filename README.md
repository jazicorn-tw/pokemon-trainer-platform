<!-- markdownlint-disable MD033 -->

<h1 align="center">
  {{project-name}}
</h1>

<p align="center">
  <em>
    A production-grade Spring Boot 4 + Gradle backend API template —
    CI-first quality gates, TDD from day one, disciplined developer experience.
  </em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java 21">
  <img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot 4">
  <img src="https://img.shields.io/badge/database-postgresql-blue" alt="PostgreSQL">
  <!-- markdownlint-disable-next-line MD013 -->
  <a href="https://github.com/your-org/{{project-name}}/actions/workflows/ci-test.yml"><img src="https://github.com/your-org/{{project-name}}/actions/workflows/ci-test.yml/badge.svg" alt="CI"></a>
</p>

---

> **Using this as a template?** See [`docs/onboarding/PROJECT_SETUP.md`](docs/onboarding/PROJECT_SETUP.md)
> for the full setup checklist — placeholder replacement, env files, bootstrap, and first run.

---

## 🚀 At a glance

**{{project-name}}** is a Spring Boot 4 backend API scaffold that demonstrates:

- Doctor-first local setup validation
- CI-aligned quality gates from day one
- PostgreSQL with Flyway migrations (no in-memory shortcuts)
- Testcontainers for integration testing
- Incremental domain delivery via numbered phases

---

## 🧭 Developer Experience (Doctor-first)

```bash
make doctor
```

- Validates Java 21, Docker, Gradle, and local tooling
- Fails fast with explicit remediation steps
- Environment readiness only — never replaces CI

Full quality gate:

```bash
./gradlew clean check
```

> **Fail fast locally. Enforce correctness in CI. Document every non-obvious rule with ADRs.**

---

## 🧠 What this template demonstrates

- **Test-Driven Development (TDD)** from day one
- **CI parity** between local and remote environments
- **Real infrastructure** — PostgreSQL everywhere, Testcontainers for integration tests
- **Explicit architecture** — non-trivial decisions captured as ADRs
- **No shortcuts** — no H2, no in-memory databases, no hidden magic scripts
- **Doctor-first DX** — one command validates the whole environment

---

## 🧩 Tech stack

- **Java 21**
- **Spring Boot 4**
- **PostgreSQL + Flyway**
- **JPA / Hibernate**
- **Testcontainers**
- **Gradle**
- **Docker / Colima**
- **Spring Security + JWT** *(planned — phased rollout)*

---

## 🧪 Testing & quality

Authoritative quality gate:

```bash
CI=true ./gradlew clean check
```

Includes:

- Unit tests (JUnit 5 + Mockito)
- Integration tests (PostgreSQL via Testcontainers)
- Formatting (Spotless)
- Static analysis (Checkstyle, PMD, SpotBugs)

> If this command fails, the change is **incorrect**.

---

## 🌐 Accessing the API

Start the app with `make run` (starts Postgres + Spring Boot, sources `.env`).
The API listens on **`http://localhost:8080`** — open `/actuator/health` to verify.

Quick-start examples: [`docs/onboarding/QUICK_START.md`](docs/onboarding/QUICK_START.md)

---

## 🗺️ Roadmap (high level)

| Phase | Focus                                |
|------:|--------------------------------------|
| 0     | Project skeleton & DX infrastructure |
| 1     | Core CRUD domain                     |
| 2     | External API integration             |
| 3     | Domain feature 3 *(define yours)*    |
| 4     | Domain feature 4 *(define yours)*    |
| 5     | Security & hardening                 |

---

## 💡 Why this exists

This scaffold exists to demonstrate **how Java backend systems should be built**,
not just that they can be built.

It reflects:

- Production mindset from day one
- Strong engineering discipline
- Clear documentation
- Respect for future contributors and reviewers

---

### 🔗 More details

- Architecture decisions: [`docs/adr/`](docs/adr/)
- Onboarding & DX: [`docs/onboarding/`](docs/onboarding/)
- Local sanity checks: `make doctor`

---

*Built to be reviewed by engineers — not just to compile.*
