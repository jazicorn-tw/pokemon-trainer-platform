# ADR-009: Deployment Strategy (Render → Kubernetes)

- **Status:** Accepted
- **Date:** 2026-01-22
- **Deciders:** Project maintainers
- **Scope:** Application deployment and runtime environment

---

## Context

The {{project-name}} is currently implemented as a **modular monolith**
(Inventory, Trading, Marketplace in a single Spring Boot application).

The project prioritizes:

- fast feedback
- low operational overhead
- CI-first quality gates
- production parity without premature complexity

A deployment approach is needed that supports these goals **now**, while leaving
a clear migration path to Kubernetes when services are split.

---

## Decision

### Phase 1: Render (single service)

- Deploy the application as a single Docker-based web service on **Render**
- Render builds the container directly from the repository `Dockerfile`
- Runtime configuration is provided exclusively via environment variables
- Health checks use Spring Boot Actuator endpoints

This phase minimizes operational overhead while validating:

- container correctness
- configuration discipline
- database migrations
- release stability

### Phase 2: Kubernetes + Helm (future)

When the system evolves into multiple independently deployable services:

- Adopt Kubernetes as the runtime platform
- Use Helm charts for packaging and configuration
- Align Helm chart versions with semantic-release tags
- Deploy each service independently

Helm is introduced early (linting only) to keep the chart valid without requiring
Kubernetes today.

---

## Consequences

### Positive

- Faster delivery during early development
- Clear separation between release and deployment concerns
- No Kubernetes tax before it provides real value
- Explicit migration path, documented in advance

### Trade-offs

- Kubernetes features (HPA, rolling strategies) are deferred
- Render-specific operational details exist during Phase 1

---

## Notes

- Helm charts are linted in CI but not deployed in Phase 1
- Kubernetes adoption will be revisited when services are extracted

---

## Appendix: Phase 1 Deployment Clarifications (Render)

This appendix documents **implementation details** for the Phase 1 deployment
strategy without expanding or altering the core decision.

### Render responsibilities

During Phase 1, Render is responsible for:

- Building the application container from the repository `Dockerfile`
- Providing HTTPS, routing, and basic runtime health checks
- Supplying runtime configuration via environment variables

Render deployment is intentionally **not automated via CI** at this stage.

### Relationship to release artifacts

Release artifacts (Docker images) are produced independently via CI, as defined
in **ADR-008**.

- semantic-release remains the sole authority for version creation
- Docker image publishing may be enabled or disabled via repository variables
- Deployment and release lifecycles are intentionally decoupled

This separation ensures that:

- releases remain reproducible
- deployments remain reversible
- operational changes do not require source code changes

### Future transition

When the system transitions to Kubernetes:

- Render-specific deployment details will be retired
- Helm charts (already validated via CI linting) will become the primary
  deployment mechanism
- Deployment automation may be introduced once multiple services exist
