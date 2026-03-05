# 🐣 Phase 1 — Resources & Inventory PR

> Phase 1 introduces the core domain: Resource and {{Resource}} CRUD,
> validation, and structured error responses using strict TDD on top of
> the Phase 0 skeleton.

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
- [ ] `curl -i -X POST .../resources` with valid body returns **201**
- [ ] `curl -i -X GET .../resources/{id}` returns **200**
- [ ] `curl -i -X POST .../resources/{id}/{{resource}}` with valid body returns **201**
- [ ] `curl -i -X GET .../resources/{id}/{{resource}}` returns **200**
- [ ] `curl -i http://localhost:8080/actuator/health` reports `UP`

---

## Phase 1 Rules (keep it clean)

### Domain

- [ ] `Resource` and `{{Resource}}` are the only entities introduced
- [ ] No {{external-api}} calls — species validation is off-limits until Phase 2
- [ ] No `spring-boot-starter-webflux` or WireMock added
- [ ] `V1__init.sql` is **not modified** — schema was established in Phase 0

### Error handling

- [ ] `ResourceNotFoundException` / `{{Resource}}NotFoundException` → **404**
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

### Resource domain

- [ ] `Resource` — `src/main/java/.../resource/Resource.java`
- [ ] `ResourceRepository` — `src/main/java/.../resource/ResourceRepository.java`
- [ ] `ResourceService` — `src/main/java/.../resource/ResourceService.java`
- [ ] `ResourceController` — `src/main/java/.../resource/ResourceController.java`
- [ ] `ResourceNotFoundException`

### {{Resource}} domain

- [ ] `{{Resource}}` — `src/main/java/.../{{resource}}/{{Resource}}.java`
- [ ] `{{Resource}}Repository` — `src/main/java/.../{{resource}}/{{Resource}}Repository.java`
- [ ] `{{Resource}}Service` — `src/main/java/.../{{resource}}/{{Resource}}Service.java`
- [ ] `{{Resource}}Controller` — `src/main/java/.../{{resource}}/{{Resource}}Controller.java`
- [ ] `{{Resource}}NotFoundException`

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

- Confirm **no {{external-api}} calls** exist anywhere in the implementation
- Confirm `GlobalExceptionHandler` returns `ProblemDetail` for 400, 404, and 409
- Confirm `@MockitoBean` (not `@MockBean`) is used in all @WebMvcTest + MockMvc
- Confirm integration tests extend `BaseIntegrationTest` — no standalone `@SpringBootTest`
- Confirm `V1__init.sql` was not modified
- Confirm quality gates are enforced and passing
