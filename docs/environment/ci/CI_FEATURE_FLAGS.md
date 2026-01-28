<!-- markdownlint-disable-file MD036 -->

# 🔀 CI Feature Flags (GitHub Actions)

These variables control **when CI publishes artifacts or performs deployments**.

They allow emergency shutdowns and prevent accidental publishing from forks or non-canonical repos.

---

## ✅ Variables

```text
# Release gating
ENABLE_SEMANTIC_RELEASE   # true|false — allow push-based semantic-release from main
                          # (workflow_dispatch can override per-run)

# Docker image publishing (GHCR)
PUBLISH_DOCKER_IMAGE      # true|false — enable Docker publishing step (called after a release run)

# Helm chart publishing (OCI/GHCR or other)
PUBLISH_HELM_CHART        # true|false — enable Helm publishing step (called after a release run)

# Canonical publishing guard
CANONICAL_REPOSITORY      # <owner>/<repo> — only repo allowed to publish artifacts

# Future / reserved
DEPLOY_ENABLED            # true|false — global deploy kill switch (future)
```

---

## 🧠 How release gating works

The Release workflow runs on:

- `push` to `main`
- manual `workflow_dispatch`

But the **release job only executes** when **either** condition is true:

- Manual run input: `enable_release == "true"`, **or**
- Repo variable: `ENABLE_SEMANTIC_RELEASE == "true"`

This ensures push-based releases are **opt-in**, while still enabling one-off manual runs.

---

## 📦 Publishing rules

Artifact publishing (Docker/Helm) is executed **only if all conditions are met**:

### 1) A release run is allowed

The release job must be allowed by the release gate above.

### 2) Feature flag is enabled

- Docker: `PUBLISH_DOCKER_IMAGE == "true"`
- Helm: `PUBLISH_HELM_CHART == "true"`

### 3) The repository is canonical

The workflow must run in the canonical repository (not a fork) where:

- `${{ github.repository }}` equals `CANONICAL_REPOSITORY`

> Why: forks can run workflows, but they must never publish official artifacts.

### 4) A release version is actually published

The publish steps should run **only when semantic-release publishes a version** (i.e., a new `vX.Y.Z` is created).

> Note: semantic-release may run and still publish nothing if there are **no releasable commits**.
> In that case, artifact publishing should be skipped.

---

## ✅ Recommended defaults

For most repos:

- `ENABLE_SEMANTIC_RELEASE=false` (enable only when ready)
- `PUBLISH_DOCKER_IMAGE=false` (enable once Docker publishing is wired)
- `PUBLISH_HELM_CHART=false` (enable once Helm publishing is wired)
- `CANONICAL_REPOSITORY=<owner>/<repo>` (always set)

---

## 🎯 Rationale

- Prevents accidental releases
- Allows instant shutdown without code changes
- Keeps release versioning decoupled from delivery
- Blocks artifact publishing from forks/non-canonical repos
