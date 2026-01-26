<!-- markdownlint-disable-file MD033 MD036 -->
<!-- markdownlint-disable-file MD033 MD060 -->

# 📚 Documentation Guide — Pokémon Trainer Platform

This folder contains the **authoritative documentation** for the Pokémon Trainer Platform.

The goal of this documentation set is to explain **how and why the system is built the way it is**, not just how to run it.

If something is non-obvious, opinionated, or easy to misuse — it belongs here.

---

## 🗂️ Documentation structure

📄 **Documentation map:** [`DOCS_TOC.md`](./DOCS_TOC.md)

This table of contents:

- Lists **every top-level folder** in `docs/`
- Describes the **purpose and scope** of each folder
- Explains **where new documentation should go**

If you are unsure where to add or find documentation, **start with `DOCS_TOC.md`**.

---

## 🎯 Purpose of the docs folder

The `docs/` directory exists to:

- Capture **architectural decisions** and their rationale
- Provide **clear onboarding paths** for new contributors
- Document **tooling, workflows, and guardrails**
- Preserve **institutional knowledge** that would otherwise live in heads or Slack

This is **living documentation**.  
Docs are expected to evolve as the system evolves.

---

## 🧭 How to use this documentation

### New contributors (recommended order)

1. `onboarding/`
   - First-day and first-PR guides
   - Common local setup failures
   - Bootstrap and environment expectations

2. `adr/`
   - Architectural Decision Records
   - Explains *why* key technical choices were made

3. `phases/`
   - High-level product and engineering roadmap
   - What exists now vs what is planned

4. `tooling/`
   - Developer-experience tooling (doctor, tree, act, etc.)

---

## 🗂️ Folder-by-folder overview

### `adr/` — Architecture Decision Records

Authoritative records of **non-trivial architectural decisions**.

Use ADRs when:

- There are multiple reasonable options
- The choice has long-term consequences
- The decision may be questioned later

Examples:

- PostgreSQL everywhere (no H2)
- Testcontainers for integration tests
- Local CI simulation with `act`

---

### `onboarding/` — Contributor onboarding

Everything a new contributor needs to become productive **without tribal knowledge**.

Includes:

- Day 1 / Day 2 onboarding guides
- Environment setup
- Common failure modes and fixes

If a contributor asks:
> “How do I get started?”  
the answer should live here.

---

### `tooling/` — Developer experience & inspection tools

Documentation for **local developer tooling** and inspection helpers.

Includes:

- Doctor checks and JSON output
- Local CI simulation (`act`)
- Repo inspection (`make tree`)

This folder documents *how to work with the repo*, not the application itself.

📄 Start here:

- `tooling/DOCTOR_JSON.md`
- `tooling/TREE.md`

---

### `devops/` — CI, deployment, and operational docs

Documentation for **CI/CD, security, and operational behavior**.

Includes:

- CI workflows and toggles
- Image build & publish rules
- Helm and deployment strategy
- Health and security docs

This is the source of truth for anything that runs **outside your laptop**.

---

### `testing/` — Testing strategy & troubleshooting

How testing works, how it fails, and how to debug it.

Includes:

- Local vs CI testing behavior
- Testcontainers + PostgreSQL
- Common CI and container errors
- Viewing and interpreting test reports

If tests fail in CI and the reason isn’t obvious, the fix should land here.

---

### `services/` — External dependencies & integrations

Documentation for **infrastructure services** the platform depends on.

Currently includes:

- PostgreSQL baseline and expectations

Add docs here when:

- The service has operational or schema expectations
- Misconfiguration causes subtle failures

---

### `quality/` — Linting & static analysis

Documentation for **quality gates** enforced locally and in CI.

Includes:

- Linting philosophy
- Static analysis tooling

This explains *why* the bar is set where it is.

---

### `phases/` — Roadmap & evolution

Describes the **planned evolution** of the platform.

Includes:

- Current phase scope
- Future phases and constraints

This helps contributors understand:

- Why certain things look incomplete
- What is intentionally deferred

---

### `make/` — Makefile documentation

Documentation for the Make-based developer workflow.

Includes:

- Makefile structure
- Roles and categories
- How to discover available commands

---

### `faq/` — Explanations of “weird” things

Short, focused explanations for topics that commonly confuse contributors.

Example:

- Executable bits in Git

If the question starts with:
> “Why does this repo do *that*?”

…it probably belongs here.

---

## 🧠 How to decide where new docs go

Use this decision table:

| Question | Put it in |
|--------|-----------|
| Why was a technical decision made? | `adr/` |
| How do I get started or unstuck? | `onboarding/` |
| How do I use local tooling? | `tooling/` |
| How does CI / deploy work? | `devops/` |
| Why did tests fail? | `testing/` |
| What phase are we in? | `phases/` |
| Why is this repo opinionated? | `quality/` |
| Why is this weird? | `faq/` |

If in doubt:

- Prefer **clarity over cleverness**
- Prefer **explicit docs over Slack answers**
- Prefer **adding a doc over adding comments**

---

## ✨ Documentation principles

- Docs explain **intent**, not just steps
- Docs are written for **future contributors**
- Docs should answer “why?” at least once
- Docs are part of the product, not an afterthought

If something surprised you while working in this repo, document it.

---

## 📌 Summary

The `docs/` folder is the **memory of this project**.

Good documentation:

- Reduces onboarding time
- Prevents repeated mistakes
- Makes architectural intent durable

If it matters, document it.
