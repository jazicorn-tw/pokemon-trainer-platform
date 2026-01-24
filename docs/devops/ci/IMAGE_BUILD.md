<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable MD024 -->

# 🏗️ Build Docker Image (CI – No Push)

This workflow builds the Docker image **for validation only**.  
It is designed to catch Dockerfile, dependency, and Helm issues early — **without publishing anything**.

Workflow file: `.github/workflows/image-build.yml`

---

## ✅ When this workflow runs

The **Build Image** workflow runs on:

- Pull requests targeting `main`, `staging`, or `dev`
- Direct pushes to `main`, `staging`, or `dev`
- Manual trigger via **workflow_dispatch**

```yaml
on:
  pull_request:
    branches: [ main, staging, dev ]
  push:
    branches: [ main, staging, dev ]
  workflow_dispatch:
```

This ensures Docker and Helm issues are detected **before** release tags are created.

---

## 🔐 Permissions

This workflow is read-only:

```yaml
permissions:
  contents: read
```

It does **not** authenticate to any container registry and **never pushes images**.

---

## 🧵 Concurrency

To avoid redundant builds on rapid pushes or PR updates:

```yaml
concurrency:
  group: image-build-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

- One build per branch/PR at a time
- Older in-progress builds are cancelled when a new commit arrives

---

## 🐳 Docker build (CI only)

### Purpose

The Docker build step validates that:

- `Dockerfile` is valid
- Application dependencies resolve correctly
- The image can be built on Linux (`amd64`)
- Layer caching behaves as expected

### Configuration

```yaml
- name: Build image (CI only, no push)
  uses: docker/build-push-action@v6
  with:
    context: .
    file: ./Dockerfile
    push: false
    platforms: linux/amd64
    tags: pokemon-trainer-platform:ci
    labels: |
      org.opencontainers.image.source=${{ github.repository }}
      org.opencontainers.image.revision=${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

Key points:

- `push: false` guarantees **no registry interaction**
- A local-only tag (`pokemon-trainer-platform:ci`) is used for validation
- OCI labels link the image back to the repo and commit SHA
- GitHub Actions cache (`type=gha`) speeds up repeated builds

---

## ⎈ Helm lint (CI only)

### Purpose

The Helm lint job validates Kubernetes manifests **without deploying anything**.

It checks:

- Chart structure and metadata
- Template rendering
- Common Helm anti-patterns and errors

### Configuration

```yaml
- name: Helm lint
  run: helm lint helm/pokemon-trainer-platform
```

Helm version is pinned for reproducibility:

```yaml
- uses: azure/setup-helm@v4
  with:
    version: v3.14.4
```

---

## 🧪 What this workflow does *not* do

This workflow intentionally does **not**:

- Push Docker images
- Require registry credentials
- Publish Helm charts
- Deploy to Kubernetes

Publishing is handled separately by the **Publish Image** workflow, which runs **only on release tags**.

---

## 🔁 Relationship to other workflows

| Workflow          | Responsibility                                  |
|-------------------|-------------------------------------------------|
| **Build Image**   | CI validation (Docker + Helm), no side effects  |
| **Publish Image** | Release-only image publishing to GHCR           |
| **CI / Quality**  | Tests, linting, static analysis                 |

This separation keeps CI **fast, safe, and predictable**.
