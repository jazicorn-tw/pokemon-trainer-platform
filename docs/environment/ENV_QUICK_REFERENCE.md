<!-- markdownlint-disable-file MD036 -->

# ⚡ Environment Variables — Quick Reference

This section is a **high-signal index** of all supported environment variables.  
Detailed behavior and rationale live in the linked docs.

---

## 🔀 CI Feature Flags (GitHub Actions)

```text
PUBLISH_DOCKER_IMAGE     # true|false — enable Docker image publishing on release tags
CANONICAL_REPOSITORY    # <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART      # true|false — (future) enable Helm chart publishing
DEPLOY_ENABLED          # true|false — (future) global deployment kill switch
ENABLE_SEMANTIC_RELEASE # true|false — optional gate for semantic-release
```

📄 See: `CI_FEATURE_FLAGS.md`

---

## 🌐 Application Runtime (All Environments)

```text
SPRING_PROFILES_ACTIVE   # dev|test|prod — active Spring profile (required)
SERVER_PORT              # optional — override default server port

SPRING_APPLICATION_NAME  # optional — app identity for logs/metrics
SPRING_MAIN_BANNER_MODE  # optional — off|console|log (often off in CI)
```

📄 See: `RUNTIME_APPLICATION.md`

---

## 🗄️ Database (PostgreSQL)

```text
SPRING_DATASOURCE_URL        # JDBC connection URL (may include SSL params)
SPRING_DATASOURCE_USERNAME  # database username
SPRING_DATASOURCE_PASSWORD  # database password (secret)

SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE  # optional — pool sizing
SPRING_FLYWAY_ENABLED                       # optional — enable/disable migrations
```

📄 See: `DATABASE_POSTGRESQL.md`

---

## 🔐 Security / Authentication

```text
JWT_SECRET                # JWT signing secret (secret)
JWT_EXPIRATION_SECONDS    # optional — token lifetime override
JWT_ISSUER                # optional — expected issuer (if enforced)
JWT_AUDIENCE              # optional — expected audience (if enforced)
```

📄 See: `SECURITY_AUTH.md`

---

## 🩺 Observability / Health

```text
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE   # actuator endpoints to expose
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED  # readiness/liveness probes
MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS    # never|when_authorized|always
```

📄 See: `OBSERVABILITY_LOGGING.md`

---

## Notes

- **CI variables** live in **GitHub Actions → Variables**
- **Runtime variables** are injected via **Render / Helm / Kubernetes**
- **Secrets are never committed** — use platform secret managers only
- Defaults are **fail-closed** where applicable
