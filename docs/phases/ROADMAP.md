<!-- markdownlint-disable-file MD009 -->
# 🗺️ Roadmap — Pokémon Trainer Platform

This document describes the **planned, phased roadmap** for the Pokémon Trainer Platform.

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
- `/ping` endpoint and context bootstrap test (Testcontainers + PostgreSQL)
- CI/CD pipelines: `ci-fast`, `ci-quality`, `ci-test`, `release`, `image-build`
- Semantic-release with Conventional Commits
- Docker image publishing to GHCR; Helm chart for Kubernetes
- Modular Make system (`make/`) with role-based targets
- `scripts/doctor.sh`, bootstrap, check, and dev lifecycle scripts
- Quality gates: Spotless, Checkstyle, PMD, markdownlint, pre-commit hooks
- SonarCloud integration; `act` support for local CI simulation

---

## 🎒 Phase 1 — Trainers & Inventory (v0.1.0)

**Status:** Completed

- Trainer entity, service, repository, and controller
- Owned Pokémon entity and inventory CRUD operations
- Validation + global exception handling
- Comprehensive TDD coverage for service and controller layers

---

## 🌐 Phase 2 — PokeAPI Integration (v0.2.0)

- WebClient-based PokeAPI client
- Species validation when adding Pokémon
- Expanded DTO models for external API data

---

## 🔄 Phase 3 — Trading System (v0.3.0)

- Trade entity, service, and controller
- Trade lifecycle:
  - Pending
  - Completed
  - Rejected
  - Cancelled
- Ownership swapping logic
- Full TDD suite for trade workflows

---

## 🛒 Phase 4 — Marketplace Listings (v0.4.0)

- SaleListing entity, service, and controller
- Buying and selling Pokémon
- Validation tests for seller and buyer scenarios
- API documentation via SpringDoc / Swagger UI

---

## 🧪 Phase 5 — Integration & E2E Testing (v0.5.0)

- Full end-to-end integration tests (Testcontainers + PostgreSQL, in use since Phase 0)
- Complete lifecycle flows:
  - Trainer → Pokémon → Trade → Listing → Purchase

---

## 🔐 Phase 6 — Security Foundation (v0.6.0)

- Spring Security scaffolding
- JWT dependencies and configuration groundwork
- All endpoints permitted (pre-authentication phase)

---

## 🔑 Phase 7 — Authentication & JWT (v0.7.0)

- UserAccount entity and repository
- Authentication endpoints:
  - `POST /auth/register`
  - `POST /auth/login`
- JWT token provider and request filter
- Endpoint protection + security integration tests

---

## ✨ Phase 8 — Developer Experience & Polish (v0.8.0)

- MapStruct mappers
- Flyway database migrations
- Structured JSON logging (Logback)
- DevTools for hot reload
- Dependency cleanup and configuration refactors

---

## 🚀 Future Milestones

- **v0.9.0** — Advanced auditing (trade history)
- **v1.0.0** — Production launch
- **v1.1.0** — GraphQL API
- **v2.0.0** — Multi-region marketplace

---

## 🧭 Notes

- Version numbers indicate **planned release targets**, not guarantees.
- Scope may evolve based on feedback, ADRs, and implementation learnings.
- Major architectural changes must be captured via ADRs.
