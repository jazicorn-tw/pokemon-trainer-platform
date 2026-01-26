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

By default, `act` follows your **active Docker context** (for example, `colima`)
and does **not** require a system-wide Docker socket symlink.

---

### macOS + Colima (optional socket standardization)

Colima exposes its Docker socket at:

```text
~/.colima/default/docker.sock
```

Some contributors choose to standardize on the system socket path
(`/var/run/docker.sock`) so all Docker-based tooling uses an identical entry point.

If you prefer this setup, you may create a symlink:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

This is **optional**. The repo’s tooling (including `doctor` and `act`) works
correctly without it as long as your Docker context is set to Colima.

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

## 🩺 Interaction with `make doctor`

The `doctor` command validates your local Docker setup before running CI workflows.

Specifically:

* If you explicitly configure a Docker socket (via `~/.actrc` or `DOCKER_HOST`),
  `doctor` will verify that the socket exists and is usable.
* If no socket override is configured, `doctor` assumes tooling will follow the
  active Docker context (for example, Colima) and will **not** require
  `/var/run/docker.sock`.

This avoids false warnings while still catching real misconfigurations.

---

## ⚠️ What `act` does NOT replicate perfectly

`act` is excellent for workflow logic and most shell steps, but some behavior differs from GitHub-hosted runners:

* Hosted toolcache behavior may differ (preinstalled tools, paths)
* Secrets are not available unless explicitly provided
* Filesystem permissions and UID/GID mappings may differ

In this repo, we guard certain steps using `env.ACT` to keep local runs stable while preserving CI correctness.

---

## 🔐 Secrets and releases

Workflows that require GitHub App tokens, signing keys, or production secrets
(for example, **release** or **publish** workflows) are **not intended to be run locally**.

For local validation, use:

```bash
make run-ci
```

This runs CI-focused workflows that are safe, deterministic, and representative of real CI behavior.
