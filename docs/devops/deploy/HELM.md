<!-- markdownlint-disable-file MD033 -->

# ⛵ Helm (Preparation Only)

This repo currently deploys as a **single service** (modular monolith) while we prepare for a
future split into multiple services.

Helm is added now for **future Kubernetes readiness**, but Kubernetes is **not** required to develop or deploy today.

---

## ⚠️ Helm chart scope and intent

The Helm chart included in this repository exists for **future readiness only**.

References:

- Deployment strategy: **ADR-009**
- Release mechanics: **ADR-008**

Current state:

- Helm charts are linted in CI
- Charts are not published
- Kubernetes is not required to run or deploy the application

All comments in `helm/` templates reference **ADR-009** when describing
deployment assumptions or future Kubernetes usage.

---

## What Helm is

Helm is a package manager for Kubernetes. A Helm "chart" is a versioned bundle of Kubernetes YAML templates + default configuration.

In this repo, the chart lives at:

```text
helm/app
```

## What we do today

We only:

- keep a minimal chart in the repo
- run `helm lint` in CI to ensure the chart stays valid

No cluster is required.

## Local usage

Install Helm:

```bash
brew install helm
```

Lint:

```bash
helm lint helm/app
```

Environment variables are documented in `.env.example` and mirrored in
`helm/app/values.yaml`.

## CI

The `Build Image` workflow also runs:

```bash
helm lint helm/app
```

## Future plan

When we extract services (monorepo multi-service), we will:

- publish Helm charts on semantic-release tags (`vX.Y.Z`)
- deploy per-service to Kubernetes using those charts
