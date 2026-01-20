# Pre-commit hook

This repo uses a **Git `pre-commit` hook** to enforce **ADR-000 quality gates** *before* code leaves your machine.

The goal is **fast, deterministic feedback** that prevents style-only CI failures and catches common issues early.

---

## What runs on `git commit`

The hook runs **only if at least one relevant file is staged**.

Relevant staged file patterns (as implemented in `.githooks/pre-commit`):

- `*.java`
- `build.gradle`
- `settings.gradle`
- `gradle.properties`
- `src/*` (anything under `src/`)
- `config/*` (anything under `config/`)
- `.github/workflows/*` (anything under GitHub Actions workflows)

If no relevant files are staged, the hook prints a message and exits.

When the hook runs, it performs:

1. **Spotless auto-format** (default ON)
2. **Static analysis (main sources)**
   - `checkstyleMain`
   - `pmdMain`
   - `spotbugsMain`
3. **Unit tests** *(optional — only when enabled)*

> **Important:** unit tests are **skipped by default** and only run when `RUN_TESTS=1` is set.

---

## Why Spotless runs first

Formatting is deterministic and cheap. Running it first reduces “format-only” CI failures.

**Note:** Spotless **mutates files**. If it reformats anything, the hook aborts the commit so you can:

1. review the formatting changes
2. `git add ...` to re-stage
3. commit again

---

## Overrides (one-off per commit)

- Skip this hook once:

  ```bash
  SKIP_QUALITY=1 git commit -m "..."
  ```

- Run unit tests too:

  ```bash
  RUN_TESTS=1 git commit -m "..."
  ```

- Disable auto-format (validate only):

  ```bash
  AUTO_FORMAT=0 git commit -m "..."
  ```

- Print debug info (what files were staged and which one triggered the hook):

  ```bash
  DEBUG_PRECOMMIT=1 git commit -m "..."
  ```

- Hard bypass (skips *all* Git hooks):

  ```bash
  git commit --no-verify
  ```

---

## Run the same checks without committing

Recommended (matches CI expectations):

```bash
make quality
```

Optional unit tests:

```bash
make test
```

Gradle equivalents:

- Format:

  ```bash
  ./gradlew spotlessApply
  ```

- Static analysis only:

  ```bash
  ./gradlew checkstyleMain pmdMain spotbugsMain
  ```

- Unit tests:

  ```bash
  ./gradlew test
  ```

---

## Make targets

- `make hooks` — installs Git hooks (runs `./scripts/install-hooks.sh`)
- `make quality` — runs `spotlessApply` then `./gradlew clean check`
- `make test` — runs unit tests
- `make bootstrap` — runs `hooks` + `quality`
