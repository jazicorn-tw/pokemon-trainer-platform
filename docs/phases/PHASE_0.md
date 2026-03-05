# 🔰 Phase 0 — Project Skeleton & DX Infrastructure (v0.0.1)

> Goal: establish a **production-realistic Spring Boot baseline** with a full developer
> experience stack — CI/CD, quality gates, release automation, and local tooling —
> **before any domain logic is introduced**.

---

## ✅ Purpose

Phase 0 establishes the non-negotiable foundation of the system in two layers:

**Application skeleton** — the app boots, the database is wired, endpoints are verified.

**DX & infrastructure** — CI/CD, release automation, quality gates, container publishing,
and local tooling are all in place before domain work begins.

No business logic is introduced in this phase.

---

## 🎯 Outcomes

By the end of Phase 0 you will have:

* Spring Boot app that boots with PostgreSQL (Testcontainers) and Flyway
* Verified `GET /ping` and `GET /actuator/health` endpoints
* 5 GitHub Actions workflows green on `main`
* Semantic-release publishing Docker images to GHCR on every release
* Helm chart for Kubernetes deployment
* `make doctor` passing locally, pre-commit hooks installed
* `make quality` / `./gradlew clean check` as the authoritative quality gate

---

## 📄 Sub-documents

| Doc | Covers |
| --- | ------ |
| [`PHASE_0_1.md`](PHASE_0_1.md) | Spring Boot skeleton — ping, health, Testcontainers, config, runbook |
| [`PHASE_0_2.md`](PHASE_0_2.md) | CI/CD pipelines, semantic-release, Docker image publishing, Helm |
| [`PHASE_0_3.md`](PHASE_0_3.md) | Quality gates, Make system, developer scripts, local DX (act, Colima) |

---

## ✅ Definition of Done (Phase 0)

### Skeleton

* [ ] Docker/Colima running
* [ ] `contextLoads()` passes using Testcontainers PostgreSQL
* [ ] `PingControllerTest` passes
* [ ] `/ping` returns `pong`
* [ ] `/actuator/health` returns `UP`

### DX & Infrastructure

* [ ] All 5 CI workflows pass on push to `main`
* [ ] `make quality` / `./gradlew clean check` passes locally
* [ ] Pre-commit hooks installed and enforced (`make hooks`)
* [ ] `make doctor` passes with no errors
* [ ] `make check-all` passes all environment checks
* [ ] semantic-release produces a tagged release on merge to `main`
* [ ] Docker image published to GHCR on release

---

## 🔜 Next — Phase 1 Preview

With a verified skeleton and full DX stack in place, Phase 1 can focus purely
on **domain logic** — Resource CRUD and {{resource}} inventory — without any
infrastructure rewrites.

See [`PHASES.md`](PHASES.md) for Phase 1 and beyond.
