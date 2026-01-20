# Onboarding

Welcome! 👋  
This repository is designed to provide **fast feedback**, **strong quality gates**, and **clear expectations** from day one.

If you follow the steps below, you should be able to:

- Get the project running locally
- Make your first PR confidently
- Understand *why* the guardrails exist (not just what they are)

---

## 🚀 Quick start (recommended)

After cloning the repo, run:

```bash
make bootstrap
```

This is the **single supported entry point** for new contributors.

### What `make bootstrap` does

1. Installs repo-local Git hooks (including commit message validation)
2. Verifies required local dependencies
3. Runs the local quality gate (formatting + static checks)
4. Fixes common macOS permission issues
5. Fails fast if your environment is misconfigured

📄 Details: [`MAKEFILE.md`](./files/MAKEFILE.md)

---

## 🧭 How onboarding is structured

Onboarding docs are intentionally **progressive**. You don’t need to read everything at once.

### Day-based flow

| When | What to read |
| ---- | ---- |
| Day 1 | [`DAY_1_ONBOARDING.md`](./DAY_1_ONBOARDING.md) — local setup, expectations |
| Day 2 | [`DAY_2_FIRST_PR.md`](./DAY_2_FIRST_PR.md) — first PR, CI, review flow |

---

## 🧑‍💻 Development workflow

```text
Code → cz commit → commit-msg hook → CI → review → merge
```

```mermaid
flowchart LR
    A[Write Code] --> B[cz commit]
    B --> C[commit-msg hook]
    C -->|pass| D[Push PR]
    D --> E[CI]
    E -->|pass| F[Merge]
    C -->|fail| A
    E -->|fail| A
```

### 📝 Commit messages (important)

This project **enforces Conventional Commits** to support:

- semantic versioning
- clean changelogs
- reliable release automation

#### ✅ Preferred way to commit

```bash
cz commit
```

This interactive command:

- guides you through the correct commit format
- prevents rejected commits
- keeps history consistent across contributors

#### ⚠️ About `git commit`

You *can* use `git commit` **only if** you already know the correct format.

If the message is invalid:

- the `commit-msg` hook will reject it
- you’ll be asked to fix the message before committing

> **Rule of thumb:**  
> Use `cz commit` unless you have a specific reason not to.

📄 Details:

- [`docs/onboarding/setup/COMMITIZEN.md`](./setup/COMMITIZEN.md)
- [`docs/adr/ADR-007-commit-msg.md`](../adr/ADR-007-commit-msg.md)

---

## 🧱 Quality gates & ADRs

All non-obvious rules are documented as Architecture Decision Records.

### Core ADRs

- ADR-000 — Linting & quality gates  
- ADR-001 — PostgreSQL everywhere  
- ADR-002 — Testcontainers  
- ADR-003 — Actuator health checks  
- ADR-004 — `.env` & config precedence  
- ADR-005 — Phased security  
- ADR-007 — Commit message enforcement (Commitizen)

📄 Index: [`docs/adr/README.md`](../adr/README.md)

---

## 🧪 Testing & CI

📄 Start here:

- [`SETUP_TESTING.md`](./setup/SETUP_TESTING.md)
- [`docs/testing/TESTING.md`](../testing/TESTING.md)
- [`docs/testing/CI_TROUBLESHOOTING.md`](../testing/CI_TROUBLESHOOTING.md)

---

## 🐳 Docker & local services

📄 Docs:

- [`SETUP_DOCKER.md`](./setup/SETUP_DOCKER.md)
- [`docker-compose.yml`](../../docker-compose.yml)

---

## 🛠️ Local dev environment

📄 Docs:

- [`DEV_ENVIRONMENT.md`](./DEV_ENVIRONMENT.md)
- [`DEPENDENCIES.md`](./DEPENDENCIES.md)
- [`.vscode/README.md`](../../.vscode/README.md)

---

## 🧠 Guiding principle

> **Use `cz commit` for guidance.  
> Let hooks fail fast.  
> CI protects the system.  
> ADRs explain why.**

Welcome aboard 🚀
