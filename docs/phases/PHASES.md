<!-- markdownlint-disable-file MD024 -->
# 📦 Delivery Phases & Roadmap

## {{project-name}}

_A production-grade Spring Boot 4 + Gradle backend API scaffold — built phase-by-phase
with strict Test‑Driven Development (TDD) and CI-first quality gates._

This document is the **authoritative delivery contract** for the system.
Each phase is completed **only** when its release criteria are met.

For design rationale and trade‑offs, see **[../ARCHITECTURE.md](../ARCHITECTURE.md)**.

---

## 📘 Overview

The **{{project-name}}** scaffold lets you build a Spring Boot 4 backend API incrementally:

* Phase 0 — runnable skeleton with full DX and CI infrastructure
* Phase 1 — core domain entities and CRUD API
* Phase 2 — external API integration (validation or enrichment)
* Phase 3+ — trades, marketplace, auth, or your own domain features

The project is built using **TDD (Test-Driven Development)** at all phases.
Each version introduces new functionality only after writing failing tests first.

---

> **Note on version labels:** Phase version numbers (v0.0.1, v0.1.0, etc.) are
> **delivery milestone identifiers**, not git release tags. Git tags are managed
> automatically by semantic-release from Conventional Commits and will not match
> phase labels. See `CHANGELOG.md` for actual release history.

---

## 🧩 Tech Stack

| Area        | Technology                                              |
| ----------- | ------------------------------------------------------- |
| Language    | Java 21                                                 |
| Framework   | Spring Boot 4.0.x                                       |
| Database    | PostgreSQL (local/dev/prod), Testcontainers (tests)     |
| HTTP Client | WebClient (Spring WebFlux)                              |
| Auth        | Spring Security + JWT _(planned — phased rollout)_      |
| Testing     | JUnit 5, AssertJ, Mockito, Spring Test, Testcontainers  |
| Migration   | Flyway                                                  |
| Build       | Gradle 9                                                |

---

## 🧪 Test-Driven Development Workflow

Every feature in this project follows:

1. **Write failing tests** (unit or controller tests)
2. **Implement the minimal passing code**
3. **Refactor with confidence**

No feature is added without tests.

---

## 🔰 Phase 0 — Project Skeleton & DX Infrastructure (v0.0.1)

> ⚠️ **Environment requirement:** Phase 0 tests require **Docker** (or **Colima on macOS**)
> because the project uses **Testcontainers** for PostgreSQL-backed integration tests.
> If Docker is not running, Phase 0 **must fail** — this is intentional and documents
> production parity.

* Full walkthrough: [`PHASE_0.md`](PHASE_0.md)

---

### 🎯 Purpose

Establish a **runnable, testable Spring Boot 4 service** with a full production-grade DX stack —
CI/CD, quality gates, release automation, and local tooling — before any domain logic.

Phase 0 exists to:

* Prove the application can boot end-to-end
* Lock in database, migration, testing, and quality-gate strategy
* Wire CI/CD pipelines, semantic-release, and Docker image publishing from day one
* Prevent later architectural drift
* Ensure CI and local environments behave identically

No business logic is introduced in this phase.

---

### 🧱 Phase-Gate ADRs

* **ADR-000** — Quality gates & local/CI parity
* **ADR-001** — PostgreSQL as the only database (no H2, no in-memory fallbacks)
* **ADR-002** — Flyway for schema migrations (explicit, versioned SQL)
* **ADR-003** — Testcontainers for all integration tests
* **ADR-004** — Actuator health endpoints + Docker health checks
* **ADR-005** — Phased security approach (dependencies now, enforcement later)

---

### 🧪 TDD Contract (Phase 0)

1. **Context load test** — Spring context boots, PostgreSQL + Flyway wiring confirmed
2. **Public liveness endpoint** — `GET /ping` returns `"pong"`
3. **Operational health** — `GET /actuator/health` returns UP with DB status
4. **Container health** — Dockerfile healthcheck wired to Compose

---

### ✅ Release Criteria (Phase 0 Complete)

* Docker / Colima running locally
* Application boots without manual setup
* Local quality gates pass (ADR-000)
* `./gradlew test` passes using Testcontainers PostgreSQL
* `/ping` responds with `"pong"`
* `/actuator/health` reports UP
* CI pipeline passes
* Docker healthcheck passes

