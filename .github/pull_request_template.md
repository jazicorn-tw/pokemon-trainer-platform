# Pull Request

## Summary

### What changed?

-

### Why?

-

---

## Scope & Risk

### Change type

- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] Build / CI
- [ ] Chore

### Risk level

- [ ] Low (docs or tests only)
- [ ] Medium (behavior change, well-covered)
- [ ] High (wide impact, migration, config)

### Rollback

- [ ] Default: revert this PR _(fill in below only if different)_

---

## Evidence

- [ ] `make check-all` passes
- [ ] `./gradlew clean check` passes locally
- [ ] CI quality gate is green
- [ ] `./gradlew test` passes (Docker / Colima running)
- [ ] `curl -i http://localhost:8080/ping` returns `pong`
- [ ] `curl -i http://localhost:8080/actuator/health` reports `UP`

---

## Tests

> Use the lowest layer that covers the behaviour being tested.

| What | Layer | Tooling |
| ---- | ----- | ------- |
| Business rules, no I/O | Service unit | JUnit 5 + Mockito |
| HTTP contract | Controller slice | `@WebMvcTest` + `@MockitoBean` |
| Database persistence | Integration | `extends BaseIntegrationTest` |

- [ ] Tests added or updated at the appropriate layer
- [ ] No `@ServiceConnection` — classic Testcontainers only (`extends BaseIntegrationTest`)
- [ ] No business logic added to controllers

---

## Quality Gates (ADR-000)

> ADR-000 defines linting, static analysis, and CI enforcement as **foundational** decisions.

- [ ] `./gradlew clean check` passes locally
- [ ] No linting rules disabled or bypassed
- [ ] Static analysis reports reviewed (no unexpected violations)
- [ ] Commits use Conventional Commits format (`cz commit`) — see ADR-007

---

## Architecture Decision Records

- [ ] No architectural decisions introduced
- [ ] ADRs updated or added (list below)
- [ ] Existing ADRs reviewed and still valid

**ADRs referenced / modified:**

- ADR-___

---

## Phase & Gate

**Current phase:** Phase 1 (Resource + Owned{{resource}} CRUD) — Phase 2 ({{external-api}}) is next

- [ ] Change is phase-appropriate — no Phase 2+ features introduced
- [ ] No cross-layer refactors beyond what this change requires

---

## Pre-review self-check

Before requesting review:

- [ ] Branch is up to date with base branch
- [ ] `./gradlew test` passes locally
- [ ] CI checks are green
- [ ] No unrelated changes included
- [ ] No secrets or `.env` values committed

---

## Notes for reviewers

-

---

## Reviewer checklist

- [ ] Change is small and scoped
- [ ] Architecture layers are respected (no business logic in controllers)
- [ ] Tests are present and meaningful
- [ ] No new Testcontainers strategy introduced (classic only)
- [ ] CI checks are green
- [ ] ADRs referenced if behavior or structure changed
