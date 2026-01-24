<!-- markdownlint-disable-file MD033 -->

# 🐳 Publish Docker Image (Release Tags Only)

This repository publishes a Docker image to **GitHub Container Registry (GHCR)** **only** when a **semantic-release tag** is pushed (example: `v1.2.3`).

Workflow file: `.github/workflows/image-publish.yml`

---

## ✅ When this workflow runs

This workflow triggers **only** on pushed Git tags matching:

- `v*.*.*` (example: `v1.2.3`)

```yaml
on:
  push:
    tags:
      - "v*.*.*"
```

That means:

- A normal push to `main` **will not** publish an image.
- A release tag created by **semantic-release** (or manually) **will** attempt to publish.

---

## 🔐 Permissions (minimal)

The workflow uses minimal GitHub Actions permissions:

- `contents: read` — to clone the repo
- `packages: write` — to push the image to GHCR

```yaml
permissions:
  contents: read
  packages: write
```

Authentication uses the built-in `GITHUB_TOKEN` (no PAT required).

---

## 🧠 Publish toggle: fork-safe + default-false

Before building/pushing, the workflow runs a **gate** job that decides whether publishing is allowed.

### Required repository variables

This workflow relies on GitHub **Repository variables** (Settings → Secrets and variables → Actions → Variables):

| Variable                | Example value     | Purpose                                                               |
|-------------------------|-------------------|-----------------------------------------------------------------------|
| `PUBLISH_DOCKER_IMAGE`  | `true` or `false` | Global “on/off” switch (defaults to `false` when missing).            |
| `CANONICAL_REPOSITORY`  | `owner/repo`      | Prevents publishing from non-canonical repos (hardens against forks). |

### Gate rules

Publishing is allowed **only if**:

1. `CANONICAL_REPOSITORY` is set **and** matches the current `${{ github.repository }}`, **and**
2. `PUBLISH_DOCKER_IMAGE == "true"`

Otherwise, the workflow skips the publish job and records the reason.

---

## 🧵 Concurrency

To prevent duplicate publishes for the same tag:

```yaml
concurrency:
  group: publish-image-${{ github.ref }}
  cancel-in-progress: false
```

This ensures only one publish runs per tag ref.

---

## 🏗️ What gets published

### Image name

The image is published to GHCR under:

- `ghcr.io/<owner>/<repo>`

Derived from:

```yaml
images: ghcr.io/${{ github.repository }}
```

Example:

- `ghcr.io/jazicorn-tw/pokemon-inventory-system`

### Tags

Tags are derived from the Git tag (SemVer), plus a `latest` tag:

- `v1.2.3` → `1.2.3`
- `v1.2.3` → `1.2`
- `v1.2.3` → `1`
- `latest`

Configured via `docker/metadata-action`:

```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=semver,pattern={{major}}
  type=raw,value=latest
```

### Labels

OCI labels include:

- `org.opencontainers.image.source` → GitHub repo
- `org.opencontainers.image.revision` → commit SHA

---

## 🧰 Build details

The publish job:

1. Checks out the repository with full history + tags (`fetch-depth: 0`)
2. Sets up Docker Buildx
3. Logs into GHCR using `GITHUB_TOKEN`
4. Extracts tags/labels from the Git tag
5. Builds and pushes `linux/amd64`

Build-push configuration:

```yaml
with:
  context: .
  file: ./Dockerfile
  push: true
  platforms: linux/amd64
  tags: ${{ steps.meta.outputs.tags }}
  labels: ${{ steps.meta.outputs.labels }}
  cache-from: type=gha
  cache-to: type=gha,mode=max
```

### Cache

Uses GitHub Actions cache (`type=gha`) for faster rebuilds and reproducibility.

---

## 🧪 Quick verification (after a release)

After semantic-release publishes a tag (e.g., `v1.2.3`), confirm:

1. GitHub Actions shows a successful run for **Publish Image**
2. GHCR has the new package + tags

You can also pull locally:

```bash
docker pull ghcr.io/<owner>/<repo>:1.2.3
docker pull ghcr.io/<owner>/<repo>:latest
```

---

## 🔧 Troubleshooting

### Publish job didn’t run

Most common causes:

- `PUBLISH_DOCKER_IMAGE` is missing or not `"true"`
- `CANONICAL_REPOSITORY` is missing or doesn’t match `${{ github.repository }}`
- The tag didn’t match `v*.*.*`

Check the workflow logs step:

> **Docker publish toggle**

It prints:

- `PUBLISH_DOCKER_IMAGE=...`
- `gate.publish=...`
- `gate.reason=...`

### Login to GHCR fails

Confirm:

- Workflow permissions include `packages: write`
- Package visibility/permissions in GHCR are correct for your org/user

---

## 🔒 Notes on safety

Even though fork tag-push publishing is uncommon, the **canonical repo check** is deliberate hardening. It prevents accidental or malicious publishing from a copy of the repository where variables might differ.
