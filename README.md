<!-- markdownlint-disable MD033 -->

# 🎒 Pokémon Trainer Platform

<p align="center">
  <em>
    A production-grade Spring Boot 4 backend showcasing test-driven design,
    CI-first quality gates, and disciplined developer experience.
  </em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java 21">
  <img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot 4">
  <img src="https://img.shields.io/badge/database-postgresql-blue" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/docker-ready-blue" alt="Docker">
  <img src="https://img.shields.io/badge/tests-testcontainers-2496ED" alt="Testcontainers">
  <a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml"><img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-build.yml"><img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-build.yml/badge.svg" alt="Build Image"></a>
  <a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-publish.yml"><img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-publish.yml/badge.svg" alt="Publish Image"></a>
</p>

---

## 🚀 At a glance

**Pokémon Trainer Platform** is a backend API that enables trainers to:

- Manage trainer profiles
- Validate and manage Pokémon (via PokéAPI)
- Trade Pokémon with other trainers
- Buy and sell Pokémon in a marketplace

The domain is playful.  
The engineering is intentionally **serious**.

---

## 🧭 Developer Experience (Doctor‑first)

This project demonstrates a **doctor-first onboarding model**:

```bash
make doctor
```

- Validates Java 21, Docker, and local tooling
- Fails fast with explicit remediation steps
- Never replaces CI — CI remains authoritative

A single CI-aligned quality gate enforces correctness:

```bash
./gradlew clean check
```

> **Fail fast locally.  
> Enforce correctness in CI.  
> Document every non-obvious rule with ADRs.**

---

## 🧠 What this project demonstrates

- **Test‑Driven Development (TDD)** from day one
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
- **Spring Security + JWT (phased)**
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

- Unit & integration tests
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
