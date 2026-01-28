<!-- markdownlint-disable-file MD036 -->

# 🌐 ENV Spec — Remote Environments (CI / Hosted Platforms)

This document defines **environment variables and behavior that apply only to
_remote_ environments**, such as:

- GitHub Actions (CI)
- Render (managed hosting)
- AWS / cloud platforms
- Future Kubernetes deployments

It intentionally **excludes local-only configuration** (Docker Desktop, Colima,
`.env` files, etc.).

> **Authoritative scope**
> This document is a **normative extension of `ENV_SPEC.md`**.
> If a variable appears here, it is assumed to be set by a platform,
> not by a developer’s local machine.

---

## 🧭 Design principles

- Remote environments are **non-interactive**
- Configuration is **injected, not discovered**
- Secrets are **always platform-managed**
- Defaults are **fail-closed**
- CI is **stricter than local development**

---

## 🔀 CI & Platform Feature Flags

These variables control **whether CI performs irreversible actions** such as
publishing artifacts or deploying infrastructure.

```text
PUBLISH_DOCKER_IMAGE     # true|false — allow Docker image publishing
CANONICAL_REPOSITORY    # <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART      # true|false — (future) allow Helm publishing
DEPLOY_ENABLED          # true|false — (future) global deployment kill switch
ENABLE_SEMANTIC_RELEASE # true|false — gate semantic-release execution
```

### Rules

- Publishing or deployment **must be explicitly enabled**
- If a flag is unset, the behavior is **disabled**
- Non-canonical repositories are always blocked

---

## 🧪 CI Runtime (GitHub Actions)

These variables are expected to exist **only in CI**.

```text
CI                      # true — set automatically by CI runners
GITHUB_ACTIONS          # true — GitHub Actions environment
GITHUB_REF              # branch or tag ref
GITHUB_SHA              # commit SHA
```

Notes:

- These values must never be relied on in application runtime code
- They are valid **only during workflow execution**

---

## ☁️ Hosted Runtime Platforms (Render / AWS / Cloud)

Variables typically injected by managed platforms.

```text
PORT                    # platform-provided port (Render)
RENDER                  # true — Render environment indicator
AWS_REGION              # AWS region (if applicable)
```

Rules:

- Platform-provided ports **must be respected**
- Applications must not assume fixed ports in prod
- Presence-based flags (`RENDER=true`) are acceptable for diagnostics only

---

## 🗄️ Managed Databases (Remote)

Remote databases are **always external** to the application process.

```text
SPRING_DATASOURCE_URL        # JDBC URL (often includes SSL)
SPRING_DATASOURCE_USERNAME  # DB user
SPRING_DATASOURCE_PASSWORD  # DB password (secret)
```

### SSL expectations

- Remote databases **usually require SSL**
- SSL configuration should be embedded in the JDBC URL
- Do not rely on local trust stores or filesystem certs

---

## 🔐 Secrets (Remote-only)

All secrets in remote environments must be:

- injected via platform secret managers
- non-printable and non-loggable
- rotated without code changes

Common examples:

```text
JWT_SECRET
DATABASE_PASSWORD
GHCR_TOKEN
```

---

## 🩺 Health & Probes (Remote)

Remote platforms depend on **explicit health signals**.

```text
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED  # true in orchestrated envs
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE  # usually health,info
```

Rules:

- Health endpoints must be reachable without auth (platform-scoped)
- Failure to report health should prevent traffic routing

---

## 🚫 Explicitly not allowed

The following must **never** be required in remote environments:

- `.env` files
- interactive prompts
- host-specific paths
- Docker Desktop / Colima assumptions

---

## 🔗 Related documents

- `ENV_SPEC.md` — Authoritative variable specification
- `ENV_QUICK_REFERENCE.md` — High-level index
- `CI_FEATURE_FLAGS.md` — Detailed CI gating behavior
- `PLATFORM_NOTES.md` — Platform-specific nuances

---

## Summary

- This spec governs **remote, non-local environments**
- CI and hosted platforms inject configuration
- Publishing and deployment are always **opt-in**
- Secrets are platform-managed and never committed
