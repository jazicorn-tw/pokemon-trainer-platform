# 🧬 Phase 2 — PokeAPI Species Validation PR

> Phase 2 validates Pokémon species names against the live PokeAPI before
> allowing them to be added to a trainer's inventory.
> See [`docs/phases/PHASE_2.md`](../../docs/phases/PHASE_2.md) for the full
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
- [ ] `curl -i -X POST .../trainers/{id}/pokemon` with valid species returns **201**
- [ ] `curl -i -X POST .../trainers/{id}/pokemon` with invalid species returns **422**
- [ ] `curl -i http://localhost:8080/actuator/health` reports `UP`

---

## Phase 2 Rules (keep it clean)

### PokeAPI client

- [ ] `PokeApiClient` uses `WebClient` in **blocking** mode (`.block()`) only
- [ ] No `Mono` or `Flux` exposed in the service layer
- [ ] `pokeapi.base-url` is externalized via `application.properties`

### Error handling

- [ ] Invalid species → **422 Unprocessable Entity** (not 400 or 500)
- [ ] PokeAPI unavailable → **503 Service Unavailable** (not 500)
- [ ] Both exceptions handled in `GlobalExceptionHandler` via `ProblemDetail`

### Testing

- [ ] **No real HTTP calls** to `pokeapi.co` in any test
- [ ] Controller slice tests use `@MockitoBean PokeApiService`
- [ ] `PokeApiClient` tests use WireMock stubs
- [ ] Integration tests use WireMock or `@MockitoBean` — never live network
- [ ] All tests extend `BaseIntegrationTest` where persistence is involved
- [ ] No `@ServiceConnection` used

### Dependencies

- [ ] `spring-boot-starter-webflux` added for `WebClient` only
- [ ] No other reactive dependencies introduced

---

## New classes introduced

- [ ] `PokeApiClient` — `src/main/java/.../pokeapi/PokeApiClient.java`
- [ ] `PokeApiService` — `src/main/java/.../pokeapi/PokeApiService.java`
- [ ] `InvalidSpeciesException`
- [ ] `PokeApiUnavailableException`

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

- Confirm **no real HTTP calls** to `pokeapi.co` exist in any test
- Confirm 422 (invalid species) and 503 (unavailable) are wired correctly
- Confirm `WebClient` is used in blocking mode only — no reactive streams
- Confirm quality gates are enforced and passing
