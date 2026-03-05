<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD060 -->

# 🚀 Releases (semantic-release)

> **TL;DR**
>
> - Releases are created **only from `main`**
> - Releases are **gated** (off by default)
> - Commit **type** controls versioning (`feat` / `fix` / `perf`)
> - `CHANGELOG.md` and GitHub Releases are generated automatically
> - Artifact publishing (Docker / Helm) is optional and separately gated
> - The `release` commit scope is **reserved for automation**

---

## ⚡ TL;DR — How to get a release

1. Merge into `main` with a **releasable commit type**

   ```text
   feat: add resource inventory endpoint
   ```

2. Ensure one of the release gates is enabled:

   ```text
   ENABLE_SEMANTIC_RELEASE=true
   ```

   or run the workflow manually with:

   ```text
   enable_release=true
   ```

3. semantic-release:
   - calculates the next version
   - creates `vX.Y.Z`
   - updates `CHANGELOG.md`
   - publishes a GitHub Release

No releasable commits → **no release** (this is expected).

---

## 🧠 Deep dive — Release system design

### What happens on release

When a change lands on **`main`** *and releases are enabled*, the workflow performs:

1. Evaluate **release gates**
2. Analyze Conventional Commits
3. Preview the next version (dry run)
4. Create a Git tag (`vX.Y.Z`)
5. Generate GitHub Release notes
6. Update `CHANGELOG.md`
7. Commit the changelog back to `main` as:

   ```text
   chore(release): X.Y.Z [skip ci]
   ```

> ⚠️ The `release` scope is **reserved for automation only**.  
> Humans must never author `*(release): ...` commits.

---

### 🌿 Branch flow

- Work happens on `dev`
- Integrate via PR into `staging`
- Promote via PR from `staging` → `main`
- **Releases are cut only from `main`**

---

## ✍️ Commit messages (this drives versioning)

semantic-release reacts only to **commit types**, not scopes.

### Releasable types

| Type | Result |
|---|---|
| `feat` | Minor release |
| `fix` | Patch release |
| `perf` | Patch release |
| `BREAKING CHANGE` | Major release |

### Non-releasing types

| Type | Result |
|---|---|
| `docs` | No release |
| `chore` | No release |
| `test` | No release |
| `ci` | No release |
| `refactor` | No release |
| `style` | No release |
| `build` | No release |

Unknown or missing types are grouped under **🧩 Other** in release notes.

---

### Intentional override for refactors

Refactors **do not release by default**.

To intentionally cut a version (e.g. for rollback safety):

```text
fix: internal refactor + stability
```

or

```text
perf: refactor for performance
```

---

## 📝 Release notes strategy

This repository intentionally produces **two views** of release notes:

### CHANGELOG.md

- Grouped by category
- Includes short commit hashes
- Optimized for maintainers

### GitHub Releases

- Grouped by category
- No commit hashes
- Optimized for consumers

Both are generated from the same commits using different writer options.

---

## 🚦 Release gating

Releases are **disabled by default**.

The release job runs only when **one** is true:

```text
ENABLE_SEMANTIC_RELEASE=true
```

or manual workflow input:

```text
enable_release=true
```

This prevents accidental releases from routine merges.

---

## 📦 Artifact publishing gates

Docker / Helm publishing requires **all** of:

1. A published version (`vX.Y.Z`)
2. Running in the canonical repository
3. The corresponding feature flag enabled

```text
PUBLISH_DOCKER_IMAGE=true
PUBLISH_HELM_CHART=true
```

Forks can run CI safely but **cannot publish artifacts**.

---

## 🧪 Dry runs

Dry runs calculate the next version **without side effects**.

### Local

```bash
make release-dry-run
```

Or directly:

```bash
npm ci
npx semantic-release --dry-run
```

### CI

Every release workflow includes a dry-run preview step for visibility.

---

## 🔐 Required GitHub configuration

### GitHub App

Releases authenticate using a **GitHub App**, not `GITHUB_TOKEN`.

Required secrets:

- `GH_APP_ID`
- `GH_APP_PRIVATE_KEY`

### Branch protection

Because the changelog commit is pushed to `main`, the GitHub App must be allowed
to **bypass the `main` ruleset**.

---

## 🆘 Troubleshooting

### Nothing was released

- No releasable commits
- Expected behavior — check the Release Summary

### Artifacts not published

- Non-canonical repo
- Feature flag disabled
- No release version

### Changelog commit failed

- GitHub App not allowed to bypass branch protection

---

## 🎯 Design principles

- Explicit intent over automation magic
- Versioning decoupled from delivery
- Fork-safe by default
- CI explains *why* something happened (or didn’t)

---

## 🧭 Why didn’t a release happen? (decision tree)

Follow this top-to-bottom — you’ll always land on the answer.

```text
Did the workflow run?
 ├─ No → Releases are gated (ENABLE_SEMANTIC_RELEASE / manual run)
 └─ Yes
     └─ Did semantic-release find releasable commits?
         ├─ No
         │   ├─ Only docs/chore/refactor/ci/test commits → Expected (no release)
         │   └─ Squash commit message not Conventional → Fix commit message
         └─ Yes
             └─ Was this the canonical repository?
                 ├─ No → Release may run, artifacts will not publish
                 └─ Yes
                     └─ Did artifact publishing run?
                         ├─ No → Feature flag disabled (PUBLISH_*)
                         └─ Yes → ✅ Everything worked
```

### Common quick fixes

- **No releasable commits**
  - Use `feat:` / `fix:` / `perf:` in the *squash merge* commit
- **Workflow didn’t run**
  - Set `ENABLE_SEMANTIC_RELEASE=true` or use manual input
- **Artifacts skipped**
  - Confirm canonical repo + feature flag enabled

---

## 🔗 Related release documentation

- **Release contract (policy + rationale)**  
  See `.release.contract.json` — documents *why* the release system behaves the way it does.

- **semantic-release configuration**  
  See `.releaserc.cjs` — executable source of truth.

- **CHANGELOG.md**  
  Maintainer-facing, hash-inclusive release history.

These three files are intentionally kept separate:

- config (`.releaserc.cjs`)
- policy (`.release.contract.json`)
- behavior & usage (`docs/devops/RELEASE.md`)
