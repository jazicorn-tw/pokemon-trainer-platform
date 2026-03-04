<!-- markdownlint-disable-file MD036 -->

# 🧪 `.actrc` — act local CI configuration

This document describes the **recommended `.actrc` configuration** for this repository.

`.actrc` is a plain-text configuration file read automatically by `act`. It is **not** a shell script.

Its purpose is to make local CI simulation behave as close to GitHub Actions as possible, with
zero flags required on each run.

---

## 📍 File location

Create the file at:

```text
~/.actrc
```

`act` will load this file automatically on every invocation.

---

## 📄 This file vs `.actrc`

This file **documents** the recommended configuration.

The actual `.actrc` file:

- lives in your **home directory** (`~/.actrc`)
- is **not committed** to this repository
- is **machine-specific**

For a copy-ready template, see:

- `docs/devops/ci/act/actrc.example`

---

## ✅ Repo-standard `.actrc`

```text
# Match GitHub Actions runner image
-P ubuntu-latest=catthehacker/ubuntu:full-latest

# Force CI architecture parity (GitHub runners are amd64)
--platform linux/amd64

# Allow Docker socket access inside the runner container
--container-options "--user 0:0"
```

This configuration requires **no per-command flags** and works with the repo’s Make wrappers.

---

## 🧠 What each line does

### `-P ubuntu-latest=...`

Pins `ubuntu-latest` to the same image used by GitHub-hosted runners.

This avoids unexpected behavior caused by `act` defaults drifting from CI.

---

### `--platform linux/amd64`

Forces containers to run as **linux/amd64**, even on Apple Silicon hosts.

Why this matters:

- GitHub Actions runners are amd64
- Prevents `exec format error` and subtle runtime mismatches
- Ensures "works locally" == "works in CI"

---

### `--container-options "--user 0:0"`

Runs the runner container as root.

Why this matters:

- Required for access to `/var/run/docker.sock`
- Matches GitHub-hosted runner permissions
- Avoids `permission denied` socket errors

---

## ⚠️ Important notes

- `.actrc` is **not versioned** in this repository
- Do **not** commit `.actrc`
- This file affects *all* `act` runs on your machine

If you need to override behavior temporarily, pass flags directly to `act`.

---

## 🔗 Related docs

`docs/devops/ci/act`

- `ACT_OVERVIEW.md` — what `act` is and how we use it
- `ACT_COMMANDS.md` — common Make targets and commands
- `ACT_TROUBLESHOOTING.md` — real-world failure modes and fixes
