<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable MD024 -->

# CI & Workflow Naming Conventions

This document defines **naming rules for GitHub Actions workflows** in this repository.
The goal is clarity, safety, and long-term maintainability — not cleverness.

If you can understand what a workflow does **without opening the YAML**, the name is correct.

---

## Core Principle

> **Workflow names reflect intent, not tools.**

Names should answer one question immediately:

> *Does this workflow validate code, or does it produce / publish artifacts?*

---

## Category 1: `ci-*` — Validation Only

### Definition

Workflows prefixed with `ci-`:

* Validate correctness, quality, or standards
* Are safe to run frequently (PRs, pushes)
* **Never publish or deploy artifacts**

These workflows answer:

> "Is this change acceptable?"

### Examples

* `ci-fast` — quick PR feedback (compile + lightweight tests)
* `ci-quality` — formatting, linting, static analysis
* `ci-test` — full test suite (including integration / Testcontainers)

### Rules

* ✅ May fail safely
* ✅ May run on forks
* ❌ Must not push images, releases, or deployments
* ❌ Must not mutate external systems

---

## Category 2: `image-*` — Artifact Lifecycle (Docker Images)

### Definition

Workflows prefixed with `image-`:

* Build or distribute container images
* Are gated by branch, tags, or feature flags
* Operate on **real artifacts**

These workflows answer:

> "What happens to the container image?"

### Examples

* `image-build` — build image only (no push)
* `image-publish` — build + push image to registry

### Rules

* ❌ Must not run on every PR by default
* ✅ Must be explicitly gated (tags, vars, canonical repo checks)
* ✅ Naming should reflect lifecycle stage (`build`, `publish`, `scan`, `sign`)

---

## Category 3: `release-*` — Versioning & Source Releases

### Definition

Workflows prefixed with `release-`:

* Create versioned releases
* Tag source code
* Generate changelogs

These workflows answer:

> "Are we cutting a new version?"

### Examples

* `release` or `release-semantic`
* `release-notes`

### Rules

* 🚨 Must be tightly gated (protected branches, semantic-release, GitHub App)
* 🚨 Must be auditable and deterministic
* ❌ Must not be confused with CI validation

---

## Category 4: `deploy-*` — Environment Mutation

### Definition

Workflows prefixed with `deploy-`:

* Change a running environment
* Apply Helm charts, infra, or runtime config

These workflows answer:

> "Where is this code running now?"

### Examples

* `deploy-staging`
* `deploy-production`

### Rules

* 🚨 Must never run on PRs
* 🚨 Must be environment-specific
* 🚨 Must be reversible and observable

---

## Why This Matters

Clear naming provides:

* 🔍 Instant understanding in the GitHub Actions UI
* 🛡️ Safer defaults (validation ≠ publishing)
* 🧠 Lower cognitive load for new contributors
* 📈 Scalability as workflows grow

Bad naming leads to:

* Accidental publishing
* Confusing failures
* Fragile pipeline logic

---

## Final Checklist (Before Adding a Workflow)

Ask yourself:

1. Does this **validate** code? → `ci-*`
2. Does this **create or publish artifacts**? → `image-*`
3. Does this **cut a version**? → `release-*`
4. Does this **change a live environment**? → `deploy-*`

If the name doesn’t answer that question clearly, rename it.

---

**Naming is architecture. Treat it accordingly.**
