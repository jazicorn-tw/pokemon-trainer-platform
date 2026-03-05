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

### GitHub App secrets for `act` (advanced)

If you need to run a workflow locally that authenticates as the GitHub App
(e.g. release gating, token generation), `act` must receive the private key as
a single-line value. The PEM file is multiline, so it must be base64-encoded first.

**One-time setup:**

```bash
# Encode the private key from .secrets into a single-line b64 file
# Replace the path with wherever you store your GitHub App PEM
base64 github-app.pem | tr -d '\n' > .tmp_key.b64
```

Then set `GH_APP_PRIVATE_KEY` in `.secrets` to the contents of `.tmp_key.b64`:

```bash
# Read the encoded key into .secrets
echo "GH_APP_PRIVATE_KEY=$(cat .tmp_key.b64)" >> .secrets
```

> ⚠️ `.tmp_key.b64` is a secret. Never commit it. Delete it after use.
> Base64 is encoding, not encryption — the key is still sensitive.

📄 Full reference: [`docs/devops/ci/act/SECRETS.md`](../devops/ci/act/SECRETS.md)

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
| `fix:` | `fix(resource): handle null username` | patch (0.0.x) |
| `feat:` | `feat({{resource}}): add nickname field` | minor (0.x.0) |
| `feat!:` / `BREAKING CHANGE:` | `feat!: rename resource endpoint` | major (x.0.0) |
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
| Database persistence | Integration | `AbstractIntegrationTest` (Testcontainers) |
| External HTTP client (Phase 2+) | Client unit | WireMock stubs |

### Rules

* Controller tests use `@MockitoBean` on the service — no real database
* Integration tests extend `AbstractIntegrationTest` — required, not optional
* No test makes a real HTTP call to external services
* Test methods use **camelCase only** — no underscores (Checkstyle `MethodName`)

### Running tests

```bash
./gradlew test                      # all tests (requires Docker)
./gradlew test --tests "*.ResourceServiceTest"  # single class
```

📄 Details: [`docs/testing/LOCAL_TESTING.md`](../testing/LOCAL_TESTING.md)

---

## 4. Phase 2 preview — external API integration

Phase 2 is the next active development target. Here is what lands and what it
means for your PRs now.

### What Phase 2 adds

* `ExternalClient` — HTTP client for the external validation/enrichment API
* `ExternalService` — validation facade called by the domain service
* Validation wired into the relevant POST endpoints
* New responses: **422** (invalid input), **503** (external API down)
* New test tooling: HTTP stubs (e.g. WireMock) for stubbing external calls

### Architecture change

```text
ResourceController
  └─ ResourceService
       └─ ExternalService          ← Phase 2 addition
            └─ ExternalClient      ← Phase 2 addition (HTTP client)
```

### What is off-limits in PRs right now

* Do **not** implement `ExternalClient` or `ExternalService` ahead of Phase 2
* Do **not** add Phase 2 dependencies to the build yet
* Do **not** add HTTP stub dependencies yet

---

## 5. Useful references for daily work

| Topic | Doc |
| ----- | --- |
| Architecture layers | [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) |
| All ADRs | [`docs/adr/README.md`](../adr/README.md) |
| Commit format | [`docs/commit/COMMITIZEN.md`](../commit/COMMITIZEN.md) |
| Quality gates | [`docs/adr/ADR-000-linting.md`](../adr/ADR-000-linting.md) |
| Testcontainers setup | [`docs/testing/LOCAL_TESTING.md`](../testing/LOCAL_TESTING.md) |
| Testcontainers deep dive | [`docs/faq/TESTCONTAINERS_EXPLAINED.md`](../faq/TESTCONTAINERS_EXPLAINED.md) |
| Flyway migrations | [`docs/faq/FLYWAY_MIGRATIONS_EXPLAINED.md`](../faq/FLYWAY_MIGRATIONS_EXPLAINED.md) |
| CI troubleshooting | [`docs/testing/CI_TROUBLESHOOTING.md`](../testing/CI_TROUBLESHOOTING.md) |
| act setup | [`docs/tooling/ACTRC.md`](../tooling/ACTRC.md) |
| act secrets | [`docs/devops/ci/act/SECRETS.md`](../devops/ci/act/SECRETS.md) |
| Contributing guide | [`CONTRIBUTING.md`](../../CONTRIBUTING.md) |
| Phase roadmap | [`docs/phases/ROADMAP.md`](../phases/ROADMAP.md) |

---

A Day-3 contributor understands the full loop: code → commit → CI → release.
Everything from here is just iteration.
