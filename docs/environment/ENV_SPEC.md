<!-- markdownlint-disable-file MD060 -->
<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# ✅ ENV Spec - Environment Configuration

This document defines **feature flags** and **runtime environment variables**
used across CI, local development, Render, and future Kubernetes deployments.

> **Security note**
> This file intentionally documents **variable names and behavior only**.
> Secret values must be provided via platform secret managers and must never
> be committed to source control.

---

## ⚡ Environment Variables — Quick Reference

### 🔀 CI Feature Flags (GitHub Actions)

**Purpose:** Control *when* CI publishes artifacts or performs deployments, without code changes.  
🔗 See details: **[CI Feature Flags](#-ci-feature-flags-github-actions)**

```text
PUBLISH_DOCKER_IMAGE     # optional — true|false — enable Docker image publishing on releases
CANONICAL_REPOSITORY     # required* — <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART       # optional — true|false — enable Helm chart publishing (future)
DEPLOY_ENABLED           # optional — true|false — global deployment kill switch (future)

ENABLE_SEMANTIC_RELEASE  # optional — true|false — gate semantic-release execution
```

\* Required **only when artifact publishing is enabled**
(`PUBLISH_DOCKER_IMAGE=true` or `PUBLISH_HELM_CHART=true`)

---

### 🌐 Application Runtime (All Environments)

**Purpose:** Define core runtime behavior consistently across local, Render, and Kubernetes.  
🔗 See details: **[Application runtime](#-application-runtime-all-environments-1)**

```text
SPRING_PROFILES_ACTIVE   # required — dev|test|prod — active Spring profile
SERVER_PORT              # optional — override default server port

SPRING_APPLICATION_NAME  # optional — app identity in logs/metrics
SPRING_MAIN_BANNER_MODE  # optional — off|console|log — reduce noise in CI
```

---

### 🗄️ Database (PostgreSQL)

**Purpose:** Configure database connectivity for the application and Flyway migrations.  
🔗 See details: **[Database (PostgreSQL)](#️-database-postgresql-1)**

```text
SPRING_DATASOURCE_URL         # required — JDBC connection URL (may include SSL params)
SPRING_DATASOURCE_USERNAME    # required — database username
SPRING_DATASOURCE_PASSWORD    # required — database password (secret)

SPRING_DATASOURCE_DRIVER_CLASS_NAME          # optional — force driver (usually auto-detected)
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE   # optional — connection pool sizing
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE        # optional — connection pool sizing
SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT  # optional — pool timeout tuning
```

---

### 🧭 Flyway (Migrations)

**Purpose:** Control Flyway behavior per environment (especially prod startup policy).  
🔗 See details: **[Flyway](#-flyway-migrations)**

```text
SPRING_FLYWAY_ENABLED             # optional — true|false — enable/disable migrations
SPRING_FLYWAY_BASELINE_ON_MIGRATE # optional — true|false — baseline existing schema
SPRING_FLYWAY_LOCATIONS           # optional — override migration locations
```

---

### 🔐 Security / Authentication

**Purpose:** Control JWT-based authentication and token behavior.  
🔗 See details: **[Security / Authentication](#-security--authentication)**

```text
JWT_SECRET               # required — JWT signing secret (secret)
JWT_EXPIRATION_SECONDS   # optional — token lifetime override

JWT_ISSUER               # optional* — expected issuer
JWT_AUDIENCE             # optional* — expected audience
```

\* Optional **until** issuer/audience validation is implemented. If you enforce these checks, they become required.

---

### 🩺 Observability / Health

**Purpose:** Expose health and probe endpoints for platforms and orchestrators.  
🔗 See details: **[Observability / Health](#-observability--health)**

```text
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE    # optional — actuator endpoints to expose
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED   # optional — enable readiness/liveness probes
MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS     # optional — never|when_authorized|always
MANAGEMENT_SERVER_PORT                      # optional — run actuator on separate port
MANAGEMENT_HEALTH_DB_ENABLED                # optional — true|false — DB health contributor toggle
```

---

### 🧾 Logging

**Purpose:** Adjust verbosity and formatting per environment without rebuilding.  
🔗 See details: **[Logging](#-logging)**

```text
LOGGING_LEVEL_ROOT          # optional — e.g. INFO|DEBUG|WARN
LOGGING_LEVEL_COM_POKEDEX   # optional — package-level override (example)
LOGGING_PATTERN_CONSOLE    # optional — customize console output
```

---

## ✅ Minimal required per environment

Legend: ✅ required, ⚪ optional, — not used / not applicable

### Runtime variables

| Variable | Local (dev) | CI (tests) | Render (prod) | K8s (prod) | Notes |
|---|---:|---:|---:|---:|---|
| `SPRING_PROFILES_ACTIVE` | ✅ | ✅ | ✅ | ✅ | Usually `dev` / `test` / `prod` |
| `SERVER_PORT` | ⚪ | — | ⚪ | ⚪ | Often provided by platform; override only if needed |
| `SPRING_APPLICATION_NAME` | ⚪ | ⚪ | ⚪ | ⚪ | Useful for logs/metrics |
| `SPRING_MAIN_BANNER_MODE` | ⚪ | ✅ | ⚪ | ⚪ | Often `off` in CI |
| `SPRING_DATASOURCE_URL` | ✅ | ✅ | ✅ | ✅ | JDBC URL (may include SSL params) |
| `SPRING_DATASOURCE_USERNAME` | ✅ | ✅ | ✅ | ✅ | DB user |
| `SPRING_DATASOURCE_PASSWORD` | ✅ | ✅ | ✅ | ✅ | **Secret** |
| `SPRING_DATASOURCE_DRIVER_CLASS_NAME` | — | — | ⚪ | ⚪ | Rarely needed |
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | ⚪ | ⚪ | ⚪ | ⚪ | Pool tuning matters in prod |
| `SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE` | ⚪ | ⚪ | ⚪ | ⚪ | Pool tuning matters in prod |
| `SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT` | ⚪ | ⚪ | ⚪ | ⚪ | Pool tuning matters in prod |
| `SPRING_FLYWAY_ENABLED` | ⚪ | ⚪ | ⚪ | ⚪ | Sometimes `false` if migrations run separately |
| `SPRING_FLYWAY_BASELINE_ON_MIGRATE` | ⚪ | — | ⚪ | ⚪ | Only if needed |
| `SPRING_FLYWAY_LOCATIONS` | ⚪ | — | ⚪ | ⚪ | Only if you override defaults |
| `JWT_SECRET` | ✅ | ✅ | ✅ | ✅ | **Secret**; use a CI-only value in tests |
| `JWT_EXPIRATION_SECONDS` | ⚪ | ⚪ | ⚪ | ⚪ | Optional override |
| `JWT_ISSUER` | ⚪ | ⚪ | ⚪ | ⚪ | Becomes ✅ if enforced |
| `JWT_AUDIENCE` | ⚪ | ⚪ | ⚪ | ⚪ | Becomes ✅ if enforced |
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | ⚪ | ⚪ | ⚪ | ⚪ | Often set to `health,info` |
| `MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED` | ⚪ | ⚪ | ⚪ | ✅ | Typically `true` in K8s |
| `MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS` | ⚪ | ⚪ | ✅ | ✅ | Usually `never` or `when_authorized` |
| `MANAGEMENT_SERVER_PORT` | — | — | ⚪ | ⚪ | Separate actuator port if desired |
| `MANAGEMENT_HEALTH_DB_ENABLED` | ⚪ | ⚪ | ⚪ | ⚪ | Toggle DB checks if too strict |
| `LOGGING_LEVEL_ROOT` | ⚪ | ⚪ | ⚪ | ⚪ | Environment-specific verbosity |
| `LOGGING_LEVEL_COM_POKEDEX` | ⚪ | ⚪ | ⚪ | ⚪ | Package override (example) |
| `LOGGING_PATTERN_CONSOLE` | ⚪ | ⚪ | ⚪ | ⚪ | Formatting override |

### CI feature flags (workflow-level)

| Variable | Local | CI | Render | K8s | Notes |
|---|---:|---:|---:|---:|---|
| `PUBLISH_DOCKER_IMAGE` | — | ⚪ | — | — | GitHub Actions Variable |
| `CANONICAL_REPOSITORY` | — | ✅* | — | — | Required only when publishing is enabled |
| `PUBLISH_HELM_CHART` | — | ⚪ | — | — | Reserved |
| `DEPLOY_ENABLED` | — | ⚪ | — | — | Reserved kill switch |
| `ENABLE_SEMANTIC_RELEASE` | — | ⚪ | — | — | Release gate |

\* Required only when publishing is enabled

---

## 🔀 CI Feature Flags (GitHub Actions)

Create these under:

**Settings → Secrets and variables → Actions → Variables**

### Docker image publishing

#### Variables

- `PUBLISH_DOCKER_IMAGE` = `true` | `false`  
  Controls whether Docker images are published to GHCR **after a successful release**.

- `CANONICAL_REPOSITORY` = `<owner>/<repo>`  
  Defines the **single canonical repository** allowed to publish artifacts.

---

#### Behavior (current)

Docker publishing runs **only if all conditions are met**:

1. A semantic-release version (`vX.Y.Z`) was actually published
2. `PUBLISH_DOCKER_IMAGE == true`
3. `github.repository == CANONICAL_REPOSITORY`

Outcomes:

- All conditions met → image is published
- Any condition fails → publish job is **skipped with a warning summary**

This guard:

- prevents publishing from forks
- prevents publishing when no release occurred
- avoids silent no-ops

---

#### Used by

- `.github/workflows/release.yml` (publish job)

---

#### Rationale

- Allows **emergency shutdown** of publishing without code changes
- Prevents **accidental publishing** from forks or mirrors
- Decouples release versioning (ADR-008) from artifact delivery
- Makes publishing policy **explicit, auditable, and observable**

---

### Helm chart publishing (future)

- `PUBLISH_HELM_CHART` = `true` | `false`

Planned behavior (when wired):

- Runs in the same **publish job**
- Subject to the same canonical-repo and “version published” guards
- Skipped with an explanatory summary when disabled

Status:

- **Scaffolded but not yet implemented**
- Documented for forward compatibility

---

### Deployment kill switch (future)

- `DEPLOY_ENABLED` = `true` | `false`

Reserved global safety switch for automated deployments.

Planned usage:

- Gate Render, Kubernetes, or other deploy workflows
- Allow instant halt of deploys during incidents

Status:

- **Not currently used**

---

### semantic-release gate

- `ENABLE_SEMANTIC_RELEASE` = `true` | `false`

Behavior:

- `true` → allows push-based releases from `main`
- `false` → release job is skipped
- manual `workflow_dispatch` with `enable_release=true` can override per run

This variable ensures releases are **explicit and intentional**.

---

## 🧾 CI Job Summaries (important)

Release-related workflows emit **human-readable Job Summaries**:

### Release job summary

Includes:

- Trigger (push vs manual)
- Branch and repository
- Release gate values
- **Dry-run version preview**
- Final outcome (published / skipped)

### Publish job summary

Includes:

- Canonical repository check (pass/fail)
- Published version
- Docker / Helm enablement
- Clear explanation when publishing is skipped

These summaries appear in the **Summary tab** of GitHub Actions and are the
primary way to understand *why* CI behaved the way it did.

---

## 🌐 Runtime Environment Variables (All Platforms)

The application follows **12-factor principles**:

- configuration via environment variables only
- no environment-specific config files
- no secrets in source control

The same variable names are used across **local**, **Render**, and **Kubernetes**.

---

## 🧪 Application runtime (all environments)

These variables control **application behavior**, not delivery.
They are stable across local dev, CI, Render, and Kubernetes.

| Variable | Required | Description |
|--------|----------|-------------|
| `SPRING_PROFILES_ACTIVE` | ✅ | Active Spring profile (`dev`, `test`, `prod`) |
| `SERVER_PORT` | ❌ | Override default server port (often injected by platform) |
| `SPRING_APPLICATION_NAME` | ❌ | App identity used in logs/metrics |
| `SPRING_MAIN_BANNER_MODE` | ❌ | Banner mode: `off`, `console`, `log` (often `off` in CI) |

---

## 🗄️ Database (PostgreSQL)

Used by the application and Flyway migrations in **all environments**.

| Variable | Required | Description |
|--------|----------|-------------|
| `SPRING_DATASOURCE_URL` | ✅ | JDBC connection URL |
| `SPRING_DATASOURCE_USERNAME` | ✅ | Database username |
| `SPRING_DATASOURCE_PASSWORD` | ✅ | Database password (**secret**) |

### Pooling (HikariCP)

Connection pool tuning knobs. Defaults are usually fine for dev/test.

| Variable | Required | Description |
|--------|----------|-------------|
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | ❌ | Upper bound on DB connections |
| `SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE` | ❌ | Idle connections to keep |
| `SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT` | ❌ | How long to wait for a connection |

Notes:

- Pool sizing matters in Render/K8s where resources are constrained
- Align max pool size with DB connection limits

### Render Postgres note (SSL)

If using Render-managed Postgres, SSL may be required in production.

Common approaches:

- Include SSL parameters **directly in the JDBC URL**, or
- Configure SSL via standard Postgres/JDBC settings supported by the platform

**Recommendation:** Keep SSL configuration in the JDBC URL to preserve 12‑factor portability.

---

## 🧭 Flyway (Migrations)

Controls schema migration behavior per environment.

| Variable | Required | Description |
|--------|----------|-------------|
| `SPRING_FLYWAY_ENABLED` | ❌ | Enable/disable migrations at startup |
| `SPRING_FLYWAY_BASELINE_ON_MIGRATE` | ❌ | Baseline existing schema before migrate |
| `SPRING_FLYWAY_LOCATIONS` | ❌ | Override migration locations |

Notes:

- Same variables apply across local, CI, Render, and Kubernetes
- If migrations move to a dedicated job later, set `SPRING_FLYWAY_ENABLED=false` for the app

---

## 🔐 Security / Authentication

JWT configuration for authentication.

| Variable | Required | Description |
|--------|----------|-------------|
| `JWT_SECRET` | ✅ | Secret used to sign JWTs |
| `JWT_EXPIRATION_SECONDS` | ❌ | Token lifetime override |
| `JWT_ISSUER` | ❌ | Expected issuer (if validated) |
| `JWT_AUDIENCE` | ❌ | Expected audience (if validated) |

Notes:

- Secrets **must** come from platform secret managers
- Never log or echo these values
- If issuer/audience validation is enforced, treat them as required

---

## 🩺 Observability / Health

Used by platforms and orchestrators for health checks.

| Variable | Required | Description |
|--------|----------|-------------|
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | ❌ | Actuator endpoints to expose |
| `MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED` | ❌ | Enable readiness/liveness probes |
| `MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS` | ❌ | Health details: `never`, `when_authorized`, `always` |
| `MANAGEMENT_SERVER_PORT` | ❌ | Run actuator on a dedicated port |
| `MANAGEMENT_HEALTH_DB_ENABLED` | ❌ | Toggle DB health contributor |

Used by:

- Render health checks
- Kubernetes readiness/liveness probes

---

## 🧾 Logging

Logging behavior tuning without rebuilds.

| Variable | Required | Description |
|--------|----------|-------------|
| `LOGGING_LEVEL_ROOT` | ❌ | Root log level |
| `LOGGING_LEVEL_COM_POKEDEX` | ❌ | Package-level override (example) |
| `LOGGING_PATTERN_CONSOLE` | ❌ | Customize console output |

Notes:

- Prefer targeted package overrides in prod
- Never log secrets (especially headers or tokens)

---

## Summary

- Runtime variables define **how the app behaves**
- They are **independent of CI delivery logic**
- Values vary per environment, names do not
- Secrets always live outside source control

---

## ☁️ Platform-specific notes

### Render (Phase 1 – planned)

- Environment variables configured via the Render dashboard
- Secrets stored encrypted by Render
- JDBC URLs may include SSL parameters
- Health checks should target:
  - `/actuator/health`
  - `/actuator/health/readiness`

No CI-controlled deployment occurs in Phase 1 (see ADR-009).

---

### Helm / Kubernetes (Phase 2 – future)

Environment variables will be injected via:

- Helm `values.yaml`
- Kubernetes `ConfigMap` (non-secrets)
- Kubernetes `Secret` (sensitive values)

Helm charts support:

- image repository + tag injection
- environment variable templating
- readiness/liveness probes

See:

- **ADR-009** — Deployment Strategy
- `helm/pokemon-trainer-platform/values.yaml`

---

## 🔗 Related Decisions

- **ADR-008** — CI-Managed Releases with semantic-release
- **ADR-009** — Deployment Strategy (Render → Kubernetes)

---

## Summary

- CI feature flags control **when releases and publishing occur**
- Publishing is **job-level gated**, canonical-repo enforced, and fork-safe
- Runtime variables control **application behavior**, not delivery
- CI behavior is always explained via **Job Summaries**
