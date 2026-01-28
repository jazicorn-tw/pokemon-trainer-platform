<!-- markdownlint-disable-file MD036 -->

# ⚡ Environment Variables — Quick Reference (CI & Remote)

This section is a **high-signal index** of environment variables that apply to
**CI and remote (non-local) environments only**.

Detailed behavior and rules live in the linked specs.

---

## 🔀 CI Feature Flags (GitHub Actions)

```text
PUBLISH_DOCKER_IMAGE     # true|false — enable Docker image publishing
CANONICAL_REPOSITORY    # <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART      # true|false — (future) enable Helm publishing
DEPLOY_ENABLED          # true|false — (future) global deployment kill switch
ENABLE_SEMANTIC_RELEASE # true|false — gate semantic-release execution
```

📄 See: `ENV_SPEC_CI.md`

---

## 🧪 CI Runtime (GitHub Actions)

```text
CI               # true — set automatically by CI runners
GITHUB_ACTIONS   # true — GitHub Actions environment
GITHUB_REF       # branch or tag ref
GITHUB_SHA       # commit SHA
```

📄 See: `ENV_SPEC_CI.md`

---

## ☁️ Hosted Runtime Platforms (Render / AWS / Cloud)

```text
PORT         # platform-provided port (e.g. Render)
RENDER       # true — Render environment indicator
AWS_REGION   # AWS region (if applicable)
```

📄 See: `PLATFORM_NOTES.md`

---

## 🗄️ Managed Databases (Remote)

```text
SPRING_DATASOURCE_URL
SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_PASSWORD
```

📄 See: `DATABASE_POSTGRESQL.md`

---

## 🔐 Secrets (Remote-only)

```text
JWT_SECRET
DATABASE_PASSWORD
GHCR_TOKEN
```

📄 See: `ENV_SPEC_CI.md`

---

## 🩺 Observability / Health

```text
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE
```

📄 See: `OBSERVABILITY_LOGGING.md`

---

## Notes

- **CI variables** are injected by GitHub Actions
- **Remote runtime variables** are injected by hosting platforms (Render, AWS, etc.)
- **Secrets are never committed** — use platform secret managers only
- Defaults are **fail-closed** where applicable
