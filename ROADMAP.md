# 🗺️ Roadmap — Pokémon Trainer Platform

This document describes the **planned, phased roadmap** for the Pokémon Trainer Platform.

It reflects **intent and design direction**, not a record of released changes.

> ✅ Actual released changes are tracked in `CHANGELOG.md`, which is generated automatically from Conventional Commits and Git tags.

---

## 🔰 Phase 0 — Project Skeleton (v0.0.1)

**Status:** Completed

- Initial Spring Boot 4 project setup
- `/ping` endpoint and basic context bootstrap test
- Testing environment:
  - JUnit 5
  - AssertJ
  - Mockito

---

## 🎒 Phase 1 — Trainers & Inventory (v0.1.0)

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

- Testcontainers support with PostgreSQL
- Full end-to-end tests:
  - Trainer → Pokémon → Trade → Listing → Purchase flow

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
