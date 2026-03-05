<!-- markdownlint-disable-file MD009 -->
# 🗺️ Roadmap — {{project-name}}

This document describes the **planned, phased roadmap** for {{project-name}}.

It reflects **intent and design direction**, not a record of released changes.

> ✅ Actual released changes are tracked in `CHANGELOG.md`, which is generated automatically
> from Conventional Commits and Git tags.
>
> **Note on version labels:** Phase version numbers (v0.0.1, v0.1.0, etc.) are
> **delivery milestone identifiers**, not git release tags. Git tags are managed
> automatically by semantic-release from Conventional Commits and will not match
> phase labels. See `CHANGELOG.md` for actual release history.

---

## 🔰 Phase 0 — Project Skeleton & DX Infrastructure (v0.0.1)

**Status:** Completed

- Initial Spring Boot 4 project setup
- `/ping` endpoint and context bootstrap test (containerized PostgreSQL)
- CI/CD pipelines: `ci-fast`, `ci-quality`, `ci-test`, `release`, `image-build`
- Semantic-release with Conventional Commits
- Docker image publishing to GHCR; Helm chart for Kubernetes
- Modular Make system (`make/`) with role-based targets
- `scripts/doctor.sh`, bootstrap, check, and dev lifecycle scripts
- Quality gates: Spotless, Checkstyle, PMD, SpotBugs, markdownlint, pre-commit hooks
- SonarCloud integration; `act` support for local CI simulation

---

## 🐣 Phase 1 — Core Domain & CRUD API (v0.1.0)

**Status:** TODO — define your domain

- Primary entity (CRUD): create, read, update, delete
- Secondary entity (inventory/items): add, list, update, remove
- Validation + global structured error handling (RFC 7807 ProblemDetail or equivalent)
- Comprehensive TDD coverage: unit, controller slice, and integration tests

---

## 🧬 Phase 2 — External API Integration (v0.2.0)

> TODO: Replace with your external API target.

- HTTP client for external validation/enrichment API
- Validation wired into domain write operations
- Graceful failure handling (422 invalid, 503 API unavailable)
- External API fully mocked in all tests

---

## ⚔️ Phase 3 — *(Define your feature)* (v0.3.0)

> TODO: Replace with your domain feature (e.g. Trading, Notifications, Subscriptions).

- *(Describe the feature)*
- *(List the key entities and operations)*
- Full TDD suite

---

## 💰 Phase 4 — *(Define your feature)* (v0.4.0)

> TODO: Replace with your domain feature (e.g. Marketplace, Billing, Reporting).

- *(Describe the feature)*
- API documentation (e.g. OpenAPI / Swagger UI)

---

## 🧪 Phase 5 — Integration & E2E Testing (v0.5.0)

- Full end-to-end integration tests against real PostgreSQL (containerized)
- Complete lifecycle flows across all domain features
- No mocked repositories in integration test layer

---

## 🔐 Phase 6 — Security Foundation (v0.6.0)

- Security framework scaffolding
- Auth dependencies and configuration groundwork
- All endpoints permitted (pre-authentication phase)

---

## 🔑 Phase 7 — Authentication & Authorization (v0.7.0)

- User account entity and repository
- Authentication endpoints:
  - `POST /auth/register`
  - `POST /auth/login`
- Token provider and request filter
- Endpoint protection and security integration tests

---

## ✨ Phase 8 — Developer Experience & Polish (v0.8.0)

- Object mapping library integration
- Database migration hardening
- Structured JSON logging
- Dependency cleanup and configuration refactors

---

## 🚀 Future Milestones

- **v0.9.0** — Audit & history
- **v1.0.0** — Stable public API
- **v2.0.0** — *(define your next milestone)*

---

## 🧭 Notes

- Version numbers indicate **planned release targets**, not guarantees.
- Scope may evolve based on feedback, ADRs, and implementation learnings.
- Major architectural changes must be captured via ADRs.
