# ADR-006: Local Developer Experience – Makefile Commands, Doctor Checks, and Verification

- **Status:** Accepted
- **Date:** 2026-01-20
- **Deciders:** Project maintainers
- **Scope:** Local developer experience, quality gates, onboarding

---

## Context

This project prioritizes **production parity**, **explicit quality gates**, and **fast, actionable feedback** for developers.

Key characteristics of the codebase:

- Java **21+**
- Gradle wrapper–driven builds
- Docker-backed integration tests via **Testcontainers**
- Real PostgreSQL in all non-dev environments
- CI as the **authoritative enforcer** of quality (ADR-000)

Historically, failures caused by missing or misconfigured local infrastructure
(Java version, Docker, Colima, Gradle wrapper permissions) surfaced **late** and
with poor error messages (deep inside Gradle or Spring Boot startup).

We want local failures to be:

- Fast
- Explicit
- Actionable
- Clearly distinguished from CI enforcement

---

## Decision

### 1. Introduce a local environment sanity check (`doctor`)

A local-only script is added:

```bash
scripts/doctor.sh
```

Responsibilities:

- Validate **Java 21+** availability
- Ensure the **Gradle wrapper** exists and is executable
- Verify Docker CLI availability
- Verify Docker daemon reachability
- Validate Docker socket health
- On macOS:
  - Detect Colima
  - Ensure Colima is running (when present or explicitly required)
- Perform best-effort Docker memory checks

Design constraints:

- **Fail fast**
- **Never auto-start services**
- **Print explicit remediation instructions**
- **Exit immediately when `CI=true`**

This script is a **local convenience tool** and is not used directly by CI.

---

### 2. Expose the check via a single human-facing Make target: `doctor`

The following Make targets are defined for environment readiness:

| Target   | Purpose                                          |
|----------|--------------------------------------------------|
| `doctor` | Runs `scripts/doctor.sh` to validate local setup |
| `help`   | Lists common Make targets                        |

Rationale:

- `doctor` is memorable and human-friendly (ideal for onboarding)
- A single command avoids redundancy and cognitive overhead
- The script name (`doctor.sh`) matches its intent and documentation

---

### 3. Standardize local workflows using Make

Make is used as a **thin orchestration layer** over Gradle and scripts.

Key targets:

| Target      | Meaning                                                                   |
|-------------|---------------------------------------------------------------------------|
| `lint`      | Static analysis only                                                      |
| `test`      | Unit tests                                                                |
| `verify`    | “Am I good to push?” (doctor + lint + test)                               |
| `quality`   | Local CI approximation (doctor + auto-format + ./gradlew clean check)     |
| `bootstrap` | First-time setup (hooks + doctor + quality)                               |

Design principles:

- Make targets are **memorable**
- Make targets **do not replace CI**
- Make targets encode **intent**, not implementation detail

---

### 4. Define `verify` as a developer-experience umbrella

The `verify` target intentionally exists to answer a human question:

> “Is this good enough to push or open a PR?”

It runs:

1. Environment sanity (`doctor`)
2. Static analysis (`lint`)
3. Unit tests (`test`)

It does **not** run formatting or integration tests by default.

CI remains authoritative.

---

### 5. Keep CI authoritative and isolated

CI behavior remains unchanged:

- CI runs Gradle directly
- CI does **not** invoke Make
- CI enforces the quality gate via:

```bash
./gradlew clean check
```

Guards are added so that even if Make targets are accidentally invoked in CI,
local-only helpers (`doctor.sh`) exit immediately.

---

### 6. Docker container naming

Docker Compose–managed services **must not use `container_name`**.

Rationale:

- `container_name` disables Docker Compose’s project scoping
- Renaming repositories or services (e.g., inventory → trainer) can leave
  orphaned containers that collide with new names
- `docker compose down` cannot reliably clean up containers it does not own

By allowing Docker Compose to auto-generate container names, we ensure:

- Clean teardown with `docker compose down -v`
- No cross-project or legacy-name collisions
- Multiple compose projects can run simultaneously on the same machine

All interaction with containers should use `docker compose exec`
rather than `docker exec <container-name>`.

## Consequences

### Positive

- Faster, clearer local failures
- Smoother onboarding
- Reduced “it works on my machine” ambiguity
- Strong alignment between docs, tooling, and CI
- Developer commands read well in documentation and interviews

### Trade-offs

- Additional scripts and documentation must be maintained
- Best-effort checks (e.g. Docker memory) may vary by provider
- Makefile introduces a small abstraction layer over Gradle

---

## Non-goals

- Replacing CI with local tooling
- Auto-starting Docker or Colima
- Hiding Gradle from contributors
- Supporting unsupported Java versions

---

## Summary

This ADR formalizes the project’s **local developer experience contract**:

- CI is authoritative
- Local tooling is explicit and helpful
- Environment issues fail fast
- Commands encode intent, not mechanics

The combination of `doctor`, `verify`, and `quality` provides a clear, scalable,
and professional workflow aligned with ADR-000.
