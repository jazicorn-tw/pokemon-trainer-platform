# 🔰 Phase 0.1 — Spring Boot Skeleton

> Part of [Phase 0](PHASE_0.md). Covers the application baseline: boot, database,
> and HTTP endpoint verification.

---

## ⚠️ Test Requirement (Read First)

**Phase 0 integration tests REQUIRE a running Docker engine (or Colima on macOS).**

This project uses **Testcontainers with PostgreSQL** starting in Phase 0 to ensure:

* production-parity database behavior
* early detection of schema/migration issues
* no divergence between test and real environments

If Docker/Colima is not running, `./gradlew test` **will fail** for integration tests.

> Note: **not every test needs Docker**. MVC slice tests (like `/ping`) are intentionally DB-free.

---

## ✅ Purpose

Establish a runnable, testable Spring Boot 4 service:

* Spring Boot application boots cleanly
* PostgreSQL is wired consistently across environments
* Flyway is active from day one
* HTTP + health endpoints are verifiable
* Tests fail for real reasons (not misconfiguration)

---

## 🎯 Outcomes

* A passing **context-load** integration test backed by PostgreSQL (Testcontainers)
* A verified `GET /ping` endpoint that returns `pong`
* A verified `GET /actuator/health` endpoint that returns `UP`
* A clean baseline for Phase 1 domain work

---

## 🧪 TDD Flow

> 🐳 Before running any tests:
>
> ```bash
> docker ps
> ```
>
> If this fails (macOS):
>
> ```bash
> colima start
> docker context use colima
> ```

---

### 1️⃣ Context Load Test (Infrastructure Proof)

This test proves that:

* component scanning works
* auto-configuration is valid
* database + Flyway wiring is correct
* the application can **actually start**

Integration tests extend a shared Testcontainers base:
`com.{{app-name}}.platform.testinfra.BaseIntegrationTest`.

That base class:

* defines a `@Container` PostgreSQL Testcontainer
* starts it defensively (to avoid early Spring condition-check evaluation issues)
* registers datasource properties via `@DynamicPropertySource`

**File**
`src/test/java/com/{{app-name}}/platform/PlatformApplicationTest.java`

```java
package com.{{app-name}}.platform;

import com.{{app-name}}.platform.testinfra.BaseIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class PlatformApplicationTest extends BaseIntegrationTest {

  @Test
  void contextLoads() {
    // Fails if Spring, DB, or Flyway are misconfigured
  }
}
```

✅ **Expected result**: passes only if Docker + Testcontainers are working.

> Schema behavior (Flyway + JPA validate, etc.) is owned by `application-test.yml`
> to avoid duplicate configuration sources.

---

### 2️⃣ Failing HTTP Test — `/ping`

This test verifies the HTTP boundary **without** starting a full server
and **without touching the database**.

**File**
`src/test/java/com/{{app-name}}/platform/ping/PingControllerTest.java`

```java
package com.{{app-name}}.platform.ping;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(PingController.class)
class PingControllerTest {

  @Autowired
  MockMvc mockMvc;

  @Test
  void pingReturnsPong() throws Exception {
    mockMvc.perform(get("/ping"))
        .andExpect(status().isOk())
        .andExpect(content().string("pong"));
  }
}
```

❌ **Expected result initially**: fails — controller doesn't exist yet.

> If Spring Security is introduced later and this test starts failing due to filters,
> either disable filters for this slice test or import the security config explicitly.

---

### 3️⃣ Minimal Controller (Green)

**File**
`src/main/java/com/{{app-name}}/platform/ping/PingController.java`

```java
package com.{{app-name}}.platform.ping;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class PingController {

  @GetMapping("/ping")
  String ping() {
    return "pong";
  }
}
```

✅ **Expected result**: test passes.

---

## 📦 Dependencies (Skeleton Baseline)

```gradle
dependencies {
  implementation 'org.springframework.boot:spring-boot-starter-web'
  implementation 'org.springframework.boot:spring-boot-starter-actuator'
  implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
  implementation 'org.springframework.boot:spring-boot-starter-validation'

  implementation 'org.flywaydb:flyway-core'
  runtimeOnly 'org.postgresql:postgresql'

  testImplementation 'org.springframework.boot:spring-boot-starter-test'
  testImplementation 'org.testcontainers:junit-jupiter'
  testImplementation 'org.testcontainers:postgresql'
}
```

---

## ⚙️ Configuration (PostgreSQL-First)

**File** `src/main/resources/application.properties`

```properties
spring.application.name=platform-service

spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

spring.jpa.open-in-view=false
spring.jpa.hibernate.ddl-auto=validate

spring.flyway.enabled=true
spring.flyway.locations=${FLYWAY_LOCATIONS:classpath:db/migration}

management.endpoints.web.exposure.include=health,info
```

> Tests do **not** need these environment variables — Testcontainers provides
> datasource properties dynamically via `@DynamicPropertySource`.

---

## ▶️ Runbook

```bash
# Run tests (requires Docker/Colima)
docker ps
./gradlew test

# Run the app locally (docker-compose PostgreSQL)
docker compose up -d postgres
export SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:5432/{{app-name}}"
export SPRING_DATASOURCE_USERNAME="postgres"
export SPRING_DATASOURCE_PASSWORD="postgres"
./gradlew bootRun

# Validate endpoints
curl -i http://localhost:8080/ping
curl -i http://localhost:8080/actuator/health
```

---

## 🧯 Troubleshooting

```bash
# Docker context mismatch
docker context use colima

# Testcontainers + Colima
DOCKER_HOST=unix:///Users/<you>/.colima/default/docker.sock \
TESTCONTAINERS_RYUK_DISABLED=true \
./gradlew test
```

See `docs/environment/local/TROUBLESHOOTING.md` and `docs/environment/local/COLIMA.md`.

---

← Back to [Phase 0 overview](PHASE_0.md) | Next: [Phase 0.2 — CI/CD & Release](PHASE_0_2.md)
