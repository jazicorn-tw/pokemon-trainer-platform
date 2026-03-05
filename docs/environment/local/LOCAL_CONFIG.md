<!-- markdownlint-disable-file MD060 -->
<!-- markdownlint-disable-file MD024 -->

# 🌱 Local Configuration

This document explains the **required local environment files** for this repository
and how to create them correctly.

These files are **not committed** to the repo, but they are **required** for local
development, CI simulation, and tooling such as `doctor`.

---

## ✅ Required files

| File | Location | Committed? | Purpose |
|-----|---------|---------|---------|
| `.env` | Project root | No | Local runtime configuration |
| `.actrc` | `$HOME/.actrc` | No | Configuration for `act` (local GitHub Actions runner) |
| `.config/local-settings.json` | Project root | Yes | Tooling defaults (Colima, doctor, DB, postgres image) |

---

## 📄 `.env` (project root)

The `.env` file contains **local-only environment variables** used during development.

### Create the file

```bash
cp .env.example .env
```

If no `.env.example` exists yet, create `.env` manually:

```bash
touch .env
```

### Example `.env`

```env
# Application
SPRING_PROFILES_ACTIVE=local
SERVER_PORT=8080

# Database (local / Docker / Testcontainers)
POSTGRES_DB={{resource}}
POSTGRES_USER={{resource}}
POSTGRES_PASSWORD={{resource}}
POSTGRES_PORT=5432

# Optional tooling flags
DEBUG=false
```

> ⚠️ **Do not commit `.env`**
>
> The file may contain secrets or machine-specific configuration.
> It should always remain ignored by Git.

---

## ⚙️ `.actrc` (home directory)

The `.actrc` file configures [`act`](https://github.com/nektos/act), which is used
to run GitHub Actions workflows locally.

### Create the file

If this repository provides an example file:

```bash
cp ../devops/ci/act/.actrc.example ~/.actrc
```

Otherwise, create it manually:

```bash
touch ~/.actrc
```

### Required contents

```text
-P ubuntu-latest=catthehacker/ubuntu:full-latest
--container-architecture linux/amd64
--container-daemon-socket /var/run/docker.sock
```

### Required permissions

For security reasons, `.actrc` **must** have strict permissions:

```bash
chmod 600 ~/.actrc
```

Your `doctor` checks will fail if permissions are more permissive.

### Required contents

```text
-P ubuntu-latest=catthehacker/ubuntu:full-latest
--container-architecture linux/amd64
--container-daemon-socket /var/run/docker.sock
```

### Required permissions

For security reasons, `.actrc` **must** have strict permissions:

```bash
chmod 600 ~/.actrc
```

Your `doctor` checks will fail if permissions are more permissive.

---

## 🧩 `.config/local-settings.json` (committed)

Unlike `.env` and `.actrc`, this file **is committed** to the repository.
It provides team-wide defaults for local tooling — Colima resource
requirements, doctor thresholds, local DB connection defaults, and the
Postgres image tag used by Docker Compose.

Scripts read it via `jq` or Python before falling back to hard-coded
values, so overriding a default is as simple as editing the JSON.

```bash
make local-settings   # print all effective resolved values (after OS override merge)
```

To customise for your machine without touching the committed file, create
an OS-specific override (e.g. `.config/local-settings.macos.json`) — it is
deep-merged on top of the base at runtime.

📄 Full key reference and override instructions:
[`LOCAL_ENVIRONMENT.md`](./LOCAL_ENVIRONMENT.md)

---

## 🩺 Validation

After creating the files, verify your setup:

```bash
make doctor
```

Or run the check directly:

```bash
scripts/check/check-required-files.sh
```

For machine-readable output:

```bash
DOCTOR_JSON=1 scripts/check/check-required-files.sh
```

---

## 🧠 Why this exists

This project follows a **doctor-first onboarding model**:

- Fail fast when required setup is missing
- Provide clear remediation steps
- Keep CI, local dev, and documentation in sync

If something is unclear or missing, update this document — it is the source of truth.
