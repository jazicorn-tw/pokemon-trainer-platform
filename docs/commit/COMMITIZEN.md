# 🧾 Commit Messages & Commitizen

This project enforces **Conventional Commits** to ensure:

- predictable releases
- meaningful changelogs
- clean, automated CI workflows

Commit message validation is enforced **locally** via a `commit-msg` hook and **authoritatively** via CI.

---

## ✨ What this gives us

- Consistent, machine-readable commit history  
- Automated semantic versioning (via CI)
- Auto-generated `CHANGELOG.md` (via CI)
- Clear intent for refactors, breaking changes, and features

---

## 🧠 The rules (Conventional Commits)

All commit messages must follow this format:

```text
<type>(optional scope): <description>
```

### Common types

| Type        | Purpose                             |
|-------------|-------------------------------------|
| `feat`      | New feature (minor version signal)  |
| `fix`       | Bug fix (patch signal)              |
| `refactor`  | Code change with no behavior change |
| `test`      | Tests only                          |
| `docs`      | Documentation only                  |
| `chore`     | Tooling, config, housekeeping       |
| `build`     | Build system or dependency changes  |
| `ci`        | CI configuration changes            |

### Breaking changes (pre-1.0)

For this project (currently `0.x`):

```text
feat!: change API contract
```

Breaking changes **do not** automatically bump to `1.0.0`.  
Major version stability is an explicit, intentional decision.

---

## 🛠️ Commitizen (`cz`)

This repo uses **Commitizen** to:

- validate commit messages
- guide authors toward correct Conventional Commit syntax

### Interactive commits (recommended)

Instead of writing commit messages manually, run:

```bash
cz commit
```

This ensures every commit complies with the required format.

---

## ⚠️ About `cz bump`

Commitizen includes commands such as:

```bash
cz bump
cz changelog
```

⚠️ **These commands are intentionally discouraged in this repository.**

### Why?

This project uses **semantic-release** in CI as the **single authority** for:

- version calculation
- changelog generation
- tagging
- GitHub releases

Running `cz bump` locally can:

- generate versions that do not match CI
- create changelog conflicts
- be rejected by CI guards

> **Guideline:**  
> Use Commitizen for **commit authoring only**.  
> Let CI handle all release concerns.

---

## 🔍 `commit-msg` hook (local enforcement)

We use a **repo-managed Git hook** at:

```text
.githooks/commit-msg
```

Git is configured with:

```bash
git config core.hooksPath .githooks
```

### What the hook does

- Runs on **every commit**
- Validates the commit message using:

```bash
cz check --commit-msg-file <file>
```

- Rejects invalid commit messages immediately, before they reach CI

---

## 🏷️ Versioning & changelog (CI-owned)

Releases are handled **exclusively in CI** via **semantic-release**.

CI is responsible for:

- calculating the next semantic version
- generating and updating `CHANGELOG.md`
- creating Git tags
- publishing GitHub releases

Local version bumps and changelog edits are allowed by tooling,
but **guarded against in CI** to ensure consistency.

---

## 📌 Notes for contributors

- You do **not** need Python to build the project
- Commitizen is only required for authoring commits
- Install Commitizen via:

```bash
pipx install commitizen
```
