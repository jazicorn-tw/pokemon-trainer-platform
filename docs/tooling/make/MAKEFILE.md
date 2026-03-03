<!-- markdownlint-disable MD036 -->

# 🛠️ Makefile Guide

This repository uses **GNU Make** as a **developer-experience framework**, not a collection of ad-hoc shell aliases.

The Makefile system is intentionally structured, layered, and documented.  
This file explains **how to use Make** and **how to navigate the Makefile system** — not the detailed decade semantics.

The decade contract itself lives in a **dedicated document** and is treated as authoritative.

---

## 🎯 What Make is (and is not)

**Make is:**

- A stable, documented CLI for developers
- A local mirror of CI behavior
- A way to encode guardrails and intent
- A coordination layer over scripts and tools

**Make is not:**

- A replacement for CI
- A dumping ground for one-off commands
- A place to restate architectural contracts

CI remains the source of truth.  
Make exists to provide **fast, local feedback**.

---

## 🚀 Quick start

```bash
make help
```

Common entry points:

```bash
make doctor      # Environment capability checks
make verify      # CI-aligned correctness checks
make dev-up      # Start local runtime prerequisites
make run-ci      # Simulate CI locally via act
```

---

## 🧭 Repository structure

Makefiles live under the `make/` directory and are loaded in numeric order.

```text
make/
├── 00-kernel.mk
├── 10-presentation.mk
├── 20-configuration.mk
├── 30-interface.mk
├── 31-interface-categories.mk
├── 32-interface-roles.mk
├── 40-preconditions.mk
├── 50-library.mk
├── 51-role-entrypoints.mk
├── 60-verification.mk
├── 70-runtime.mk
├── 71-runtime-lifecycle.mk
├── 80-simulation.mk
├── 81-tree.mk
└── 90-delivery.mk
```

The numeric prefixes are **not arbitrary**.  
They represent responsibility layers that scale over time.

---

## 🧱 Decade model (authoritative source)

This file intentionally **does not** define decade responsibilities.

The canonical definition lives here:

- 📄 `docs/tooling/make/MAKEFILE_DECADES.md` (authoritative)

If there is ever a discrepancy between this guide and the decade document,  
**the decade document wins**.

---

## 🧪 The `doctor` model

`doctor` answers a single question:

> *Is this machine capable of working on this repository?*

```bash
make doctor
```

Doctor:

- Runs local-only checks
- Fails fast with actionable errors
- Can emit structured JSON for automation

Doctor is advisory.  
CI remains authoritative.

---

## 🔍 Mental model

Think in layers:

- **Interface (30s)** → what users invoke
- **Verification (60s)** → correctness
- **Runtime (70s)** → local services
- **Simulation (80s)** → CI parity
- **Delivery (90s)** → shipping

If a target feels out of place, it probably is.

---

## 🧠 Adding new targets

When adding a target:

- Choose the **correct decade**
- Prefer reuse via `50-library.mk`
- Keep interface targets stable
- Document intent when placement is non-obvious

If placement is unclear, consult the decade guide **before** adding a new band.

---

## Philosophy

This Makefile system favors:

- Explicit structure over convenience
- Stable contracts over churn
- Clear intent over clever shortcuts

If a command matters, it should be:

> **One Make target away — and in the right layer**
