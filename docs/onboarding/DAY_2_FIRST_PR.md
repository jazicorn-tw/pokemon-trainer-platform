# Day-2 / First PR Checklist

This checklist ensures your **first contribution** follows the project’s
architecture, testing discipline, and delivery standards.

If you complete everything here, your first PR should be **boring to review** —
in the best possible way.

---

## Goals for Day-2

* Understand the project structure and architectural intent
* Make a **small, scoped change**
* Prove you can run tests locally and in CI
* Produce a PR that matches team expectations

---

## 1. Read Before You Code (Required)

Skim these documents **once**:

* [`README.md`](../../README.md) — project purpose & scope
* [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — layers and boundaries
* [`docs/phases/PHASES.md`](../phases/PHASES.md) — current phase and constraints
* [`docs/adr/README.md`](../adr/README.md) — especially:

  * ADR-001 (PostgreSQL everywhere)
  * ADR-002 (Testcontainers)
  * ADR-004 (.env local support)

You do **not** need to memorize them — just know *where* decisions live.

---

## 2. Create a Feature Branch

```bash
git checkout -b feature/<short-description>
```

Rules:

* One concern per branch
* No refactors unless explicitly required

---

## 3. Pick a Day-2-Sized Change

Good first PR examples:

* Add a small endpoint (`GET /ping` style)
* Add validation to an existing request
* Improve logging or error messages
* Add or refine a test
* Documentation clarification

Avoid:

* Cross-layer refactors
* Dependency upgrades
* Style or formatting-only PRs

---

## 4. Implement Using the Architecture

Follow the layer order:

1. Controller (HTTP boundary)
2. Service (business logic)
3. Domain (rules, invariants)
4. Repository (persistence)

Rules:

* Controllers are thin
* Services are explicit
* No business logic in controllers
* No framework leakage into domain

---

## 5. Tests Are Mandatory

Before committing:

```bash
./gradlew test
```

Guidelines:

* Controller logic → MVC test
* Business logic → service test
* Persistence → Testcontainers-backed test

❌ Do not merge code that is not tested.

---

## 6. Verify Local Behavior

If applicable:

```bash
./gradlew bootRun -Dspring.profiles.active=local
```

Check:

* Endpoint responds as expected
* No startup warnings or errors
* Actuator health is `UP`

---

## 7. Commit Standards

Make small, intentional commits.

### Preferred tool: `cz commit`

```bash
cz commit
```

Runs an interactive prompt — just answer the questions:

```text
? Select the type of change:   feat
? Scope (optional):            resource
? Short description:           add nickname validation
? Longer description (opt.):   [enter to skip]
? Breaking change?             N
```

The `commit-msg` hook validates the message automatically. If you use `git commit`
directly, the hook still runs — an invalid format will be rejected with a clear error.

📄 Full reference: [`docs/commit/COMMITIZEN.md`](../commit/COMMITIZEN.md)

### Commit format reference

```text
feat: add <short description>
fix: correct <short description>
test: add coverage for <area>
docs: clarify <topic>
```

Avoid:

* `wip`
* `fix stuff`
* Giant multi-purpose commits

---

## 8. Open the Pull Request

Ensure your PR:

* Targets the correct base branch
* References the current phase
* Explains **what** changed and **why**
* Mentions any ADRs touched or relied on

Use the PR template **as-is**.

---

## 9. Pre-Review Self-Check

Before requesting review, confirm:

* [ ] **Branch is up to date** with base branch
* [ ] **`./gradlew test` passes locally**
* [ ] **CI checks are green**
* [ ] **Change is phase-appropriate**
* [ ] **No unrelated changes included**

---

## 10. Responding to Review

* Treat comments as design discussion, not criticism
* Ask questions if intent is unclear
* Push follow-up commits (don’t rewrite history unless asked)

---

## What Success Looks Like

* PR is small and readable
* Review focuses on design, not tooling
* CI passes on first or second run
* You understand *why* feedback was given

---

## What *Not* To Do

* ❌ Don’t push directly to main
* ❌ Don’t disable tests
* ❌ Don’t bypass architecture layers
* ❌ Don’t "fix" unrelated things

---

A clean Day-2 PR proves you can work effectively in this codebase.
Everything else builds on that.

---

## 11. Reviewer Checklist (Reviewer-Side)

For reviewers evaluating a Day-2 / first PR:

* [ ] Change is **small and scoped**
* [ ] Architecture layers are respected
* [ ] No business logic in controllers
* [ ] Tests are present and meaningful
* [ ] CI checks are green
* [ ] No unrelated refactors or formatting noise
* [ ] ADRs referenced if behavior or structure changed

If all boxes are checked, this PR is safe to merge.

---

## 12. First PR Smoke Test (CI Failures)

If CI fails on your **first PR**, check these **in order**:

* [ ] Did you run `./gradlew test` locally?
* [ ] Is Docker / Colima running?
* [ ] Is the correct Docker context active (`docker context use colima`)?
* [ ] Did Testcontainers start PostgreSQL successfully?
* [ ] Did you accidentally rely on local-only `.env` values?

If CI still fails:

* Read the **first failure**, not the last
* Paste the first `Caused by:` block into the PR
