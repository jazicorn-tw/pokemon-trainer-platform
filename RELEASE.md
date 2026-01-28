<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD060 -->

# 🚀 Releases (semantic-release)

This repository uses **semantic-release** to automate versioning, changelogs, Git tags, GitHub Releases,
and **optionally** downstream artifact publishing (Docker / Helm), all behind explicit CI gates.

---

## ✅ What happens on release

When a change lands on **`main`** *and releases are enabled*, the release workflow performs:

### Release phase

1. Evaluate **release gates** (repo variables or manual override)
2. Analyze commit messages (Conventional Commits) to determine the next version
3. **Preview** the next version (dry-run, no side effects)
4. Create a Git tag like `vX.Y.Z`
5. Generate GitHub Release notes
6. Update `CHANGELOG.md`
7. Commit the changelog back to `main` as:

   ```text
   chore(release): X.Y.Z [skip ci]
   ```

### Delivery phase (optional, gated)

After a version is successfully published:

- 🐳 **Docker image publishing** (if enabled)
- ⎈ **Helm chart publishing** (if enabled)

> Delivery is **decoupled** from versioning. A release may occur without publishing any artifacts.

---

## 🚦 Release gating (important)

Releases **do not run by default**.

The release job executes only when **one of these is true**:

- Repository variable:

  ```text
  ENABLE_SEMANTIC_RELEASE=true
  ```

- Manual workflow run with input:

  ```text
  enable_release=true
  ```

This prevents accidental releases from routine merges.

---

## 📦 Artifact publishing gates

Artifact publishing is guarded even more strictly.

Docker / Helm publishing runs **only if all conditions are met**:

1. A release version was actually published (`vX.Y.Z`)
2. The workflow is running in the **canonical repository**
3. The corresponding feature flag is enabled

### Canonical repository guard

```yaml
github.repository == vars.CANONICAL_REPOSITORY
```

This ensures:

- forks can run CI safely
- **only the official repo** can publish artifacts

### Feature flags

```text
PUBLISH_DOCKER_IMAGE=true   # enable Docker publishing
PUBLISH_HELM_CHART=true     # enable Helm publishing
```

If any gate fails, publishing is **skipped with a warning summary** (not silently ignored).

---

## 🧾 CI summaries (observability)

The workflow emits **human-readable summaries** in GitHub Actions:

### Release job summary

- Trigger (push / manual)
- Branch and repository
- Release gates and feature flags
- Dry-run preview result
- Final outcome (published / skipped)

### Publish job summary

- Canonical repo check
- Published version
- Docker / Helm enablement
- Gate pass / fail indicators

These appear in the **Summary tab** of each job.

---

## 🌿 Branch flow

- Work happens on `dev`
- Integrate via PR into `staging`
- Promote via PR from `staging` → `main`
- **Releases are created only from `main`**

---

## ✍️ Commit message requirements (this is what drives releases)

semantic-release reacts only to **Conventional Commits** on `main`
(or the squash commit message that lands on `main`).

Use these patterns for the **squash merge commit message**:

### Minor release (new features)

```text
feat(release): <summary>
```

### Patch release (bug fixes)

```text
fix(release): <summary>
```

### Major release (breaking changes)

```text
feat(release)!: <summary>

BREAKING CHANGE: <migration notes>
```

### No release (docs / chores only)

```text
docs(release): <summary>
```

or

```text
chore(release): <summary>
```

### Releasable commit types

| Type | Effect |
|---|---|
| `feat` | Minor release |
| `fix` | Patch release |
| `perf` | Patch release |
| `breaking change` | Major release |

### Non-releasing commit types

| Type | Effect |
|---|---|
| `docs` | No release |
| `chore` | No release |
| `test` | No release |
| `ci` | No release |
| `refactor` | No release |

### ⚠️ Intentional override for refactors (important)

Refactor-only changes **do not cut releases by default** to reduce version noise.

If you want to **intentionally cut a patch release** for a refactor batch
(e.g. to create a rollback point or publish a new artifact), use an explicit
releasable type in the **squash merge commit message**, for example:

```text
fix(release): internal refactor + stability
```

or

```text
perf(release): refactor for performance
```

This keeps releases **explicit and intentional**, even when triggered manually.

---

## 🧪 Dry run (local or CI)

Dry runs calculate the next version **without publishing anything**.

### Local

```bash
npm ci
npx semantic-release --dry-run
```

### CI

The release workflow always performs a **dry-run preview step** before publishing.
This is for visibility only and has no side effects.

---

## 🔐 Required GitHub settings

### GitHub App (required)

Releases authenticate using a **GitHub App**, not the default `GITHUB_TOKEN`.

Add these **repository secrets**:

- `GH_APP_ID`
- `GH_APP_PRIVATE_KEY` (full PEM)

The workflow mints a short-lived installation token and passes it to semantic-release.

### Branch protection (main)

Because `@semantic-release/git` pushes a changelog commit to `main`,
the **GitHub App** must be allowed in the **Bypass list** for the `main` ruleset.

If not configured, releases will fail with protected-branch errors.

---

## 🆘 Troubleshooting

### Release workflow ran but nothing was published

- No releasable commits (`docs:` / `chore:` only)
- This is expected behavior
- See the **Release Summary** panel for confirmation

### Artifact publishing skipped

- Non-canonical repository (fork)
- Feature flag disabled
- No release version published

All cases are surfaced in the **Publish job summary**.

### Protected branch update failed

- GitHub App not allowed to bypass `main` ruleset
- Add the App to the bypass list

---

## 🎯 Design principles

- Explicit intent over automation magic
- Versioning decoupled from delivery
- Fork-safe by default
- CI explains *why* something happened (or didn’t)
