<!-- markdownlint-disable-file MD036 -->

# 🧪 act — What it is and how we use it

`act` is a **local CI simulator** that executes GitHub Actions workflows exactly as CI would, using Docker.

It allows you to run workflows on your machine while preserving the same execution model as GitHub-hosted runners.

In this repo, `act` is used for:

* Debugging workflow logic quickly
* Reproducing CI failures locally
* Validating workflow changes before pushing

---

## ✅ Prerequisites

* Docker daemon running

  * macOS: **Colima** (recommended) or Docker Desktop
* The standard Docker socket available at `/var/run/docker.sock`

### macOS + Colima setup (recommended)

Colima exposes its Docker socket at:

```text
~/.colima/default/docker.sock
```

To ensure `act`, Docker CLI, and GitHub Actions tooling all talk to the **same daemon**, we standardize on the system socket:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

This avoids subtle bugs caused by tools talking to different Docker daemons.

---

## 🔥 The repo-standard way to run `act`

We **do not** invoke `act` directly. Instead, we wrap it with Make targets that encode repo standards:

```bash
make run-ci                 # defaults to ci workflow
make run-ci ci              # run .github/workflows/ci.yml
make run-ci ci test         # run only the 'test' job
make list-ci build-image    # list jobs in build-image.yml
```

### Why the Make wrapper exists

The wrapper exists because it enforces invariants that match GitHub Actions:

* Pins the runner image mapping for `ubuntu-latest`
* Forces container architecture to `linux/amd64` (matches CI runners)
* Runs the runner container as root to allow Docker socket access
* Applies repo-wide defaults consistently across contributors

This keeps local CI simulation **boringly close** to real CI.

---

## ⚠️ What `act` does NOT replicate perfectly

`act` is excellent for workflow logic and most shell steps, but some behavior differs from GitHub-hosted runners:

* Hosted toolcache behavior may differ (preinstalled tools, paths)
* Secrets are not available unless explicitly provided
* Filesystem permissions and UID/GID mappings may differ

In this repo, we guard certain steps using `env.ACT` to keep local runs stable while preserving CI correctness.

---

## 🔐 Secrets and releases

Workflows that require GitHub App tokens, signing keys, or production secrets (for example, **release** or **publish** workflows) are **not intended to be run locally**.

For local validation, use:

```bash
make run-ci
```

This runs CI-focused workflows that are safe, deterministic, and representative of real CI behavior.
