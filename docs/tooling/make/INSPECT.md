# 🔍 Makefile Inspection (`inspect-mk`)

This document explains the **Makefile inspection tooling** provided by the
`inspect-mk` command and the scripts under `scripts/inspect/`.

The goal is **discoverability**, **navigation**, and **read-only introspection**
of the decade-based Makefile architecture.

Scripts live under `scripts/inspect/make/`.

---

## 🧱 What problem this solves

As the Makefile system grows, it becomes harder to answer questions like:

- *What Make targets exist?*
- *Which decade does this file belong to?*
- *Where should I add a new target?*
- *What does `make 70-runtime.mk` actually expose?*

`inspect-mk` exists to answer those questions **without opening files** and
**without executing any side effects**.

---

## 🧭 Decade-based architecture (quick recap)

This repository uses a **numeric decade convention** for Make modules:

| Decade | Purpose |
| ------ | -------- |
| 00s | Kernel / Make bootstrapping |
| 10s | Presentation (UX, colors, formatting) |
| 20s | Configuration & feature flags |
| 30s | Public interface (help, categories, roles) |
| 40s | Preconditions & environment checks |
| 50s | Libraries & shared helpers |
| 60s | Verification & quality gates |
| 70s | Runtime orchestration |
| 80s | Simulation / automation |
| 90s | Delivery / release |

`inspect-mk` uses the **first digit** of the filename to determine the decade
(e.g. `52-commit.mk` → **50s**).

---

## 🛠️ Available commands

### List all Make modules (grouped by decade)

```bash
make inspect-mk
```

Example output:

```text
📂 Available make/ modules

50s — Library
  🧩 50-library.mk
  🧩 52-commit.mk
  🧩 53-local-hygiene.mk
```

- Read-only
- Grouped by decade
- Emoji indicates the architectural layer

---

### Inspect a single Make module

```bash
make inspect-mk 50
```

or explicitly:

```bash
make inspect-mk FILE=make/50-library.mk
```

This prints all **documented targets** (`##` comments) in that file.

---

### Inspect all modules in a decade

```bash
make inspect-mk 5 FLAG=a
```

or:

```bash
make inspect-mk 50 FLAG=a
```

This inspects **every file in the same decade bucket** and prints:

- A consolidated list of targets
- One header per file

---

## 🚫 What `inspect-mk` will *not* do

By design, `inspect-mk` is intentionally limited:

- ❌ No execution of targets
- ❌ No mutation of files
- ❌ No environment checks
- ❌ No shelling out to Docker / Gradle / Git

It is **safe to run at any time**.

---

## 📁 Script layout

All logic lives in shell scripts; Make only orchestrates.

```text
scripts/inspect/make/
├── make-router.sh      # main entrypoint (argument routing)
├── make-list.sh        # list modules (grouped by decade)
├── make-all.sh         # inspect all modules
├── make-decade-all.sh  # inspect all modules in one decade
```

This keeps Makefiles:

- thin
- readable
- declarative

---

## 🧠 Design principles

- **Discoverability first**
- **Make = orchestration**
- **Scripts = logic**
- **Read-only by default**
- **Boring > clever**

If something feels surprising, it’s probably a bug.

---

## ✅ When to use `inspect-mk`

Use this tool when you want to:

- onboard a new contributor
- understand where a target lives
- audit available commands
- decide which decade a change belongs to
- explore the Makefile system safely

---

If you’re unsure where to add something, start with:

```bash
make inspect-mk
```

and follow the decade. 🧭
