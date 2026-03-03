<!-- markdownlint-disable MD036 -->

# 🏷️ Project Badges

This document is the **authoritative source of truth** for badges used in this repository.

- `README.md` surfaces a **curated subset** of badges intended for first-time readers
  (recruiters, reviewers, new contributors).
- `BADGES.md` documents **what each badge represents**, why it exists, and how to
  maintain or extend the badge set over time.

Badges are treated as **signals**, not decoration.

---

## 📌 Current Badges

### Java 21

```html
<img src="https://img.shields.io/badge/java-21-blue" alt="Java 21">
```

**Represents**

- The project is built using **Java 21 (LTS)**

**Why it matters**

- Signals modern Java usage
- Aligns with current enterprise backend standards

**Update when**

- Java baseline changes

---

### Spring Boot 4.x

```html
<img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot 4">
```

**Represents**

- The project targets **Spring Boot 4.x**

**Why it matters**

- Indicates use of the latest Spring ecosystem
- Signals familiarity with modern Spring conventions

**Update when**

- Spring Boot major version changes

---

### PostgreSQL (Production Database)

```html
<img src="https://img.shields.io/badge/database-postgresql-blue" alt="PostgreSQL">
```

**Represents**

- PostgreSQL is the **only database** used
- No in-memory or substitute databases (e.g. H2)

**Why it matters**

- Demonstrates production-grade persistence choices
- Matches CI and Testcontainers behavior

**Update when**

- Database technology changes

---

### Testcontainers

```html
<img src="https://img.shields.io/badge/tests-testcontainers-2496ED" alt="Testcontainers">
```

**Represents**

- Integration tests run against **real services**
- PostgreSQL is provisioned via Testcontainers

**Why it matters**

- Strong signal of testing maturity
- Differentiates from mock-only or in-memory testing setups

**Update when**

- Integration testing strategy changes

---

### Continuous Integration (CI)

```html
<a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml">
  <img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/ci-test.yml/badge.svg" alt="CI">
</a>
```

**Represents**

- Status of the primary CI workflow
- Enforces formatting, static analysis, and tests

**Why it matters**

- Confirms automated quality gates
- CI is the authoritative enforcer of correctness

**Source**

- GitHub Actions workflow: `ci-test.yml`

---

## 🧪 Conditional / Deferred Badges

The following badges are **implemented or scaffolded**, but intentionally **not surfaced in `README.md` yet**.

They may be added later once their signals are externally meaningful.

---

### Docker Image Build

```html
<a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-build.yml">
  <img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-build.yml/badge.svg" alt="Build Image">
</a>
```

**Represents**

- Status of the Docker image build workflow

**Why it matters**

- Confirms the application can be packaged into a runnable artifact
- Serves as a prerequisite for future image publishing

**Why it is not shown in README yet**

- Images are not yet consumer-facing
- Publishing is intentionally gated behind quality enforcement

**Source**

- GitHub Actions workflow: `image-build.yml`

---

### Docker Image Publish (Deferred)

```html
<a href="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-publish.yml">
  <img src="https://github.com/jazicorn-tw/pokemon-trainer-platform/actions/workflows/image-publish.yml/badge.svg" alt="Publish Image">
</a>
```

**Represents**

- Publication of Docker images to a registry

**Why it matters**

- Signals release-grade artifacts
- Enables downstream consumption

**Why it is deferred**

- Image publishing will be enabled **after quality gates (SonarQube) are enforced**
- Badge will be surfaced once images are documented and consumable

**Source**

- GitHub Actions workflow: `image-publish.yml`

---

## ➕ How to Add a New Badge

Only add a badge if the tool or practice is:

- ✅ Already implemented
- ✅ Enforced in CI or exercised in real code paths
- ✅ Meaningful to external readers

### Required process

1. Add the badge **here first** (`BADGES.md`)
2. Document:
   - What it represents
   - Why it matters
   - When it should change
3. Curate a subset into `README.md` if appropriate

---

## 🚫 Explicitly Excluded (For Now)

The following are intentionally **not badged yet**:

- Coverage percentage (until enforced in CI)
- Security / JWT (until authentication is enforced)
- Release / version badges
- Dependency count or tooling vanity badges

---

## 🧭 Design Principle

> Badges should describe **reality**, not intent.

If a badge cannot be defended by code, tests, or CI,
it does not belong in this project.
