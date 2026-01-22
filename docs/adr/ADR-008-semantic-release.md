# ADR-008: CI-Managed Releases with semantic-release

- **Status:** Accepted
- **Date:** 2026-01-22
- **Deciders:** Project maintainers
- **Scope:** Release management, versioning, changelog generation

---

## Context

This project prioritizes **CI as the single source of truth**, strong quality gates, and minimal manual steps for release management.

Historically, release processes that rely on:

- local version bumps
- manual changelog edits
- ad-hoc tagging

tend to drift from actual commit history, introduce human error, and create inconsistent artifacts.

At the same time, the project already enforces:

- **Conventional Commits**
- commit message validation via Commitizen
- protected branches and CI-driven workflows

We need a release system that:

- derives versions from commit history
- runs only in CI
- produces reproducible artifacts
- avoids modifying source-controlled version files during development

---

## Decision

We adopt **semantic-release** as the **sole authority** for releases.

Releases are:

- triggered **only in CI**
- executed **only on the `main` branch**
- driven entirely by **Conventional Commit history**
- published using a **GitHub App token**

### semantic-release responsibilities

semantic-release is responsible for:

- calculating the next semantic version
- generating release notes
- updating `CHANGELOG.md`
- creating Git tags
- publishing GitHub releases
- uploading built artifacts

### Explicit non-responsibilities

semantic-release **does not**:

- update version fields in source files (e.g. `build.gradle`)
- rely on local release commands
- allow manual version bumps

Artifact versioning is injected **at build time** via CI (e.g. Gradle `-PreleaseVersion`).

---

## Implementation

### CI execution

semantic-release runs in GitHub Actions using:

```bash
npx semantic-release
```

Dependencies are installed with:

```bash
npm ci
```

This ensures:

- pinned dependency versions
- deterministic CI behavior
- no reliance on npm scripts

### Authentication

Releases use a **GitHub App installation token** rather than the default `GITHUB_TOKEN` to:

- allow changelog commits back to the repository
- create tags and releases with elevated permissions
- avoid token permission limitations

Both `GITHUB_TOKEN` and `GH_TOKEN` are set to the App token for compatibility.

---

## Guardrails

To prevent accidental or manual releases:

- Local commands such as `cz bump` and `cz changelog` are **discouraged**
- CI enforces guards that:
  - block changelog or version file changes in PRs
  - allow release artifacts only when authored by semantic-release on `main`
- Branch protection prevents direct pushes to `main`

These guardrails ensure CI remains the **only release authority**.

---

## Consequences

### Positive

- Fully automated, reproducible releases
- Clean Git history without version-churn commits
- Versions always reflect commit intent
- Reduced cognitive load for contributors
- Clear separation between development and release concerns

### Trade-offs

- Releases cannot be cut locally
- Requires Node tooling in CI (even for a Java project)
- Debugging release failures happens in CI, not locally

These trade-offs are acceptable given the benefits and alignment with project goals.

---

## Alternatives Considered

### Local version bumping (Commitizen / manual)

Rejected due to:

- risk of human error
- version drift
- poor CI parity

### File-based versioning (e.g. updating `build.gradle`)

Rejected due to:

- noisy commits
- merge conflicts
- unclear source of truth

---

## Related Decisions

- **ADR-000** — Quality Gates and CI as Authority  
- **ADR-006** — Local Developer Experience and Verification  
- **ADR-005** — Phased Security Approach  

---

## Notes

semantic-release complements Commitizen:

- Commitizen: **authoring and validation**
- semantic-release: **versioning and publishing**

This separation of concerns is intentional and enforced.