---

## 🐣 Phase 1 — Core Domain & CRUD API (v0.1.0)

### Purpose

Introduce the primary domain entities and their full CRUD API, built test-first.

### TODO: Define your domain

Replace the placeholders below with your actual entities:

* **Primary entity** — _e.g. User, Order, Product, Author_
* **Secondary entity** — _e.g. Item, LineItem, Comment, Book_

### TDD Steps

* Write service unit tests for your primary entity
* Implement entity, JPA repository, service, controller
* Write `@WebMvcTest` @WebMvcTest + MockMvc with `@MockitoBean`
* Write Testcontainers integration tests extending `AbstractIntegrationTest`
* Add `GlobalExceptionHandler` returning `ProblemDetail` (RFC 7807) for 400, 404, 409

### Release Criteria

* Primary entity CRUD works end-to-end
* Sub-entity ownership enforced (parent must exist)
* Invalid references return structured 404/409 ProblemDetail errors
* All unit, slice, and integration tests pass
* CI pipeline green

---

## 🧬 Phase 2 — External API Integration (v0.2.0)

### Purpose

Validate or enrich domain data against an external API before persisting.

### TODO: Define your external API

* **External API** — _e.g. Stripe, SendGrid, a public REST API_
* **Validation rule** — _e.g. validate entity exists, enrich with metadata_

### TDD Steps

* Mock the external API client in all tests (WireMock stubs)
* Write failing tests for invalid/rejected cases
* Implement WebClient-based HTTP client (blocking `.block()`)
* Add graceful failure handling

### Release Criteria

* Invalid entries rejected with 422 Unprocessable Entity
* External API failures handled gracefully (503, not 500)
* External API fully mocked in CI — no real HTTP calls
* All Phase 1 tests remain green

---

## ⚔️ Phase 3 — Define your feature (v0.3.0)

> TODO: Replace with your domain feature (e.g. Trading, Notifications, Subscriptions).

### Purpose

> Describe the feature and why it matters.

### TDD Steps

> List the test-first steps for your feature.

### Release Criteria

> List the acceptance criteria.

---

## 💰 Phase 4 — Define your feature (v0.4.0)

> TODO: Replace with your domain feature (e.g. Marketplace, Billing, Reporting).

### Purpose

> Describe the feature and why it matters.

### Release Criteria

> List the acceptance criteria.

---

## 🧪 Phase 5 — Integration Testing & E2E (v0.5.0)

### Purpose

Validate real‑world end-to-end behavior using PostgreSQL and Testcontainers
(already in use since Phase 0 — this phase adds full lifecycle coverage across
domain features).

### Release Criteria

* Full domain-flow integration tests pass against real PostgreSQL (Testcontainers)
* Migrations apply cleanly end-to-end
* No mocked repositories in integration test layer

---

## 🔐 Phase 6 — Security Skeleton (v0.6.0)

### Purpose

Introduce Spring Security infrastructure without enforcement.

### New Dependencies

* `spring-boot-starter-security`
* `jjwt-*`
* `spring-security-test`

### Release Criteria

* No endpoint regressions
* Security infrastructure present but inactive

---

## 🛡 Phase 7 — JWT Authentication (v0.7.0)

### Purpose

Enforce authentication and authorization on protected routes.

### Release Criteria

* Unauthorized requests return 401
* Valid JWT grants access
* Passwords stored securely (BCrypt)

---

## 🌱 Phase 8 — Developer Experience & Refactor (v0.8.0)

### Purpose

Improve maintainability and developer experience.

### New Dependencies

* Spring Boot DevTools
* MapStruct
* SpringDoc OpenAPI UI

### Release Criteria

* No behavior changes
* All tests remain green
* Documentation complete

---

## 📦 Getting Started

```bash
git clone https://github.com/your-org/{{project-name}}
cd {{project-name}}
make bootstrap
make doctor
make run
```

---

## 🧪 Running Tests

```bash
./gradlew test   # requires Docker
```

---

## ⚙️ Operational Readiness

* Actuator liveness & readiness
* Docker‑friendly healthchecks
* Kubernetes‑compatible design

---

## 🗺 Beyond v0.8.0

* v0.9.0 — Audit & history
* v1.0.0 — Stable public API
* v2.0.0 — _define your next milestone_
