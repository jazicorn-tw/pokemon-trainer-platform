<!-- markdownlint-disable-file MD036 -->

# 📂 Documentation Table of Contents

This document provides a **high-level map of the `docs/` directory**.
It is intended to help contributors quickly understand **where information lives**
and **where new documentation should be added**.

Use this as your first stop when navigating the documentation.

---

## 🗂️ Top-level folders

### `_templates/`

Reusable documentation templates.

Used for:

- ADR templates
- Environment or config templates
- Any standardized doc format

If you are creating a *new kind* of document that should be consistent over time,
start here.

---

### `adr/` — Architecture Decision Records

Authoritative records of **why key technical decisions were made**.

Includes:

- Trade-offs
- Alternatives considered
- Long-term implications

If the question is *“why did we choose this?”*, the answer belongs here.

---

### `commit/` — Commit conventions & Git hygiene

Documentation related to **commit messages and Git workflow standards**.

Includes:

- Commit message conventions
- Commitizen usage
- Pre-commit expectations

If a change fails because of a commit rule, check here.

---

### `devops/` — CI, deployment, and operations

Everything related to **running, building, securing, and deploying** the system.

Includes:

- CI workflows and toggles
- Image build & publish rules
- Deployment strategies
- Health and security docs

If it runs in CI or production, it’s documented here.

---

### `enviroment/` — Local environment setup

Documentation for **local infrastructure and environment configuration**.

Includes:

- Docker & Colima setup
- Local configuration expectations
- Environment troubleshooting

If something fails *before* the app starts, start here.

> Note: folder name preserved for compatibility, despite the typo.

---

### `faq/` — Frequently asked “why” questions

Short, focused explanations for **confusing or non-obvious behaviors**.

Includes:

- Git quirks
- Tooling surprises
- Repo-specific conventions

If the question starts with *“why does this repo do that?”*, it belongs here.

---

### `make/` — Makefile documentation

Documentation for the **Make-based developer workflow**.

Includes:

- Makefile structure
- Roles and categories
- How to discover and use Make targets

If you’re unsure which `make` command to run, start here.

---

### `onboarding/` — Contributor onboarding

Step-by-step guidance for **new contributors**.

Includes:

- First-day and first-PR guides
- Bootstrap workflow
- Common early failures

This is the recommended starting point for new contributors.

---

### `phases/` — Roadmap & project evolution

High-level documentation describing the **planned evolution** of the platform.

Includes:

- Current phase scope
- Future phases
- Explicitly deferred work

Helps explain *why* some features are intentionally incomplete.

---

### `quality/` — Quality gates & standards

Documentation explaining **quality expectations and enforcement**.

Includes:

- Linting philosophy
- Static analysis rules
- Why the bar is set where it is

If CI rejects your change, this folder likely explains why.

---

### `services/` — External services & dependencies

Documentation for **infrastructure services** the platform depends on.

Includes:

- PostgreSQL expectations
- Integration assumptions

If a dependency has rules or constraints, document them here.

---

### `testing/` — Testing strategy & troubleshooting

How tests work, how they fail, and how to debug them.

Includes:

- Local vs CI testing behavior
- Testcontainers usage
- Common CI/container failures
- Viewing test reports

If tests fail and the reason isn’t obvious, this is your map.

---

### `tooling/` — Developer tooling & inspection

Documentation for **local developer tooling and inspection helpers**.

Includes:

- Doctor checks
- Local CI simulation (`act`)
- Repo inspection (`make tree`)

If a tool helps you understand or validate the repo, it belongs here.

---

## 📌 Root files

### `README.md`

The **documentation index and philosophy**.

Explains:

- Purpose of the `docs/` folder
- How docs are organized
- How to decide where new documentation goes

Start here if you’re unsure where to look.

---

## 🧠 How to use this TOC

- Skim to orient yourself
- Use folder contracts to decide where new docs belong
- Prefer adding documentation over adding comments or tribal knowledge

If it matters, document it.
