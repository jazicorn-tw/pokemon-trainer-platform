<!-- markdownlint-disable-file MD060 -->
<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# ✅ Repo Variables & Environment Configuration

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
PUBLISH_DOCKER_IMAGE   # optional — true|false — enable Docker image publishing on release tags
CANONICAL_REPOSITORY   # required* — <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART     # optional — true|false — (future) enable Helm chart publishing
DEPLOY_ENABLED         # optional — true|false — (future) global deployment kill switch

ENABLE_SEMANTIC_RELEASE  # optional — true|false — gate semantic-release (if used)
```

\* Required **only when publishing is enabled** (`PUBLISH_DOCKER_IMAGE=true`)

---

### 🌐 Application Runtime (All Environments)

**Purpose:** Define core runtime behavior consistently across local, Render, and Kubernetes.  
🔗 See details: **[Application runtime](#-application-runtime-all-environments-1)**

```text
SPRING_PROFILES_ACTIVE  # required — dev|test|prod — active Spring profile
SERVER_PORT             # optional — override default server port

SPRING_APPLICATION_NAME # optional — app identity in logs/metrics
SPRING_MAIN_BANNER_MODE # optional — off|console|log — reduce noise in CI
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
LOGGING_PATTERN_CONSOLE     # optional — customize console output
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
| `ENABLE_SEMANTIC_RELEASE` | — | ⚪ | — | — | Optional gate for semantic-release |

\* Required only when `PUBLISH_DOCKER_IMAGE=true`

---

## 🔀 CI Feature Flags (GitHub Actions)

Create these under:

**Settings → Secrets and variables → Actions → Variables**

### Docker image publishing

#### Variables

- `PUBLISH_DOCKER_IMAGE` = `true` | `false`  
  Controls whether Docker images are published to GHCR on semantic-release tags.

- `CANONICAL_REPOSITORY` = `<owner>/<repo>`  
  Defines the **single canonical repository** allowed to publish Docker images.

---

#### Behavior

**Publishing requires *both* conditions to be true:**

1. `PUBLISH_DOCKER_IMAGE == true`
2. The workflow is running in `CANONICAL_REPOSITORY`

Outcomes:

- `true` **and** canonical repo → images are built and pushed on `vX.Y.Z` tags
- `false` → publish job is skipped (no registry login, no push)
- non-canonical repo → publish job is skipped (safety guard)

---

#### Used by

- `.github/workflows/publish-image.yml`

---

#### Rationale

- Allows **emergency shutdown** of publishing without code changes
- Prevents **accidental publishing** from forks or mirrored repositories
- Decouples release versioning (ADR-008) from artifact delivery
- Makes publishing policy **explicit, auditable, and configuration-driven**

---

### Helm chart publishing (future)

- `PUBLISH_HELM_CHART` = `true` | `false`

Reserved for future Helm chart publishing workflows.

Planned behavior:

- `true` → Helm charts published on release tags
- `false` → chart publishing skipped

Status:

- **Not currently used**
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

### semantic-release gate (optional)

- `ENABLE_SEMANTIC_RELEASE` = `true` | `false`

If your release workflow is gated, this variable acts as an explicit switch.

Planned usage:

- `true` → allow push-based releases (per workflow gating)
- `false` → skip the release job

Status:

- **Only used if your semantic-release workflow references it**

---

## 🌐 Runtime Environment Variables (All Platforms)

The application follows **12-factor principles**:

- configuration via environment variables only
- no environment-specific config files
- no secrets in source control

The same variable names are used across **local**, **Render**, and **Kubernetes**.

---

## 🧪 Application runtime (all environments)

| Variable                 | Required | Description                                    |
|--------------------------|----------|------------------------------------------------|
| `SPRING_PROFILES_ACTIVE` | ✅       | Active Spring profile (`dev`, `test`, `prod`)  |
| `SERVER_PORT`            | ❌       | Override default server port (optional)        |
| `SPRING_APPLICATION_NAME` | ❌      | App identity used in logs/metrics (optional)   |
| `SPRING_MAIN_BANNER_MODE` | ❌      | Banner mode: `off`, `console`, `log`           |

---

## 🗄️ Database (PostgreSQL)

