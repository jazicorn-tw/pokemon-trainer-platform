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
System socket         = /var/run/docker.sock (symlink)
DOCKER_HOST           = (unset)
```

One-time setup:

```bash
colima start
docker context use colima
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
unset DOCKER_HOST
```

Verify:

```bash
docker context show
ls -l /var/run/docker.sock
echo "DOCKER_HOST=${DOCKER_HOST:-<unset>}"
```

---

## ❌ "No such image: catthehacker/ubuntu:full-latest"

### Cause

Almost always: pulls and creates happened against **different Docker daemons/sockets**.

### Fix

Ensure `/var/run/docker.sock` exists and points at Colima:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
unset DOCKER_HOST
```

Then rerun.

---

## ❌ "permission denied ... unix:///var/run/docker.sock"

### What it means

The runner container can see `/var/run/docker.sock`, but the user inside the container cannot access it.

### Fix (repo standard)

Run the runner container as root:

```text
--container-options="--user 0:0"
```

Our Make wrapper already passes this.

---

## ❌ Architecture mismatch (arm64 host → linux/amd64 images)

### Symptom

* Containers fail to start
* `exec format error`
* Images pull successfully but jobs crash immediately

### Cause

On Apple Silicon, your host is **arm64**, but most GitHub Actions runner images (including `catthehacker/ubuntu:*`) run as **linux/amd64**.

`act` defaults to `linux/amd64` to match CI, which can expose mismatches if the platform is not explicit.

### Fix (repo standard)

We intentionally run CI simulation as **linux/amd64** to match GitHub:

* Ensure your Make wrapper or `act` invocation uses `--platform linux/amd64`
* Or set this once in `~/.actrc`

This avoids "works on my machine" drift between local and CI.

---

## ⚠️ "pip running as root" warning

### Symptom

```text
WARNING: Running pip as the 'root' user can result in broken permissions
```

### Cause

During `act` runs, some workflows install lightweight validation tools using `pip` inside the runner container, which runs as root by design.

### Impact

* Harmless in ephemeral CI containers
* No effect on host system
* Safe to ignore if output noise is acceptable

### Optional quiet alternatives

If you want cleaner logs:

* Use `pipx` instead of `pip`
* Replace Python tooling with a minimal validator (for example, required-field checks)

If the warning does not bother you, **no action is required**.

---

## ❌ Helm setup fails with EPERM chmod

### Symptom

```text
Error: EPERM: operation not permitted, chmod '/opt/hostedtoolcache/helm/...'
```

### Cause

`azure/setup-helm` assumes GitHub-hosted runner toolcache behavior.

### Fix (repo standard)

Use a split setup based on `env.ACT`:

* GitHub runners: `azure/setup-helm`
* act runs: `apt-get install helm`

---

## ❌ Release workflow fails: missing app_id / secrets

### Symptom

```text
Input required and not supplied: app_id
```

### Cause

Local `act` does not have GitHub Actions secrets unless you provide them.

### Fix

Run CI-focused workflows locally:

```bash
make run-ci
make run-ci ci
```

Avoid running release/publish workflows locally.

---

## 🧠 Quick mental model

* Symlink = correct default (`/var/run/docker.sock`)
* `DOCKER_HOST` = nuclear override (avoid)
* Runner user must be able to read the socket (we run root)

One socket. One daemon. Everything works.
