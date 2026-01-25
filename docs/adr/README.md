# Architecture Decision Records (ADR)

This folder contains **Architecture Decision Records** for the **Pokémon Trainer Platform**.

ADRs capture *why* we made a decision, not just *what* we built.

---

## ADR Index

> Keep this list in numeric order. Link each ADR file.

- **ADR-000** — Linting & static analysis as the first architectural decision  
- **ADR-001** — PostgreSQL baseline (no H2)  
- **ADR-002** — Flyway for schema migrations  
- **ADR-003** — Testcontainers for integration testing  
- **ADR-004** — Actuator health endpoints + Docker healthchecks  
- **ADR-005** — Phased security implementation (dependencies first, enforcement later)  
- **ADR-006** — Local developer experience  
- **ADR-007** — Commit message policy  
- **ADR-008** — CI-managed releases with semantic-release  
- **ADR-009** — Deployment strategy  
- **ADR-010** — Local CI simulation with `act`  
- **ADR-011** — Modular monolith → microservices (planned)

---

## When to write an ADR

Write (or update) an ADR when a change affects any of the following:

### Architecture & boundaries

- Introducing a new module, layer, or major package boundary
- Changing service boundaries or responsibility splits
- Adding a new public API style (REST changes, versioning strategy, pagination rules)

### Data & persistence

- Changing database technology, schema ownership, or migration strategy
- Introducing new persistence patterns (CQRS, outbox, event sourcing)
- Decisions that affect transactionality, consistency, or performance

### Security & compliance

- Introducing authentication or authorization (JWT, sessions, OAuth)
- New security posture (public vs protected endpoints, CORS, rate limiting)
- Secrets handling, encryption, PII handling, audit requirements

### Infrastructure & operability

- Changing deployment topology (Docker / Compose / Kubernetes)
- Runtime, ports, or healthcheck strategy changes
- Observability decisions (logging format, metrics, tracing, alerting)
- CI/CD policy changes (branch protection, merge rules, release automation)

### Testing strategy

- Changing integration test strategy (Testcontainers wiring, profiles, lifecycle)
- Adding or removing test categories or quality gates (coverage thresholds, smoke tests)

---

## Lightweight ADR rule

If you’re unsure, default to writing a *small* ADR:

- One page maximum
- Clear decision, context, and consequences
- Alternatives can be brief (2–3 bullets)

---

## ADR review checklist

Before marking an ADR as **Accepted**, confirm:

- The decision is clearly stated
- The context is specific to this repository (not generic advice)
- Alternatives were considered
- Consequences and tradeoffs are explicit
- The decision is reflected in documentation and code

---

## Naming & status conventions

Recommended format:

- **Filename**: `ADR-00X-short-title.md`
- **Title**: `ADR-00X: Short Title`
- **Status**: `Proposed` → `Accepted` → `Superseded` (with a link)

---

## Cross-links

- **PHASES**: phase-gated ADRs are referenced per phase
- **Pull requests**: PR templates include an ADR checklist to keep decisions explicit
