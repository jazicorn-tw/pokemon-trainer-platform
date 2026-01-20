# ADR-007: Commit Message Enforcement via Commitizen + repo-managed commit-msg hook

## Status

Accepted

## Date

2026-01-20

## Context

This project adopts **Conventional Commits** to enable:

- semantic versioning
- deterministic changelog generation
- CI-aligned release automation
- consistent developer experience

We already enforce quality via CI (ADR-000), but commit message correctness must be validated **before commits enter history** to avoid broken releases and noisy CI failures.

Git hooks are the correct enforcement point for commit messages, but several constraints shaped the final design:

- Hooks must be **repo-managed** (not global, not user-specific)
- Hooks must work on **macOS and Linux**
- Hooks must be **explicit**, not magically installed
- Installer logic must **never live inside hooks**
- CI remains the **source of truth**
- Local tooling must fail fast but be bypassable in emergencies

---

## Decision

We enforce commit message correctness using:

1. **Commitizen** (`cz`) as the canonical Conventional Commits validator
2. A **repo-managed `commit-msg` Git hook** located at:

   ```bash
   .githooks/commit-msg
   ```

3. A **guarded hook implementation** that:
   - validates commit messages via `cz check`
   - explicitly prevents installer/setup commands from being embedded in the hook
4. Explicit, cross-platform **hook installation scripts**
5. A macOS bootstrap to handle executable-bit issues common on macOS filesystems

---

## Implementation

### Commit message validation

- All commits must follow Conventional Commits
- Validation is performed by:

  ```bash
  cz check --commit-msg-file <file>
  ```

- Developers are encouraged to use:

  ```bash
  cz commit
  ```

### Hook location

- Git is configured to use:

  ```bash
  git config core.hooksPath .githooks
  ```

- Hooks are tracked in the repository and versioned

### commit-msg hook responsibilities

The `.githooks/commit-msg` hook:

- Contains **only hook logic**
- Validates commit messages with Commitizen
- Supports a one-off bypass:

  ```bash
  SKIP_COMMIT_MSG_CHECK=1 git commit ...
  ```

- Fails loudly if installer commands are detected in the hook file itself

This guard prevents accidental corruption of the hook via copy/paste of setup snippets.

### Installer logic separation

All setup logic lives in scripts under `scripts/`:

- `scripts/install-hooks.sh`
  - sets `core.hooksPath`
  - ensures hooks and scripts are executable
- `scripts/bootstrap-macos.sh`
  - macOS-only
  - fixes executable bits on filesystems that strip `+x`

Installer logic is **explicitly forbidden** inside `.githooks/commit-msg`.

### Executable-bit enforcement

To prevent silent hook failures:

- `scripts/check-executable-bits.sh` verifies:
  - `scripts/*.sh`
  - `.githooks/*`
- Local behavior: WARN
- CI behavior (`STRICT=1`): FAIL

This ensures hooks remain executable across clones and environments.

---

## Consequences

### Positive

- Invalid commit messages never enter history
- Changelogs and version bumps remain reliable
- Developers get immediate, local feedback
- CI failures due to commit format are eliminated
- Hook behavior is explicit, inspectable, and auditable
- macOS/Linux parity is preserved

### Trade-offs

- Developers must install Commitizen locally
- Hooks require an explicit `make hooks` / `make bootstrap` step
- Slight upfront complexity in exchange for long-term stability

These trade-offs are acceptable and aligned with ADR-000.

---

## Alternatives Considered

### CI-only enforcement

Rejected:

- Fails too late
- Pollutes commit history
- Increases CI noise

### pre-commit framework

Rejected:

- Conflicts with repo-managed hooks (`core.hooksPath`)
- Adds unnecessary tooling indirection

### Global Git hooks

Rejected:

- Non-portable
- Non-auditable
- Violates repo-local guarantees

---

## Related ADRs

- **ADR-000** — Quality Gates & CI Authority
- **ADR-001+** — Phase-gated development decisions

---

## Summary

This ADR establishes a **strict but pragmatic** commit message enforcement strategy:

- Repo-managed
- CI-aligned
- Cross-platform
- Explicitly installed
- Impossible to silently break

Commit messages are now a **first-class quality gate**, enforced locally and trusted globally.
