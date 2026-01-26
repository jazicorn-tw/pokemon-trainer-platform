<!-- markdownlint-disable MD033 -->

<h1 align="center">
  🎒 Pokémon Trainer Platform
</h1>

<p align="center">
  <em>
    A production-grade Spring Boot 4 backend showcasing test-driven design,
    CI-first quality gates, and disciplined developer experience.
  </em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java 21">
  <img src="https://img.shields.io/badge/database-postgresql-blue" alt="PostgreSQL">
  <a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml"><img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml/badge.svg" alt="CI"></a>
</p>

---

## 🚀 At a glance

**Pokémon Trainer Platform** is a backend API that enables trainers to:

- Manage trainer profiles
- Validate and manage Pokémon (**PokéAPI integration — phased**)
- Trade Pokémon with other trainers
- Buy and sell Pokémon in a marketplace

The domain is playful.  
The engineering is intentionally **serious**.

> **Current state:** CI, infrastructure, and testing foundations are in place; domain features are delivered incrementally by phase.

---

## 🧭 Developer Experience (Doctor-first)

This project demonstrates a **doctor-first onboarding model**:

```bash
make doctor
```

- Validates Java 21, Docker, and local tooling
- Fails fast with explicit remediation steps
- Doctor validates **environment readiness only** — it never replaces CI

A single CI-aligned quality gate enforces correctness:

```bash
./gradlew clean check
```

> **Fail fast locally.  
> Enforce correctness in CI.  
> Document every non-obvious rule with ADRs.**

---

## 🧠 What this project demonstrates

- **Test-Driven Development (TDD)** from day one
- **CI parity** between local and remote environments
- **Real infrastructure**
  - PostgreSQL everywhere
  - Testcontainers for integration tests
- **Explicit architecture**
  - Non-trivial decisions captured as ADRs
- **No shortcuts**
  - No in-memory databases
  - No hidden magic scripts

---

## 🧩 Tech stack

- **Java 21**
- **Spring Boot 4**
- **PostgreSQL + Flyway**
- **JPA / Hibernate**
- **Spring Security + JWT** *(planned — phased rollout)*
- **Testcontainers**
- **Gradle**
- **Docker**

---

## 🧪 Testing & quality

Authoritative quality gate:

```bash
CI=true SPRING_PROFILES_ACTIVE=test ./gradlew clean check
```

Includes:

- Unit tests
- Integration tests (**PostgreSQL via Testcontainers**)
- Formatting (Spotless)
- Static analysis (Checkstyle, PMD, SpotBugs)

If this command fails, the change is **incorrect**.

---

## 🗺️ Roadmap (high level)

| Phase | Focus                           |
|------:|---------------------------------|
| 0     | Project skeleton & test harness |
| 1     | Trainers & inventory            |
| 2     | PokéAPI integration             |
| 3     | Trades                          |
| 4     | Marketplace                     |
| 5     | Security & hardening            |

---

## 💡 Why this exists

This project exists to demonstrate **how backend systems should be built**, not just that they can be built.

It reflects:

- Production mindset
- Strong engineering discipline
- Clear documentation
- Respect for future contributors and reviewers

---

### 🔗 More details

- Architecture decisions: `docs/adr/`
- Onboarding & DX: `docs/onboarding/`
- Local sanity checks: `make doctor`

---

*Built to be reviewed by engineers — not just to compile.*
