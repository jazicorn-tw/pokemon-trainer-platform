<!-- markdownlint-disable-file MD041 -->

# Linting, Formatting & Static Analysis

This project enforces **automated formatting, linting, and static analysis** to keep the codebase consistent,
catch bugs early, and prevent quality regressions in PRs.

These checks form a **quality gate** (objective, automated checks), not a style debate.

This document reflects the **current Gradle configuration** and aligns with **ADR-000**.

---

## What runs by default?

By default, **formatting, linting, static analysis, and tests are applied to both production and test code**
to ensure consistent quality standards across the entire codebase.

### Enabled by default (production + tests)

- ✅ **Spotless** (formatting for all Java sources)
- ✅ `checkstyleMain`
- ✅ `checkstyleTest`
- ✅ `pmdMain`
- ✅ `pmdTest`
- ✅ `spotbugsMain`
- ✅ `spotbugsTest`

> Test code is intentionally included in the quality gate.  
> Any noise is handled through targeted refactors or narrow suppressions, not by disabling checks.

---

## Tools

### Spotless — Formatting (Google Java Format)

**Purpose:** Deterministic, opinionated formatting (Prettier-equivalent for Java).

Why Spotless:

- Same output everywhere
- Zero style debates
- CI-safe verification
- Gradle-native tasks

Commands:

```bash
# Auto-format locally
./gradlew spotlessApply

# Verify formatting (CI-safe, non-mutating)
./gradlew spotlessCheck
```

Spotless formats **all Java sources**, including tests.

---

### Checkstyle — Code Style & Consistency

**Purpose:** Enforces structural and naming conventions.

Catches:

- Unused imports
- Missing braces
- Naming violations
- Line length issues

Config:

- `config/checkstyle/checkstyle.xml`

Reports:

- `build/reports/checkstyle/`

Applies to:

- `src/main/**`
- `src/test/**`

---

### PMD — Code Smells & Best Practices

**Purpose:** Flags error-prone patterns and best-practice violations.

Rulesets used:

- `category/java/bestpractices.xml`
- `category/java/errorprone.xml`

Reports:

- `build/reports/pmd/`

Applies to:

- `src/main/**`
- `src/test/**`

---

### SpotBugs — Bug Pattern Detection

**Purpose:** Static analysis for likely runtime issues.

Catches:

- Null pointer risks
- Incorrect equality (`equals` / `hashCode`)
- Bad field exposure patterns
- Suspicious logic and concurrency mistakes

Filter (to reduce framework false positives):

- `config/spotbugs/exclude.xml`

Reports:

- `build/reports/spotbugs/`

Applies to:

- `src/main/**`
- `src/test/**`

---

## How to run

### Run the full quality gate (format + lint + analysis + tests)

```bash
./gradlew clean check
```

### Run formatting only

```bash
./gradlew spotlessApply
```

### Verify formatting only (CI-safe)

```bash
./gradlew spotlessCheck
```

### Run only linting & static analysis (main + test)

```bash
./gradlew checkstyleMain checkstyleTest pmdMain pmdTest spotbugsMain spotbugsTest
```

### Run tests only

```bash
./gradlew test
```

---

## CI expectation

CI runs:

```bash
./gradlew clean check
```

CI also uploads artifacts (even on failure):

- `build/reports/**`
- `build/test-results/**`

This makes failures debuggable without re-running locally.

---

## How to fix failures

### Formatting (Spotless)

- Run:

  ```bash
  ./gradlew spotlessApply
  ```

- Re-run:

  ```bash
  ./gradlew spotlessCheck
  ```

---

### Checkstyle failure

- Open:
  - `build/reports/checkstyle/main.html`
  - `build/reports/checkstyle/test.html`
- Fix formatting or naming issues reported.
- Re-run:

  ```bash
  ./gradlew checkstyleMain checkstyleTest
  ```

---

### PMD failure

- Open:
  - `build/reports/pmd/main.html`
  - `build/reports/pmd/test.html`
- Fix the flagged smell or refactor the method.
- Re-run:

  ```bash
  ./gradlew pmdMain pmdTest
  ```

---

### SpotBugs failure

- Open:
  - `build/reports/spotbugs/main.html`
  - `build/reports/spotbugs/test.html`
- Fix the underlying issue where possible.
- If it is a known framework false positive:
  - Prefer narrow suppression (`@SuppressFBWarnings`)
  - Or tighten the exclude filter:
    - `config/spotbugs/exclude.xml`
- Re-run:

  ```bash
  ./gradlew spotbugsMain spotbugsTest
