<!-- markdownlint-disable-file MD024 -->
# `/ping` vs `/health` (Actuator) — What’s the Difference?

This document explains **why `/ping` and `/health` both exist**, what problem each one solves,
and how they should be wired in a **Spring Boot 4** application.

---

## High-level overview

| Endpoint | Purpose | Dependencies | Intended audience |
| -------- | -------- | -------------- | ------------------- |
| `/ping` | “Is the process alive?” | **None** | Load balancers, CI smoke tests |
| `/health` | “Is the app healthy?” | **Many** (DB, disk, etc.) | Ops, monitoring, SRE |

Think of it as:

> **`/ping` = liveness**  
> **`/health` = readiness + health**

They solve **different problems** and are **not interchangeable**.

---

## `/ping` — Application liveness

### What `/ping` does

- Confirms the **application process is running**
- Confirms **Spring routing works**
- Confirms the **context loaded**
- Makes **no external calls**
- Never touches DB, cache, or APIs

### Example

```http
GET /ping
````

```json
{
  "status": "ok",
  "service": "{{app-name}}-api"
}
```

### When `/ping` should return `200`

- The JVM is running
- Spring Boot started successfully

### When `/ping` should fail

- The app crashed
- The app failed to start

### Design rules

- Must be **fast**
- Must be **reliable**
- Must **never depend on infrastructure**
- Must **never flake**

### Typical usage

- Load balancer health checks
- CI smoke tests
- Cloudflare uptime checks
- Kubernetes **liveness probes**

---

## `/health` — Actuator health & readiness

### What `/health` does

- Aggregates **HealthIndicators**
- Reports the status of:

  - Database connectivity
  - Disk space
  - Flyway migrations
  - Custom checks
  - (Optionally) external APIs

### Example

```http
GET /actuator/health
```

```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "diskSpace": { "status": "UP" },
    "ping": { "status": "UP" }
  }
}
```

### When `/health` should return `DOWN`

- Database is unreachable
- Migrations failed
- Disk is full
- A critical dependency is unavailable

### Design rules

- Infrastructure-aware
- Can be slow
- Can be flaky (by design)
- Intended for monitoring systems

### Typical usage

- Monitoring & alerting
- Readiness checks
- Ops dashboards
- Kubernetes **readiness probes**

---

## Key architectural difference

### `/ping`

- Implemented by **your code**
- Simple controller
- Zero dependencies
- Always safe to call

### `/health`

- Provided by **Spring Boot Actuator**
- Pluggable health indicators
- Infrastructure-dependent
- Reflects system readiness

---

## Why you should use BOTH

| Scenario                      | Endpoint  |
| ----------------------------- | --------- |
| App is running?               | `/ping`   |
| App ready to receive traffic? | `/health` |
| Load balancer check           | `/ping`   |
| CI smoke test                 | `/ping`   |
| Monitoring & alerting         | `/health` |
| Kubernetes liveness probe     | `/ping`   |
| Kubernetes readiness probe    | `/health` |

Using only one leads to **false positives** or **false negatives**.

---

## Recommended wiring (Spring Boot 4)

### `/ping` controller (liveness)

```java
@RestController
public class PingController {

  @GetMapping("${PING_PATH:/ping}")
  public Map<String, String> ping() {
    return Map.of(
        "status", "ok",
        "service", System.getenv().getOrDefault("SERVICE_NAME", "{{app-name}}-api")
    );
  }
}
```

**Rules enforced here:**

- No DB calls
- No injected repositories
- No external dependencies

---

### Actuator configuration

#### Dependency

```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

#### Exposure

```properties
management.endpoints.web.exposure.include=health,info
```

This exposes:

- `/actuator/health`
- `/actuator/info`

---

### Optional: liveness & readiness probes

```properties
management.endpoint.health.probes.enabled=true
management.health.livenessState.enabled=true
management.health.readinessState.enabled=true
```

Endpoints:

- `/actuator/health/liveness`
- `/actuator/health/readiness`

---

## What NOT to do

❌ Don’t use `/health` as a liveness probe
❌ Don’t make `/ping` check the database
❌ Don’t expose all Actuator endpoints publicly
❌ Don’t return `500` from `/ping` because DB is down

---

## Cloudflare / Pages note

Cloudflare Pages and edge platforms:

- Expect **simple, fast health checks**
- Do not understand Actuator semantics

**Best practice:**

- Use `/ping` for Cloudflare health checks
- Use `/actuator/health` internally or behind auth

---

## TL;DR

| Question                                | Answer    |
| --------------------------------------- | --------- |
| Do I need both?                         | **Yes**   |
| Is `/ping` redundant?                   | **No**    |
| Should `/ping` touch DB?                | **Never** |
| Should `/health` touch DB?              | **Yes**   |
| Which endpoint can fail during outages? | `/health` |

---

## Final rule of thumb

> If it’s about **“is the process alive?” → `/ping`**
> If it’s about **“can the system safely operate?” → `/health`**
