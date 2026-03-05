# Testcontainers: What's Actually Going On

If you've wondered why tests require Docker, why the first run takes
several minutes, or why extending `BaseIntegrationTest` is mandatory —
this document answers those questions.

---

## What Testcontainers does

Testcontainers starts a **real Docker container** for each dependency your
tests need. In this project that means a real PostgreSQL 16 container,
not an in-memory substitute.

The container:

- starts before any test in the class runs
- accepts real SQL (including Flyway migrations)
- is torn down when the JVM exits

This is intentional. See `docs/adr/ADR-002-testcontainers.md` for the
full decision record.

---

## Why Docker must be running

There is no fallback. If Docker (or Colima) is not reachable when tests
start, Testcontainers cannot pull or launch the container and the test
JVM hangs or fails immediately.

**Symptoms of Docker being down:**

- Tests hang indefinitely at startup
- `Could not find a valid Docker environment` in output
- `Mapped port can only be obtained after the container is started`

**Fix:**

```bash
docker context list           # check which context is active
docker info                   # confirm daemon is reachable
colima start --cpu 4 --memory 8   # macOS + Colima
```

---

## Why the first run takes 1–3 minutes

On first run, Docker pulls the PostgreSQL image from the registry:

```text
postgres:16-alpine
```

After the image is cached locally, subsequent runs start the container
in seconds. If a run feels slow after the first time, Docker is usually
the cause — not Gradle or the tests themselves.

---

## How the container lifecycle works

This project uses **classic Testcontainers** — not the Spring Boot
`@ServiceConnection` shortcut.

```java
// BaseIntegrationTest.java
protected static final PostgreSQLContainer<?> POSTGRES =
    new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName(POSTGRES_DB)
        .withUsername(POSTGRES_USER)
        .withPassword(POSTGRES_PASSWORD);

@DynamicPropertySource
static void registerDatasourceProperties(DynamicPropertyRegistry registry) {
    if (!POSTGRES.isRunning()) {
        POSTGRES.start();
    }
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);
}
```

**Why `static` field?** The container is shared across all test methods
in the class. Declaring it static with `@TestInstance(PER_CLASS)` means
one container starts per test class, not per test method.

**Why `@DynamicPropertySource`?** Spring needs the JDBC URL before it
creates the datasource bean. `@DynamicPropertySource` injects properties
at the right point in the context lifecycle.

**Why manual `start()` inside the source method?** It guarantees the
container is running before Spring attempts to connect, regardless of
whether the test runner started it earlier.

---

## What is `BaseIntegrationTest` and why must I extend it

`BaseIntegrationTest` is the single source of truth for the container
setup. It lives at:

```text
src/test/java/com/{{app-name}}/platform/testinfra/BaseIntegrationTest.java
```

Every integration test that touches the database **must** extend it:

```java
@SpringBootTest(classes = PlatformApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ResourceIntegrationTest extends BaseIntegrationTest {
    // container is already configured and started
}
```

Do **not** copy the container setup into individual test classes.
That creates parallel containers, doubles memory usage, and breaks the
shared lifecycle guarantee.

---

## Allowed and banned patterns

| Pattern | Status | Reason |
| ------- | ------ | ------ |
| `static PostgreSQLContainer<?>` field | ✅ Allowed | Deterministic shared lifecycle |
| `@DynamicPropertySource` | ✅ Allowed | Required for datasource wiring |
| `extends BaseIntegrationTest` | ✅ Required | All integration tests must use it |
| `@ServiceConnection` | ❌ Banned | Opaque lifecycle, harder to debug |
| Mixing container strategies | ❌ Banned | Creates conflicting property sources |

---

## Running a single test class

```bash
./gradlew test --tests "*.ResourceIntegrationTest"
```

One container starts for that class. Docker is still required.

If running all tests:

```bash
./gradlew test
```

Containers are reused within a class but a new one starts per class that
extends `BaseIntegrationTest`. On resource-constrained machines, avoid
running the full suite in parallel.

---

## Environment variable overrides

The container image and credentials are configurable via environment
variables — useful in CI or when you need a specific Postgres version:

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `TEST_DATASOURCE_IMAGE` | `postgres:16-alpine` | PostgreSQL image tag |
| `TEST_DATASOURCE_DB` | `{{app-name}}_test` | Database name |
| `TEST_DATASOURCE_USER` | `test` | Database user |
| `TEST_DATASOURCE_PASSWORD` | `test` | Database password |

---

## Related

- `docs/adr/ADR-002-testcontainers.md` — why Testcontainers, not H2
- `docs/testing/LOCAL_TESTING.md` — full local test setup guide
- [`COMMON_FIRST_DAY_FAILURES.md`](../onboarding/COMMON_FIRST_DAY_FAILURES.md) — Docker failure fixes
