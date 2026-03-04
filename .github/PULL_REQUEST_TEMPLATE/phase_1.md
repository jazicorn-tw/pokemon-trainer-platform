# 🐣 Phase 1 — Trainers & Inventory PR

> Phase 1 introduces the core domain: Trainer and OwnedPokemon CRUD,
> validation, and structured error responses using strict TDD on top of
> the Phase 0 skeleton.
> See [`docs/phases/PHASE_1.md`](../../docs/phases/PHASE_1.md) for the full
> TDD walkthrough.

---

## Summary

-

---

## Quality Gates (ADR-000) — Required

- [ ] `./gradlew clean check` passes locally
- [ ] No linting rules disabled or bypassed
- [ ] Static analysis reports reviewed (no unexpected violations)
- [ ] CI quality gate passes

---

## Evidence (required)

- [ ] `./gradlew test` passes (Docker / Colima running)
- [ ] `curl -i -X POST .../trainers` with valid body returns **201**
- [ ] `curl -i -X GET .../trainers/{id}` returns **200**
- [ ] `curl -i -X POST .../trainers/{id}/pokemon` with valid body returns **201**
- [ ] `curl -i -X GET .../trainers/{id}/pokemon` returns **200**
- [ ] `curl -i http://localhost:8080/actuator/health` reports `UP`

---

## Phase 1 Rules (keep it clean)

### Domain

- [ ] `Trainer` and `OwnedPokemon` are the only entities introduced
- [ ] No PokeAPI calls — species validation is off-limits until Phase 2
- [ ] No `spring-boot-starter-webflux` or WireMock added
- [ ] `V1__init.sql` is **not modified** — schema was established in Phase 0

### Error handling

- [ ] `TrainerNotFoundException` / `OwnedPokemonNotFoundException` → **404**
- [ ] `MethodArgumentNotValidException` → **400**
- [ ] `DataIntegrityViolationException` (duplicate username) → **409**
- [ ] All exceptions handled in `GlobalExceptionHandler` via `ProblemDetail` (RFC 7807)

### Testing

- [ ] Service-layer tests use **JUnit 5 + Mockito** — no Spring context loaded
- [ ] Controller slice tests use `@WebMvcTest` + `@MockitoBean` — no real database
- [ ] Integration tests extend `BaseIntegrationTest` (Testcontainers)
- [ ] No `@ServiceConnection` used
- [ ] No real HTTP calls to external services in any test
- [ ] Test method names are **camelCase only** — no underscores (Checkstyle `MethodName`)

---

## New classes introduced

### Trainer domain

- [ ] `Trainer` — `src/main/java/.../trainer/Trainer.java`
- [ ] `TrainerRepository` — `src/main/java/.../trainer/TrainerRepository.java`
- [ ] `TrainerService` — `src/main/java/.../trainer/TrainerService.java`
- [ ] `TrainerController` — `src/main/java/.../trainer/TrainerController.java`
- [ ] `TrainerNotFoundException`

### OwnedPokemon domain

- [ ] `OwnedPokemon` — `src/main/java/.../pokemon/OwnedPokemon.java`
- [ ] `OwnedPokemonRepository` — `src/main/java/.../pokemon/OwnedPokemonRepository.java`
- [ ] `OwnedPokemonService` — `src/main/java/.../pokemon/OwnedPokemonService.java`
- [ ] `OwnedPokemonController` — `src/main/java/.../pokemon/OwnedPokemonController.java`
- [ ] `OwnedPokemonNotFoundException`

### Shared

- [ ] `GlobalExceptionHandler`

---

## 🏛 Phase-gate ADRs (must be accepted)

- [ ] ADR-001 — PostgreSQL everywhere (no H2)
- [ ] ADR-002 — Testcontainers for integration testing
- [ ] ADR-003 — Actuator health endpoints + Docker healthchecks

---

### ADRs referenced / modified (if any)

- ADR-___

---

## Files / areas touched

-

---

## Notes for reviewers

- Confirm **no PokeAPI calls** exist anywhere in the implementation
- Confirm `GlobalExceptionHandler` returns `ProblemDetail` for 400, 404, and 409
- Confirm `@MockitoBean` (not `@MockBean`) is used in all controller slice tests
- Confirm integration tests extend `BaseIntegrationTest` — no standalone `@SpringBootTest`
- Confirm `V1__init.sql` was not modified
- Confirm quality gates are enforced and passing