| Variable                      | Required | Description |
|------------------------------|----------|-------------|
| `SPRING_DATASOURCE_URL`      | ✅       | JDBC connection URL |
| `SPRING_DATASOURCE_USERNAME` | ✅       | Database username |
| `SPRING_DATASOURCE_PASSWORD` | ✅       | Database password (**secret**) |

### Pooling (HikariCP)

| Variable | Required | Description |
|---|---:|---|
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | ❌ | Upper bound on DB connections |
| `SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE` | ❌ | Idle connections to keep |
| `SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT` | ❌ | How long to wait for a connection |

Notes:

- Pool defaults are often fine for local dev
- In Render/K8s, pool sizing should match your instance resources and DB limits

### Render Postgres note (SSL)

If you use Render-managed Postgres, you may need SSL in production.

Common approaches:

- Include SSL parameters **directly in the JDBC URL**, or
- Configure SSL via standard Postgres/JDBC settings your deployment platform supports

**Recommendation:** Keep SSL configuration “in the URL” so your app stays 12-factor and portable.

---

## 🧭 Flyway (Migrations)

| Variable | Required | Description |
|---|---:|---|
| `SPRING_FLYWAY_ENABLED` | ❌ | Enable/disable migrations at startup |
| `SPRING_FLYWAY_BASELINE_ON_MIGRATE` | ❌ | Baseline existing schema before migrate |
| `SPRING_FLYWAY_LOCATIONS` | ❌ | Override migration locations |

Notes:

- Same variables are used by Flyway migrations
- Values differ per environment (local, CI, Render, Kubernetes)
- If you later move migrations into a separate “migrate” job, set `SPRING_FLYWAY_ENABLED=false` for the app

---

## 🔐 Security / Authentication

| Variable                 | Required | Description |
|--------------------------|----------|-------------|
| `JWT_SECRET`             | ✅       | Secret used to sign JWTs |
| `JWT_EXPIRATION_SECONDS` | ❌       | Token lifetime override |
| `JWT_ISSUER`             | ❌       | Expected issuer (if validated) |
| `JWT_AUDIENCE`           | ❌       | Expected audience (if validated) |

Notes:

- Secrets **must** be provided via platform secret storage
- Never log or echo these values
- If you enforce issuer/audience validation, treat `JWT_ISSUER` and `JWT_AUDIENCE` as required

---

## 🩺 Observability / Health

| Variable | Required | Description |
|---|---:|---|
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | ❌ | Actuator endpoint exposure |
| `MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED` | ❌ | Enable readiness/liveness probes |
| `MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS` | ❌ | Health details: `never`, `when_authorized`, `always` |
| `MANAGEMENT_SERVER_PORT` | ❌ | Run actuator on a dedicated port |
| `MANAGEMENT_HEALTH_DB_ENABLED` | ❌ | Toggle DB health contributor |

Used by:

- Render health checks
- Kubernetes readiness/liveness probes

---

## 🧾 Logging

| Variable | Required | Description |
|---|---:|---|
| `LOGGING_LEVEL_ROOT` | ❌ | Root log level |
| `LOGGING_LEVEL_COM_POKEDEX` | ❌ | Package log override (example) |
| `LOGGING_PATTERN_CONSOLE` | ❌ | Customize console log format |

Notes:

- Prefer raising verbosity only for targeted packages in prod
- Keep secrets out of logs (especially request/headers)

---

## ☁️ Platform-specific notes

### Render (Phase 1 – planned)

- Environment variables are configured via the Render dashboard
- Secrets are stored encrypted by Render
- If using Render Postgres, ensure your JDBC URL includes any required SSL settings
- Health checks should target:
  - `/actuator/health` or
  - `/actuator/health/readiness`

No CI-controlled deployment occurs in Phase 1 (see ADR-009).

---

### Helm / Kubernetes (Phase 2 – future)

Environment variables will be injected via:

- Helm `values.yaml`
- Kubernetes `ConfigMap` (non-secrets)
- Kubernetes `Secret` (sensitive values)

Helm charts already support:

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

- CI feature flags control **when artifacts are published**
- Runtime variables control **how the application behaves**
- Variable names are stable across all platforms
- Values are always environment-specific and secret-managed
