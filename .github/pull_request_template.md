# Pull Request

## Summary

### What changed?

- _Describe the change_

### Why?

- _Explain the motivation_

### How to test?

- [ ] `./gradlew test`
- [ ] Manual verification (if applicable)

---

## Phase & Gate

**Phase:** Phase __ (0 / 1 / 2 / 3 / …)

> Phase transitions require all phase-gate ADRs to be accepted and merged.

### Phase-gate ADRs

- [ ] No phase-gate ADR changes required
- [ ] Phase-gate ADRs reviewed and still valid
- [ ] Phase-gate ADRs updated or added

---

## Quality Gates (ADR-000)

> ADR-000 defines linting, static analysis, and CI enforcement as **foundational** decisions.

- [ ] `./gradlew clean check` passes locally
- [ ] Linting violations addressed or intentionally suppressed
- [ ] No new linting rules bypassed or disabled
- [ ] CI quality gate remains intact

---

## Architecture Decision Records (ADR)

- [ ] No architectural decisions introduced
- [ ] ADRs updated or added
- [ ] Existing ADRs reviewed and still valid

### ADRs referenced / modified

- ADR-___
- ADR-___

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

### Rollback plan

- _Describe rollback if needed_

---

## Checklist

- [ ] Tests added or updated
- [ ] `./gradlew test` passes locally
- [ ] No secrets committed (env vars only)
- [ ] Documentation updated if needed
- [ ] Observability intact (health endpoints unchanged)

---

## Notes for reviewers

- _Anything reviewers should know_
