# 🧠 Architecture Overview

This document explains **how** the {{project-name}} is structured and **why**
specific design decisions were made.

The focus is on **clarity, correctness, and evolvability** rather than premature scale.

---

## 🎯 Architectural Goals

- Enterprise realism without tutorial shortcuts
- Production parity across environments
- Fast feedback loops via TDD
- Clear separation of concerns
- A safe, intentional path toward future scaling

---

## 🧱 High-Level Architecture

The system follows a classic layered architecture:

- **Controller layer** — HTTP boundary, validation, request/response shaping
- **Service layer** — business rules, orchestration, transactional boundaries
- **Domain layer** — entities, invariants, and core concepts
- **Repository layer** — persistence via Spring Data JPA

This structure favors:

- Test isolation
- Refactor safety
- Incremental extraction into separate services if needed later

---

## 📂 Domain & Package Boundaries

Top-level packages represent **bounded contexts**.

At this stage (Phase 0), these packages describe **intended boundaries** rather than
fully implemented features.

- `resource` — resource profiles and ownership *(planned)*
- `{{resource}}` — owned {{resource}} and species validation *(planned)*
- `trade` — bilateral {{resource}} exchanges *(planned)*
- `market` — listings and purchases *(planned)*
- `{{external-api}}` — external API boundary *(planned)*
- `security` — authentication and authorization *(planned)*

Defining these boundaries early provides a stable mental model and avoids
large-scale refactors as features are introduced.

---

## 📦 Technology & Dependency Decisions

Key decisions include:

- **Spring Boot 4** for long-term framework support
- **WebClient** instead of RestTemplate (non-blocking, future-proof)
- **PostgreSQL everywhere** to avoid dialect drift
- **Flyway** for explicit, versioned schema migrations
- **Testcontainers** for realistic integration tests
- **MapStruct** for explicit, compile-time-safe mapping
- **JWT delivered in phases** to avoid premature security complexity

Each decision favors **predictability and maintainability** over novelty.

---

## 🧪 Testing Strategy

The test pyramid is enforced deliberately.

### Unit tests

- Fast
- Mock external boundaries
- Validate business rules and invariants

### Integration tests

- Real PostgreSQL
- Flyway migrations applied
- No mocks for persistence or schema

Integration tests:

- Are suffixed with `*IT`
- Require Docker
- Run in both local and CI environments

---

## 🩺 Operability (Build & Operate)

Operational concerns are treated as **first-class citizens**:

- `/ping` verifies application bootstrap
- Actuator health endpoints expose readiness and liveness
- Designed for Docker-based execution and CI environments

The application is **designed to be deployable** to container platforms
without assuming a specific runtime or orchestrator.

---

## 🗃️ Schema & Migrations

- Flyway is the **single source of truth** for schema evolution
- Migrations are forward-only and deterministic
- Schema changes are verified through integration tests

This ensures schema drift is detected early and consistently.

---

## 🔒 Security (Phased Delivery)

Security is introduced incrementally to avoid obscuring domain correctness.

- Early phases: dependencies present, endpoints open
- Later phases: JWT enforcement and protected routes

This approach keeps early development focused while maintaining
a realistic and explicit security roadmap.

---

## 🚦 Quality Gates (Foundational)

Quality gates define the **minimum bar** for all code in the system.

Before domain modeling or feature development, the project establishes:

- Automated formatting
- Static analysis
- CI enforcement

These decisions are captured in **ADR-000**, which intentionally precedes
all other architectural decisions.

All changes are expected to pass:

```bash
./gradlew clean check
```

Quality gates ensure:

- Consistent code style
- Early bug detection
- Predictable refactoring safety
- Reduced PR friction

---

## 📜 Architecture Decision Records (ADRs)

Non-trivial decisions are captured in `docs/adr/`.

ADRs:

- Preserve architectural intent
- Prevent accidental regressions
- Provide context during refactors or reviews

---

## 🧭 Thoughtworks Competency Alignment

This project demonstrates:

- **Craft** — TDD, refactoring discipline, clear layering
- **Sustainable Delivery** — CI automation, reproducible tests
- **Build & Operate** — health checks, migrations, parity
- **Collaboration** — documentation, ADRs, explicit structure

---

## 🚧 Planned Improvements

- Structured JSON logging with correlation IDs
- OpenAPI-first endpoint documentation
- Contract tests for external API boundaries
- Rate limiting and abuse protection
