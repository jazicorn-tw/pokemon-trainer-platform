# Contributing

Thank you for your interest in contributing! 🤝
We welcome thoughtful, well-tested changes that improve **correctness, clarity, and long-term maintainability**.

This project is built around **Test-Driven Development (TDD)**, strict CI parity, and production-realistic constraints. Contributions that bypass these principles will not be merged.

---

## 🧪 Development Workflow (TDD Required)

All development **must** follow the **red → green → refactor** loop.

### 1. Write a failing test (RED)

Choose the *lowest appropriate layer*:

* **Service layer** → unit tests (Mockito)
* **Controller layer** → `@WebMvcTest` + MockMvc
* **Integration layer** → Testcontainers (PostgreSQL)

> If unsure, default to the lowest layer possible.

---

### 2. Write the minimal implementation (GREEN)

* Implement only what satisfies the test
* No speculative features
* No premature abstractions

---

### 3. Refactor safely (REFACTOR)

* Improve readability and naming
* Reduce duplication
* Enforce **SRP**
* Keep all tests passing

---

### 4. Commit with intent

Use clear, scoped commit messages:

* `feat(trade): add trade acceptance logic`
* `fix(pokemon): handle PokeAPI validation errors`
* `test(market): add listing cancellation coverage`

---

## 🧩 Code Style & Design Rules

* Follow Java & Spring Boot best practices
* Prefer **small, focused methods**
* Constructor injection only
* No static mutable state
* DTOs at API boundaries
* Thin controllers — no business logic

---

## 🛡️ Local Quality Gates (ADR-000)

This repository enforces **local quality gates** via a Git `pre-commit` hook.

Before code leaves your machine, the hook may:

* auto-format code (Spotless)
* run static analysis
* optionally run unit tests

Install hooks and run the full local gate:

```bash
make bootstrap
```

See `docs/onboarding/PRECOMMIT.md` for details and override options.

---

## 🏗 Architecture Principles

The codebase follows a **layered architecture**:

* `controller` → HTTP only
* `service` → business logic
* `repository` → persistence (JPA)
* `client` → external integrations (PokeAPI)
* `config` → cross-cutting concerns

Breaking layer boundaries requires justification and, if significant, an ADR.

---

## 🌱 Branching Strategy

Promotion-based model:

* `main` → production-only
* `staging` → release candidates
* `dev` → active development
* `feature/*` → one change per branch
* `hotfix/*` → urgent fixes

```text
feature/* → dev → staging → main
```

* No direct commits to `main` or `staging`
* All merges require CI + reviews

---

## 🧪 Testing Requirements

Every PR **must include appropriate tests**:

| Layer       | Required Tests              |
| ----------- | --------------------------- |
| Services    | Unit (Mockito)              |
| Controllers | `@WebMvcTest`               |
| Integration | Testcontainers (PostgreSQL) |
| Security    | `spring-security-test`      |

PRs without tests or with reduced coverage **will not be merged**.

---

## 🚦 Quality Gates (ADR-000)

Linting and CI enforcement are **architectural decisions**, not tooling preferences.

Before opening a PR:

```bash
./gradlew clean check
```

Do **not** disable or bypass checks without an approved ADR.

See:

* `docs/adr/ADR-000-linting.md`
* `docs/onboarding/LINTING.md`

---

## 📝 Pull Request Checklist

* [ ] Tests added and passing
* [ ] No failing integration tests
* [ ] Code formatted
* [ ] Feature documented if applicable
* [ ] No dead or commented-out code
* [ ] No new Testcontainers strategy

---

## ⚙ Local Development Requirements

**Prerequisites**:

* Java 21
* Docker
* macOS: Colima

Verify:

```bash
java -version
docker ps
```

---

## ▶ Running Tests Locally

```bash
colima start
docker context use colima
./gradlew test
```

If tests fail, consult `docs/TESTING.md` first.

---

## 🚫 Testcontainers Rules (Important)

This project uses **classic Testcontainers only**.

✅ Allowed:

* `@Testcontainers`
* static `@Container`
* `@DynamicPropertySource`

🚫 Not allowed:

* `@ServiceConnection`
* Mixing container strategies

---

## 🧪 Integration Test Base Class

All integration tests **must** extend:

```java
class ExampleIT extends BaseIntegrationTest {}
```

This guarantees consistent container lifecycle behavior.

---

## 💬 Need Help?

Open an issue with:

* The problem being solved
* Why it matters
* Any constraints or proposals

High-quality discussions and contributions are always welcome 🚀
