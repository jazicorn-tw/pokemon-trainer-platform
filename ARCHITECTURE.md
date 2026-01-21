# 🧠 Architecture Overview

This document explains **how** the Pokémon Trainer Platform is structured and **why** specific design decisions were made.

---

## 🎯 Architectural Goals

- Enterprise realism without tutorial shortcuts
- Production parity across environments
- Fast feedback loops via TDD
- Clear separation of concerns
- A safe path toward future scaling

---

## 🧱 High-Level Architecture

The system follows a classic layered architecture:

- **Controller layer** — HTTP boundary, validation, request/response shaping
- **Service layer** — business rules, orchestration, transactions
- **Domain layer** — entities, invariants, and core concepts
- **Repository layer** — persistence via Spring Data JPA

This structure supports refactoring, test isolation, and future extraction into separate services.

---

## 📂 Domain & Package Boundaries

Top-level packages represent **bounded contexts**:

- `trainer` — trainer profiles and ownership
- `pokemon` — owned Pokémon and species validation
- `trade` — bilateral Pokémon exchanges
- `market` — listings and purchases
- `pokeapi` — external API boundary
- `security` — authentication and authorization

This layout minimizes cross-domain coupling and enables future service decomposition.

---

## 📦 Technology & Dependency Decisions

Key decisions include:

- **Spring Boot 4** for long-term framework support
- **WebClient** instead of RestTemplate (non-blocking, future-proof)
- **PostgreSQL everywhere** to avoid dialect drift
- **Flyway** for explicit, versioned migrations
- **Testcontainers** for realistic integration tests
- **MapStruct** for explicit, compile-time-safe mapping
- **JWT delivered in phases** to avoid early complexity

Each decision favors predictability and maintainability over novelty.

---

## 🧪 Testing Strategy

The test pyramid is enforced deliberately:

- **Unit tests**
  - Fast
  - Mock boundaries
  - Validate business rules

- **Integration tests**
  - Real PostgreSQL
  - Flyway migrations applied
  - No mocks for persistence

Integration tests are suffixed with `*IT` and require Docker.

---

## 🩺 Operability (Build & Operate)

- `/ping` verifies application bootstrap
- Actuator health endpoints expose readiness and liveness
- Designed for Docker, CI, and Kubernetes compatibility

Operational concerns are treated as first-class citizens.

---

## 🗃️ Schema & Migrations

- Flyway is the single source of truth
- Migrations are forward-only and deterministic
- Schema changes are tested via integration tests

---

## 🔒 Security (Phased Delivery)

Security is introduced incrementally:

- Early phases: dependencies only, endpoints open
- Phase 7: JWT enforcement and protected routes

This keeps focus on domain correctness early while maintaining a realistic roadmap.

---

## 🚦 Quality Gates (Foundational)

Quality gates define the **minimum bar** for all code in the system.

Before any architectural layering, domain modeling, or feature work,
the project establishes:

- Automated linting
- Static analysis
- CI enforcement

These decisions are captured in **ADR-000**, which intentionally precedes
all other ADRs.

Quality gates ensure:

- Consistent code style
- Early bug detection
- Reduced PR friction
- Predictable refactoring safety

All changes are expected to pass:

```bash
./gradlew clean check
```

---

## 📜 Architecture Decision Records (ADRs)

Key decisions are captured in `docs/adr/`

ADRs prevent accidental regressions during refactors.

---

## 🧭 Thoughtworks Competency Alignment

This project demonstrates:

- **Craft** — TDD, refactoring discipline, clean layering
- **Sustainable Delivery** — CI automation, reproducible tests
- **Build & Operate** — health checks, migrations, parity
- **Collaboration** — documentation, ADRs, clear structure

---

## 🚧 Planned Improvements

- Structured JSON logging with correlation IDs
- OpenAPI‑first endpoint documentation
- Contract tests for external API boundaries
- Rate limiting and abuse protection
