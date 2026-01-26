# Bootstrap Scripts

This document describes the purpose and usage of the repo’s bootstrap scripts, and how they interact with **local settings**.

Bootstrap scripts exist to eliminate a class of frustrating, non-obvious **permission**, **line ending**, and **git hook** issues on local machines **without affecting CI**.

Scripts covered:

- `scripts/bootstrap-common.sh` (shared logic)
- `scripts/bootstrap-macos.sh` (macOS entry point)
- `scripts/bootstrap-linux.sh` (Linux entry point)

---

## Purpose

Local development environments can drift due to:

- ZIP downloads
- File copies outside of Git
- Filesystem / editor differences across OSes
- Partial or shallow checkouts

Bootstrap scripts ensure:

- Required project scripts are executable
- Repo-managed Git hooks are executable and configured
- Common local hygiene issues are corrected early

They are **safe**, **idempotent**, and **explicitly invoked** (no hidden automation).

---

## Relationship to local settings

Bootstrap behavior is influenced by **repo-committed local settings**:

```json
{
  "checks": {
    "executableBits": { "strict": 2 },
    "lineEndings": { "enforce": true },
    "filePermissions": { "warnOnGroupWrite": true }
  },
  "git": {
    "autoInstallHooks": true
  },
  "make": {
    "defaultTarget": "verify"
  }
}
```

These settings:

- Apply **locally only**
- Never affect CI behavior
- Are intended for ergonomics and early feedback

See `docs/LOCAL_ENVIRONMENT.md` for full details.

---

## What bootstrap does

When run on a supported OS, bootstrap:

1. Ensures execution from the repo root (so paths are correct)
2. Ensures Git uses the repo-managed hooks directory:

   ```bash
   git config core.hooksPath .githooks
   ```

3. Ensures executable permissions for **regular files only** (best effort):

   - files in `.githooks/`
   - files in `scripts/`

   Directories are intentionally ignored and no recursion is performed.

4. Honors relevant local settings where applicable:
   - `checks.executableBits` → auto-fix executable permissions locally
   - `git.autoInstallHooks` → configure repo-managed hooks during bootstrap

---

## What bootstrap does NOT do

- ❌ Does not run automatically on clone
- ❌ Does not modify CI behavior
- ❌ Does not install dependencies
- ❌ Does not recurse into subdirectories
- ❌ Does not change application or runtime configuration

---

## How to run

### Recommended (via Make)

```bash
make hooks
```

or during first-time setup:

```bash
make bootstrap
```

### Direct invocation

macOS:

```bash
./scripts/bootstrap-macos.sh
```

Linux:

```bash
./scripts/bootstrap-linux.sh
```

---

## OS-specific behavior

### macOS (`scripts/bootstrap-macos.sh`)

- Runs only when `uname -s` is `Darwin`
- Prints a friendly message and exits on non-macOS systems
- Delegates all shared work to `scripts/bootstrap-common.sh`

### Linux (`scripts/bootstrap-linux.sh`)

- Runs only when `uname -s` is `Linux`
- Prints a friendly message and exits on non-Linux systems
- Delegates all shared work to `scripts/bootstrap-common.sh`

### Shared helper (`scripts/bootstrap-common.sh`)

The common bootstrap helper performs the actual work:

- Resolves repo root and `cd`s there
- Applies `chmod +x` to **files only** in `scripts/` and `.githooks/` (best effort)
- Sets `git config core.hooksPath .githooks`

---

## When to re-run

Re-run bootstrap if you see errors like:

```text
permission denied
hook was ignored because it's not executable
```

or notice unexpected local diffs related to permissions or line endings.

---

## Relationship to other tooling

Bootstrap works together with:

- `scripts/check-executable-bits.sh` — verifies executable bits (auto-fix locally, enforce in CI)
- `make hooks` / `make bootstrap` — canonical entry points
- `docs/LOCAL_ENVIRONMENT.md` — local-only behavior and settings
- `ADR-000` — CI as source of truth
- `ADR-007` — commit message enforcement strategy

---

## Design principles

- Explicit execution (no hidden magic)
- Repo-managed hooks
- OS-specific entry points with shared logic
- Cross-platform safety
- CI remains authoritative
- Local developer convenience only

---

## Summary

Bootstrap scripts eliminate a class of local permission, line ending, and git hook issues in a safe, explicit way.

If something suddenly stops working locally due to environment drift, bootstrap is the first thing to run.
