<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# 🧼 Local Hygiene — Quick Reference

> This is a **developer quick reference**, not required configuration.  
> Most contributors will **never need to touch these knobs**.
>
> These settings exist to recover from **local disk pressure issues**
> (especially during `act` / Docker / Colima usage).

This document summarizes **all local hygiene configuration options** and when
they should be used.

---

## 🧪 act / Gradle cache hygiene

Controls cleanup of the local `act` Gradle cache (usually `.gradle-act`), which can
grow large during repeated local CI simulations.

### Knobs

```text
ACT_GRADLE_CACHE_REMOVE=false|true|auto
ACT_GRADLE_CACHE_PATH=.gradle-act
ACT_GRADLE_CACHE_DRY_RUN=false|true
ACT_GRADLE_CACHE_WARN_GB=8
ACT_COLIMA_DISK_MIN_FREE_GB=6
ACT_COLIMA_MIN_FREE_INODES=5000
ACT_COLIMA_PROFILE=default
```

### Behavior

| Setting                          | Effect                                                 |
| -------------------------------- | ------------------------------------------------------ |
| `ACT_GRADLE_CACHE_REMOVE=false`  | Never remove cache (default, safest)                   |
| `ACT_GRADLE_CACHE_REMOVE=true`   | Always remove cache                                    |
| `ACT_GRADLE_CACHE_REMOVE=auto`   | Remove only when Colima containerd is under pressure   |
| `ACT_GRADLE_CACHE_DRY_RUN=true`  | Show what *would* be deleted                           |
| `ACT_GRADLE_CACHE_WARN_GB`       | Warn if cache exceeds this size                        |

### Common usage

Warn only (no deletion):

```bash
make clean-act
```

Auto-clean under pressure:

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=auto
```

Force clean:

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=true
```

---

## 🐳 Docker hygiene

Controls pruning of Docker **images, containers, networks, and build cache**.

⚠️ **Docker volumes are data, not cache.** They are never automatic.

### Knobs

```text
CLEAN_DOCKER_MODE=false|true|auto
CLEAN_DOCKER_VOLUMES=false|true
CLEAN_DOCKER_VERBOSE=false|true
CLEAN_DOCKER_AUTO_MIN_FREE_GB=10
CLEAN_DOCKER_AUTO_MIN_FREE_INODES=5000
CLEAN_DOCKER_COLIMA_PROFILE=default
```

### Behavior

| Setting                     | Effect                                          |
| --------------------------- | ----------------------------------------------- |
| `CLEAN_DOCKER_MODE=false`   | Do nothing (default)                            |
| `CLEAN_DOCKER_MODE=true`    | Always prune docker cache                       |
| `CLEAN_DOCKER_MODE=auto`    | Prune only under containerd disk/inode pressure |
| `CLEAN_DOCKER_VOLUMES=true` | **Delete named volumes (destructive)**          |
| `CLEAN_DOCKER_VERBOSE=true` | Print detailed prune actions                    |

🚫 `CLEAN_DOCKER_VOLUMES` does **not** support `auto`.  
Volumes contain data and require explicit consent.

### Common usage

Auto prune cache only:

```bash
make clean-docker CLEAN_DOCKER_MODE=auto
```

Prune cache + volumes (destructive):

```bash
make clean-docker CLEAN_DOCKER_MODE=true CLEAN_DOCKER_VOLUMES=true
```

---

## 🧊 Colima hygiene (NUCLEAR)

Colima reset **destroys the VM** and deletes:

- Docker images
- Containers
- Volumes
- Build cache

This is **never automatic** and is intentionally excluded from `clean-local`.

### Knobs

```text
CLEAN_COLIMA_RESET=false|true
CLEAN_COLIMA_DISK_GB=80
CLEAN_COLIMA_PROFILE=default
CLEAN_COLIMA_ASSUME_YES=false|true
```

### Usage

Interactive reset:

```bash
make clean-colima CLEAN_COLIMA_RESET=true
```

Non-interactive (CI / scripted):

```bash
make clean-colima CLEAN_COLIMA_RESET=true CLEAN_COLIMA_ASSUME_YES=true
```

---

## 🧼 clean-local orchestration

`clean-local` runs:

- act cache hygiene
- docker cache hygiene

It **never** resets Colima.

```bash
make clean-local
```

All `ACT_*` and `CLEAN_DOCKER_*` knobs apply.

---

## 🧠 Decision guide

| Symptom                                              | Start with                                        |
| ---------------------------------------------------- | ------------------------------------------------- |
| act fails with `no space left on device`             | `make clean-local CLEAN_DOCKER_MODE=auto`         |
| Docker disk usage keeps growing                      | `make clean-docker CLEAN_DOCKER_MODE=true`        |
| Everything is broken / containerd corrupted          | `make clean-colima CLEAN_COLIMA_RESET=true`       |

---

## Design principles

- Safe by default
- Explicit over clever
- No silent data loss
- Local-only scope
- Predictable output

---

📄 Related:

- `docs/tooling/LOCAL_HYGIENE.md`
- `make/53-local-hygiene.mk`
- `scripts/cache/`
