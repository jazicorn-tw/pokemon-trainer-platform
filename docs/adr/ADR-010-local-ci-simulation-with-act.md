<!-- markdownlint-disable-file MD036 -->

# ADR-010: Local CI Simulation with `act`

**Status:** Accepted  
**Date:** 2026-01-24

---

## Context

This repository relies heavily on GitHub Actions for CI, including:

- Java / Gradle test execution with Testcontainers
- Docker image builds via Buildx
- Helm chart linting
- Release and publishing gates

Developers need a **fast, reliable way to reproduce CI behavior locally** in order to:

- Debug workflow logic before pushing
- Iterate on CI changes without burning GitHub minutes
- Diagnose platform-specific issues (Docker, sockets, permissions)

GitHub Actions runners are ephemeral and opaque, making local reproduction difficult without tooling support.

---

## Decision

We adopt **`act`** as the **official tool for local GitHub Actions simulation**.

To ensure consistency and avoid common failure modes, `act` is:

- Wrapped behind Makefile targets (`make run-ci`, `make list-ci`)
- Run with a pinned runner image (`catthehacker/ubuntu:full-latest`)
- Executed with explicit Docker socket and architecture configuration
- Guarded in workflows via an `ACT` environment flag when behavior must differ

Local CI simulation is considered a **first-class developer workflow**, but **does not replace real CI**.

---

## Implementation

### Makefile integration

Local CI is invoked via:

```bash
make run-ci [workflow] [job]
```

Examples:

```bash
make run-ci                 # defaults to ci workflow
make run-ci ci test         # run a single job
make run-ci build-image     # run a different workflow
make list-ci build-image   # list jobs
```

The Make wrapper ensures:

- `ACT=true` is exported
- The Docker daemon socket is mounted at `/var/run/docker.sock`
- The runner container runs as root to avoid socket permission issues

---

### Workflow guards

Some GitHub Actions steps behave differently under `act` (notably toolcache usage).

For these cases, workflows may branch on:

```yaml
if: ${{ env.ACT }}
```

Example use cases:

- Installing Helm via script under `act` instead of `azure/setup-helm`
- Skipping release or publishing steps locally

At the workflow level, `ACT` is defined as an empty variable to satisfy schema validation:

```yaml
env:
  ACT: ""
```

The Make wrapper overrides this value during local runs.

---

## Non-Goals

- `act` is **not** expected to perfectly reproduce GitHub-hosted runners
- Secrets-dependent workflows (release, publish) are **not required** to run locally
- Local success under `act` does **not guarantee** CI success

---

## Consequences

### Positive

- Faster CI iteration and debugging
- Clear, documented local CI entry point
- Reduced trial-and-error in GitHub Actions
- Improved onboarding experience

### Trade-offs

- Some workflow steps require `env.ACT` guards
- Tool installation paths may differ locally
- Developers must have Docker properly configured

These trade-offs are considered acceptable given the productivity gains.

---

## Alternatives Considered

### 1. Rely exclusively on GitHub Actions

Rejected due to:

- Slow feedback loops
- High iteration cost for CI changes
- Poor debuggability

### 2. Custom shell scripts to mirror CI

Rejected due to:

- Duplication of CI logic
- Drift between local scripts and workflows
- Increased maintenance burden

---

## Related Documents

- `docs/devops/ci/act/ACT_OVERVIEW.md`
- `docs/devops/ci/act/ACT_TROUBLESHOOTING.md`
- `docs/devops/ci/act/ACT_COMMANDS.md`
- `docs/MAKEFILE.md`

---

## Decision Summary

We standardize on **`act` + Makefile wrappers** for local CI simulation.

This approach balances realism, developer experience, and maintainability while keeping GitHub
Actions as the source of truth.
