# Day-3 / Going Deeper

You have a merged PR. Day-3 is about working confidently at full speed:
running CI locally, understanding how releases are produced, knowing which test
type to reach for, and seeing what Phase 2 brings to the codebase.

---

## Goals

* Run CI workflows on your machine before pushing
* Understand the commit → release chain
* Know which test layer to reach for, and why
* See what Phase 2 adds and what is off-limits until it lands

---

## 1. Local CI simulation with `act`

`act` runs GitHub Actions workflows in Docker containers on your machine.
Use it to catch workflow failures before they reach CI.

### Prerequisites

* Docker (Colima) running
* `~/.actrc` configured — see [`docs/tooling/ACTRC.md`](../tooling/ACTRC.md)

### Make targets

```bash
make run-ci                  # run the main ci workflow
make run-ci ci               # same — explicit
make run-ci ci test          # run only the 'test' job
make run-ci ci quality       # run only the quality job
make list-ci                 # list all jobs in the ci workflow
make list-ci build-image     # list jobs in build-image workflow
```

> ⚠️ Release and publish workflows are **not intended to run locally** — they
> require GitHub App tokens. Run `make run-ci` for the CI-focused workflows only.

### How it differs from real CI

`act` is close but not identical:

* Preinstalled tool paths may differ from GitHub-hosted runners
* Secrets are not injected unless you explicitly provide them via `.secrets`
* Some steps are gated behind `env.ACT` to keep local runs stable

📄 Full reference: [`docs/devops/ci/act/ACT_OVERVIEW.md`](../devops/ci/act/ACT_OVERVIEW.md)
📄 Command cheat sheet: [`docs/devops/ci/act/ACT_COMMANDS.md`](../devops/ci/act/ACT_COMMANDS.md)

---

## 2. How releases work

This repo uses **semantic-release** to produce releases automatically on every
merge to `main`. You do not trigger releases manually.

### Commit type → version bump

| Commit prefix | Example | Bump |
| ------------- | ------- | ---- |
| `fix:` | `fix(trainer): handle null username` | patch (0.0.x) |
| `feat:` | `feat(pokemon): add nickname field` | minor (0.x.0) |
| `feat!:` / `BREAKING CHANGE:` | `feat!: rename trainer endpoint` | major (x.0.0) |
| `chore:`, `docs:`, `test:` | `docs(onboarding): fix broken link` | no release |

### What a release produces

1. A git tag (`v1.2.3`)
2. A GitHub Release with generated release notes
3. A `CHANGELOG.md` entry
4. A Docker image published to GHCR

### Preview the next release locally

```bash
make release-dry-run
```

Runs semantic-release in dry-run mode — shows the computed next version and
what the release notes would look like, without creating a tag or publishing.

---

## 3. Test pattern reference

Reach for the lowest layer that covers the behaviour you are testing.

| What you are testing | Layer | Tooling |
| -------------------- | ----- | ------- |
| Business rules, no I/O | Service unit | JUnit 5 + Mockito |
| HTTP request/response contract | Controller slice | `@WebMvcTest` + `@MockitoBean` |
| Database persistence | Integration | `BaseIntegrationTest` (Testcontainers) |
| External HTTP client (Phase 2+) | Client unit | WireMock stubs |

### Rules

* Controller tests use `@MockitoBean` on the service — no real database
* Integration tests extend `BaseIntegrationTest` — required, not optional
* No test makes a real HTTP call to external services
* Test methods use **camelCase only** — no underscores (Checkstyle `MethodName`)

### Running tests

```bash
./gradlew test                      # all tests (requires Docker)
./gradlew test --tests "*.TrainerServiceTest"  # single class
```

📄 Details: [`docs/testing/LOCAL_TESTING.md`](../testing/LOCAL_TESTING.md)

---

## 4. Phase 2 preview — PokeAPI species validation

Phase 2 is the next active development target. Here is what lands and what it
means for your PRs now.

### What Phase 2 adds

* `PokeApiClient` — WebClient-based HTTP client for `pokeapi.co`
* `PokeApiService` — validation facade called by `OwnedPokemonService`
* Species validation on `POST /api/trainers/{id}/pokemon`
* New responses: **422** (invalid species), **503** (PokeAPI down)
* New dependency: `spring-boot-starter-webflux` (WebClient only, blocking)
* New test tooling: WireMock for stubbing HTTP responses

### Architecture change

```text
OwnedPokemonController
  └─ OwnedPokemonService
       └─ PokeApiService          ← Phase 2 addition
            └─ PokeApiClient      ← Phase 2 addition (WebClient, blocking)
```

### What is off-limits in PRs right now

* Do **not** implement `PokeApiClient` or `PokeApiService` ahead of Phase 2
* Do **not** add `spring-boot-starter-webflux` to `build.gradle` yet
* Do **not** add WireMock as a test dependency yet

📄 Full TDD walkthrough: [`docs/phases/PHASE_2.md`](../phases/PHASE_2.md)

---

## 5. Useful references for daily work

| Topic | Doc |
| ----- | --- |
| Architecture layers | [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) |
| All ADRs | [`docs/adr/README.md`](../adr/README.md) |
| Commit format | [`docs/commit/COMMITIZEN.md`](../commit/COMMITIZEN.md) |
| Quality gates | [`docs/adr/ADR-000-linting.md`](../adr/ADR-000-linting.md) |
| Testcontainers setup | [`docs/testing/LOCAL_TESTING.md`](../testing/LOCAL_TESTING.md) |
| CI troubleshooting | [`docs/testing/CI_TROUBLESHOOTING.md`](../testing/CI_TROUBLESHOOTING.md) |
| act setup | [`docs/tooling/ACTRC.md`](../tooling/ACTRC.md) |
| Contributing guide | [`CONTRIBUTING.md`](../../CONTRIBUTING.md) |
| Phase roadmap | [`docs/phases/ROADMAP.md`](../phases/ROADMAP.md) |

---

A Day-3 contributor understands the full loop: code → commit → CI → release.
Everything from here is just iteration.
