# ✅ TODO

This file tracks **intentional, approved work**.
If it's here, it is meant to be built.

---

## 🧭 Status

- ⏳ Planned
- 🚧 In Progress
- 🧪 Experiment
- ⛔ Blocked
- ✅ Completed

---

## 🧱 Milestones / Phases

### Phase 2 — PokeAPI Species Validation (v0.2.0)

Target: validate Pokémon species against PokeAPI before adding to inventory

---

## 📝 Planned

### ⏳ PokeAPI WebClient integration

- **Category:** 🏗️ Architecture
- **Why:** Pokémon species names must be validated against PokeAPI before being added to a trainer's
  inventory. Without this, invalid species like `"notapokemon"` are accepted silently.
- **Scope:**
  - In: WebClient-based PokeAPI client, species validation on `POST /trainers/{id}/pokemon`,
    graceful handling of PokeAPI failures
  - Out: caching PokeAPI responses, storing species metadata locally, reactive streams
- **Acceptance Criteria:**
  - [ ] `POST /trainers/{id}/pokemon` with an invalid species returns 422
  - [ ] `POST /trainers/{id}/pokemon` with a valid species succeeds
  - [ ] PokeAPI is fully mocked in all tests (no real HTTP calls)
  - [ ] PokeAPI being down returns a graceful error (not 500)
  - [ ] Tests pass with `./gradlew clean check`
  - [ ] Docs updated
- **Related ADRs:** ADR-011 (modular monolith)
- **Notes:** Use WebClient in blocking mode (`.block()`). Full reactive architecture is intentionally
  deferred. New dependency: `spring-boot-starter-webflux`.

---

## 🚧 In Progress

Nothing in progress yet.

---

## 🧪 Experiments

None active.

---

## ✅ Completed

### ✅ Phase 1 — Trainers & Inventory (v0.1.0)

- **Completed:** 2026-03-04
- **Outcome:** Full CRUD for Trainer and OwnedPokemon. Layered architecture
  (Controller → Service → Domain → Repository), GlobalExceptionHandler with ProblemDetail,
  comprehensive TDD coverage across unit, controller, and integration test layers.
