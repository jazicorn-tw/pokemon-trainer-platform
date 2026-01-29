<!-- markdownlint-disable-file MD036 -->

# 🚫 Release Commit Scope Policy

This document defines the **rules around the `(release)` commit scope**.

---

## Reserved `(release)` commit scope

The `(release)` commit scope is **reserved exclusively for CI automation**.

In this repository, releases are an **operational concern**, not a manual developer
action. Version bumps, tags, GitHub Releases, and changelog commits are created
**only** by `semantic-release` running in GitHub Actions.

---

## What this means

- Humans **must not** author commits like:

  ```text
  chore(release): 1.2.3
  ```

- Such commits are blocked locally by the `commit-msg` hook.
- The only valid source of `(release)` commits is CI automation (bots).

---

## What to use instead

| Intent                          | Commit pattern             |
|---------------------------------|----------------------------|
| CI / workflow wiring            | `chore(ci): ...`           |
| Release documentation / policy  | `docs(release-notes): ...` |
| Internal refactors              | `refactor: ...`            |
| Bug fixes                       | `fix: ...`                 |
| Features                        | `feat: ...`                |

---

## Why this rule exists

- Prevents **accidental releases**, especially during early project phases
- Keeps version history **intentional and auditable**
- Ensures releases always go through CI gates, not local machines
- Avoids humans impersonating automation via commit messages

If a release is desired, it must be triggered via the **release workflow** —
not a manual commit message.

---

## Related documentation

For CI-level enforcement and local simulation details, see:

- `docs/devops/RELEASE_GATING.md`
