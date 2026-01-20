# macOS Bootstrap Script

This document describes the purpose and usage of the macOS bootstrap script:

```bash
scripts/bootstrap-macos.sh
```

---

## Purpose

On macOS, executable permissions (`+x`) can be lost due to:

- ZIP downloads
- File copies outside of Git
- Certain filesystem or editor behaviors

This script ensures that all required project scripts and Git hooks are executable so local development works reliably.

It is **safe, idempotent, and macOS-only**.

---

## What the script does

When run on macOS (`Darwin`), the script:

1. Ensures Git uses the repo-managed hooks directory:

   ```bash
   git config core.hooksPath .githooks
   ```

2. Ensures executable permissions for:
   - All regular files in `.githooks/`
   - All shell scripts in `scripts/`

3. Prints clear status messages for visibility

On **non-macOS systems**, the script exits immediately with a friendly message and performs no actions.

---

## What the script does NOT do

- ❌ Does not run automatically on clone
- ❌ Does not modify CI behavior
- ❌ Does not install dependencies
- ❌ Does not affect Linux or Windows environments

---

## How to run it

### Recommended (via Make)

```bash
make hooks
```

or during first-time setup:

```bash
make bootstrap
```

### Direct invocation

```bash
./scripts/bootstrap-macos.sh
```

---

## When to re-run

Re-run this script if you see errors like:

```text
permission denied
hook was ignored because it's not executable
```

---

## Relationship to other tooling

This script works together with:

- `scripts/install-hooks.sh` — installs repo-local Git hooks
- `scripts/check-executable-bits.sh` — verifies executable bits (WARN locally, FAIL in CI)
- `make hooks` / `make bootstrap` — canonical entry points
- `ADR-007` — commit message enforcement strategy
- `ADR-000` — CI as source of truth

---

## Design principles

- Explicit execution (no hidden magic)
- Repo-managed hooks
- Cross-platform safety
- CI remains authoritative
- Local developer convenience only

---

## Summary

The macOS bootstrap script exists to eliminate a class of frustrating, non-obvious permission errors on macOS without introducing risk or hidden behavior.

If something suddenly stops working locally, this script is the first thing to run.
