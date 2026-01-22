# Architecture Decision Records (ADR)

This folder contains **Architecture Decision Records** for the Pokémon Trainer Inventory Service.

ADRs capture *why* we made a decision, not just *what* we built.

---

## ADR Index

> Keep this list in numeric order. Link each ADR file.

- **ADR-000** — Linting & static analysis as the first architectural decision
- **ADR-001** — PostgreSQL baseline (no H2)
- **ADR-002** — Flyway for schema migrations
- **ADR-003** — Testcontainers for integration testing
- **ADR-004** — Actuator health endpoints + Docker healthchecks
- **ADR-005** — Phase security implementation (deps first, enforcement later)
- **ADR-006** - local-dev-experience
- **ADR-007** - commit-msg
- **ADR-008** - CI-managed releases with semantic-release
  
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

- Introducing authn/authz (JWT, sessions, OAuth)
- New security posture (public vs private endpoints, CORS, rate limiting)
- Secrets handling, encryption, PII handling, audit requirements

### Infrastructure & operability

- Changing deployment topology (Docker/Compose/K8s), runtime, ports, health strategy
- Observability decisions (logging format, metrics, tracing, alerting)
- CI/CD policy changes (branch protections, merge policies, release automation)

### Testing strategy

- Changing integration test strategy (Testcontainers wiring, profiles, container lifecycle)
- Adding/removing test categories or quality gates (coverage thresholds, smoke tests)

---

## Lightweight ADR rule

If you’re unsure, default to writing a *small* ADR:

- 1 page max
- clear decision + context + consequences
- “Alternatives considered” can be brief (2–3 bullets)

---

## ADR review checklist

- Is the decision clearly stated?
- Is the context specific to this repo (not generic)?
- Are alternatives noted?
- Are consequences explicit (tradeoffs, future costs)?
- Is the decision reflected in docs (PHASES / README) and code?

---

## Naming & status conventions

Recommended format:

- Filename: `ADR-00X-short-title.md`
- Title: `ADR-00X: Short Title`
- Status: `Proposed` → `Accepted` → `Superseded` (with a link)

---

## Cross-links

- PHASES doc: phase-gate ADRs are referenced per phase
- PR templates: include ADR checklist to keep decisions explicit
