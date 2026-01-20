# 🧰 Makefile Commands Overview

This project uses a small set of **simple, memorable Makefile commands** to standardize local development and provide **fast feedback aligned with CI**, as defined in **ADR-000**.

Formatting, linting, static analysis, and tests together form a **single quality gate**.
CI is the **authoritative enforcer** of that gate.

---

## ✅ What this gives you

### Simple, memorable commands

```bash
make hooks     # install git hooks
make quality   # full local quality gate (CI-aligned)
make test      # run tests only
```

Each command does **one clear thing** and maps to a specific workflow.

---

## 🔍 What each command actually runs

### `make hooks`

Sets up local safeguards.

- Installs pre-commit hooks
- Ensures formatting and quality checks run before commits
- Provides early feedback aligned with CI expectations

Run once after cloning.

---

### `make quality` (full local quality gate)

Runs a **local approximation of the CI quality gate**, with developer-friendly behavior:

1. **Formatting (local convenience)**
   - `./gradlew spotlessApply`
   - Auto-formats code to avoid format-only CI failures

2. **Verification, linting & static analysis**
   - `./gradlew clean check`
   - Includes:
     - Spotless (format verification)
     - Checkstyle
     - PMD
     - SpotBugs
     - Tests

This command reflects the **intent and scope** of CI, but is optimized for local use.

⚠️ **Source of truth**

CI always runs:

```bash
./gradlew clean check
```

CI does **not** auto-format and is the only authoritative quality gate.

---

### `make test`

```bash
./gradlew test
```

- Runs tests only
- Useful during tight feedback loops
- Does **not** replace `make quality` before pushing
- Does **not** satisfy the ADR-000 quality contract

---

## 🤔 Why this is good

### 1. Lowers cognitive load

Contributors don’t need to remember long Gradle commands or internal task wiring.

One mental model:

> “Before I push, I run `make quality`.”

---

### 2. Aligns with CI without pretending to be CI

- Same rules
- Same failure modes
- Same expectations
- Clear separation between **local convenience** and **CI enforcement**

No “but it passed locally” ambiguity.

---

### 3. No new tooling required

- Uses `make` (already available on most systems)
- Wraps existing Gradle tasks
- No additional CLIs, wrappers, or custom runners

---

### 4. Reinforces ADR-000 in practice

This Makefile operationalizes the decision that:

- Formatting comes first
- Linting defines the baseline
- Static analysis is non-negotiable
- CI enforces the contract authoritatively

---

### 5. Reads well in docs & interviews

- Easy to explain during onboarding
- Clear signal of engineering maturity
- Demonstrates intentional developer-experience design
- Shows alignment between docs, tooling, and CI

---

## 📌 Recommended usage

- Run `make hooks` once after cloning
- Run `make quality` before pushing any change
- Use `make test` during day-to-day development

For first-time setup, prefer:

```bash
make bootstrap
```

This installs hooks **and** verifies the full quality gate passes on your machine.
