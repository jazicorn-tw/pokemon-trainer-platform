# Testing Setup Guide

> Spring Boot 4 + Gradle + JUnit 5 + PostgreSQL + Testcontainers + Flyway (macOS + Colima friendly)

This doc explains how to **set up integration testing from scratch** for this repo.
It focuses on **repeatable local setup** and a **single authoritative wiring** for Testcontainers.

## What You Get

✅ Integration tests that boot Spring and talk to a real PostgreSQL container
✅ Flyway migrations run automatically against the container DB
✅ Works on macOS (Docker Desktop **or** Colima) and in CI
✅ No hardcoded credentials in test config

## Prerequisites

### 1. Java & Gradle

* Java **21**
* Gradle Wrapper (`./gradlew`)

Verify:

```bash
java -version
./gradlew -v
```

---

### 2. Container runtime

You need **one**:

* Docker Desktop, OR
* Colima (recommended on macOS)

Verify Docker works:

```bash
docker ps
```

If `docker ps` fails → fix Docker/Colima first (see `DOCKER.md` / `COLIMA.md`).

## Required Dependencies (Gradle)

Add these to `build.gradle` (or confirm they exist):

```gradle
dependencies {
  // App deps
  implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
  implementation 'org.springframework.boot:spring-boot-starter-validation'
  implementation 'org.springframework.boot:spring-boot-starter-web'

  // Flyway
  implementation 'org.flywaydb:flyway-core'

  // Test: Spring + JUnit 5
  testImplementation 'org.springframework.boot:spring-boot-starter-test'

  // Testcontainers
  testImplementation 'org.testcontainers:junit-jupiter'
  testImplementation 'org.testcontainers:postgresql'
}
```

## Folder & File Layout

```txt
src/
  main/
    resources/
      db/migration/
        V1__init.sql
  test/
    java/com/pokedex/inventory/
      BaseIntegrationTest.java
      InventoryApplicationTests.java
    resources/
      application-test.properties
```

## Flyway Migrations (Authoritative)

All migrations live here:

```txt
src/main/resources/db/migration/
```

Example:

```sql
-- V1__init.sql
CREATE TABLE example (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL
);
```

Flyway runs automatically during test startup.

## Authoritative Testcontainers Wiring

This project uses **classic Testcontainers only**:

* JUnit 5 + `@Testcontainers`
* Static `@Container` PostgreSQL container
* Datasource injected via `@DynamicPropertySource`
* Spring Boot does **not** manage container lifecycle
* Flyway runs against the container DB

❌ `@ServiceConnection` is **not allowed**
❌ Do not mix container strategies

## Base Integration Test

```java
package com.pokedex.inventory;

import org.junit.jupiter.api.BeforeAll;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@ActiveProfiles("test")
public abstract class BaseIntegrationTest {

  @Container
  @SuppressWarnings("resource")
  static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>("postgres:16-alpine")
          .withDatabaseName("testdb")
          .withUsername("test")
          .withPassword("test");

  @BeforeAll
  static void ensureContainerRunning() {
    POSTGRES.start();
  }

  @DynamicPropertySource
  static void registerProps(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);

    registry.add("spring.flyway.url", POSTGRES::getJdbcUrl);
    registry.add("spring.flyway.user", POSTGRES::getUsername);
    registry.add("spring.flyway.password", POSTGRES::getPassword);
  }
}
```

## Smoke Test

```java
package com.pokedex.inventory;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class InventoryApplicationTests extends BaseIntegrationTest {

  @Test
  void contextLoads() {}
}
```

## Test Profile

`src/test/resources/application-test.properties`

```properties
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
logging.level.org.hibernate.SQL=debug
```

❌ Do not hardcode datasource credentials.

## Running Tests

```bash
./gradlew cleanTest test
```

With diagnostics:

```bash
./gradlew test --stacktrace --info
```

## macOS + Colima Quick Setup

```bash
unset DOCKER_HOST
colima start
docker context use colima
docker ps
./gradlew cleanTest test
```

## Common Setup Errors

### Docker not found

```text
Could not find a valid Docker environment
```

➡ Docker/Colima not running or socket misconfigured

---

### Mapped port error

```text
Mapped port can only be obtained after the container is started
```

➡ Mixed Testcontainers strategies (not allowed in this project)

## Why This Wiring Exists (Read Before Refactoring)

This project **intentionally** uses classic Testcontainers wiring.

### The Problem This Solves

Spring Boot 3.1+ introduced `@ServiceConnection`, which *looks* simpler but:

* Hides container lifecycle from the test author
* Breaks when mixing Flyway, custom datasources, or multiple containers
* Produces non-obvious failures ("mapped port not available", race conditions)
* Makes CI and local behavior diverge

### Our Chosen Strategy (Intentional)

We explicitly:

* Own the container lifecycle in test code
* Inject datasource + Flyway properties manually
* Keep Spring Boot unaware of container creation

This guarantees:

* Deterministic startup order
* Flyway always runs against the correct database
* Identical behavior locally and in CI
* Easier debugging when Docker/Testcontainers fail

### ❌ Do Not Change Without Updating Docs

If you:

* Switch to `@ServiceConnection`
* Add a managed datasource bean
* Add a CI-provided Postgres service

You **must** update:

* `TESTING.md`
* `./testing/CI_TROUBLESHOOTING.md` (errors guide)
* CI configuration

Otherwise, future contributors will break tests unintentionally.

## CI Appendix

### Recommended CI Strategy

Use **Testcontainers in CI** exactly as locally.

Do **not**:

* Add a `services:` Postgres container
* Inject database credentials via CI env vars

Why?

* Testcontainers already provisions Postgres
* One strategy = fewer environment-specific bugs

---

### Minimal CI Step Example (GitHub Actions)

```yaml
- name: Run tests
  run: ./gradlew cleanTest test
```

---

### CI Requirements

* Docker available on the runner
* No `DOCKER_HOST` overrides

---

### Debugging CI Failures

If CI fails but local passes:

* Compare Docker availability
* Check logs for Ryuk startup
* Ensure no competing Postgres service is defined

## Cross-References

* Setup & wiring: `TESTING.md` (this file)
* Error diagnostics: [CI_TROUBLESHOOTING](CI_TROUBLESHOOTING.md)
* Docker issues: [DOCKER](errors/DOCKER.md)
* Colima issues (macOS): [COLIMA](errors/COLIMA.md)
* Testcontainers issues: [TESTCONTAINERS](errors/TESTCONTAINERS.md)

## When Tests Fail — Paste This

```bash
docker ps
docker context show
echo $DOCKER_HOST
colima status
./gradlew test --stacktrace --info
```

And paste the **first `Caused by:` block**, for example:

```text
Caused by: java.lang.IllegalStateException: Could not find a valid Docker environment
    at org.testcontainers.dockerclient.DockerClientProviderStrategy.getFirstValidStrategy(...)
    ...
```
