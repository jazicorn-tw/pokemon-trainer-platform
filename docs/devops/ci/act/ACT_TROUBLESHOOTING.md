<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# 🧪 act Troubleshooting (macOS + Colima)

This document covers common `act` failure modes on macOS, especially when using **Colima**.

---

## ❓ What is `act`?

`act` is a **local CI simulator** that executes GitHub Actions workflows exactly as CI would, using Docker.

It allows you to validate workflow logic, environment variables, and container behavior **before pushing** to GitHub.

---

## ✅ Canonical setup (goal state)

```text
Docker context        = colima
Colima socket         = ~/.colima/default/docker.sock
DOCKER_HOST           = (unset)
System socket         = optional (/var/run/docker.sock symlink)
```

This repo **does not require** a system-wide Docker socket symlink.
By default, `act` and other tooling follow the **active Docker context**.

### Optional socket standardization

Some contributors prefer to standardize on `/var/run/docker.sock` so that
all Docker-based tooling uses the same entry point.

If you choose this setup:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

This is **optional** and not required by repo tooling.

---

## ❌ "No such image: catthehacker/ubuntu:full-latest"

### Cause

Almost always: pulls and creates happened against **different Docker daemons or sockets**.

This can happen if:

- `DOCKER_HOST` points somewhere unexpected
- A system socket symlink points to a different daemon than your Docker context

### Fix

Ensure your Docker context is Colima and no conflicting overrides exist:

```bash
docker context use colima
unset DOCKER_HOST
```

If you *do* use a system socket symlink, ensure it points at Colima:

```bash
ls -l /var/run/docker.sock
```

---

## ❌ "permission denied ... unix:///var/run/docker.sock"

### What it means

The runner container can see the Docker socket, but the user inside the
container cannot access it.

### Fix (repo standard)

The Make wrapper runs the container as the `runner` user and adds the Colima
Docker socket GID as a supplementary group:

```text
--user runner --group-add <colima-docker-gid>
```

The GID is auto-detected at build time via `colima ssh -- stat -c '%g' /var/run/docker.sock`.
This avoids running as root while still granting the necessary socket access.

Our Make wrapper already enforces this.

---

## ❌ Architecture mismatch (arm64 host → linux/amd64 images)

### Symptom

- Containers fail to start
- `exec format error`
- Images pull successfully but jobs crash immediately

### Cause

On Apple Silicon, your host is **arm64**, but GitHub Actions runners are
**linux/amd64**.

### Fix (repo standard)

We intentionally run CI simulation as **linux/amd64** to match GitHub:

- Ensure `--platform linux/amd64` is set (via Make wrapper or `~/.actrc`)

This avoids local/CI drift.

---

## ⚠️ "pip running as root" warning

### Symptom

```text
WARNING: Running pip as the 'root' user can result in broken permissions
```

### Cause

Some workflows install lightweight validation tools using `pip` inside
ephemeral CI containers that run as root.

### Impact

- Harmless in local CI containers
- No effect on host system
- Safe to ignore

### Optional quiet alternatives

If you want cleaner logs:

- Use `pipx`
- Replace Python tooling with minimal validators

---

## ❌ Helm setup fails with EPERM chmod

### Symptom

```text
Error: EPERM: operation not permitted, chmod '/opt/hostedtoolcache/helm/...'
```

### Cause

`azure/setup-helm` assumes GitHub-hosted runner toolcache behavior.

### Fix (repo standard)

Split setup logic using `env.ACT`:

- GitHub runners: `azure/setup-helm`
- act runs: install Helm via `apt-get`

---

## ❌ Release workflow fails: missing app_id / secrets

### Symptom

```text
Input required and not supplied: app_id
```

### Cause

Local `act` runs do not have access to GitHub secrets unless explicitly provided.

### Fix

Run CI-focused workflows locally:

```bash
make run-ci
make run-ci ci
```

Avoid running release or publish workflows locally.

---

## 🧠 Updated mental model

- Docker context is authoritative
- Socket symlinks are optional
- `DOCKER_HOST` overrides everything (avoid unless intentional)
- Runner container uses `--user runner --group-add <gid>` for socket access (not root)

One daemon. One context. Predictable results.
