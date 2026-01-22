<!-- markdownlint-disable-file MD036 -->

# 🚀 Releases (semantic-release)

This repository uses **semantic-release** to automate versioning, changelogs, Git tags, and GitHub Releases.

## ✅ What happens on release

When a change lands on **`main`**, the release workflow will:

1. Analyze commit messages (Conventional Commits) to determine the next version
2. Create a Git tag like `vX.Y.Z`
3. Generate GitHub Release notes
4. Build the Spring Boot **bootJar** **as `X.Y.Z`** (not `-SNAPSHOT`)
5. Upload `build/libs/*.jar` to the GitHub Release
6. Update `CHANGELOG.md`
7. Commit the changelog back to `main` as:
   - `chore(release): X.Y.Z [skip ci]`

> **Note:** The release build passes `-PreleaseVersion=${nextRelease.version}` so the produced JAR filename/version matches the Git tag.

## 🌿 Branch flow

- Work happens on `dev`
- Integrate via PR into `staging`
- Promote via PR from `staging` → `main`
- **Releases are created only from `main`**

## ✍️ Commit message requirements (this is what drives releases)

semantic-release only reacts to **Conventional Commits** on `main` (or the squashed commit message that lands on `main`).

Use these patterns for the **squash merge commit message** on the PR into `main`:

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

### No release (docs/chores only)

```text
docs(release): <summary>
```

or

```text
chore(release): <summary>
```

## 🧰 One-time setup (required)

Install dependencies **before running anything else**:

```bash
npm install --save-dev \
  semantic-release \
  @semantic-release/commit-analyzer \
  @semantic-release/release-notes-generator \
  @semantic-release/changelog \
  @semantic-release/exec \
  @semantic-release/git \
  @semantic-release/github
```

Add script to `package.json`:

```json
{
  "scripts": {
    "release": "semantic-release"
  }
}
```

At this point, semantic-release is installed and usable.

## 🧪 Dry run (optional, after setup)

A dry run verifies your config is detected and the version calculation works **without** pushing tags or commits.

From repo root:

```bash
npm ci
npx semantic-release --dry-run
```

- This **does not** create tags or releases.
- It is only for confidence and debugging.
- Real releases happen **only in CI on `main`**.

If you’re testing from a non-`main` branch, semantic-release may say it will not publish.
That’s expected — you’re checking configuration + parsing.

## 🧱 Gradle version behavior (SNAPSHOT locally, real versions on release)

Local development stays on SNAPSHOT by default, but release builds can override the version.

In `build.gradle`, set:

```groovy
// Prefer an explicit release version when provided by CI (semantic-release).
// Local/dev remains SNAPSHOT by default.
version = (findProperty('releaseVersion') ?: '0.0.1-SNAPSHOT')
```

The release workflow (via semantic-release `prepare`) runs:

```bash
./gradlew --no-daemon -PreleaseVersion=<next version> clean bootJar
```

## 🔐 Required GitHub settings

### GitHub App (required for releases)

This repo authenticates releases using a **GitHub App** (not the default `GITHUB_TOKEN`).

1) Install the GitHub App on this repository (repo-only install is ideal).

2) Add these **Repository secrets**:

   - `GH_APP_ID` — the GitHub App ID
   - `GH_APP_PRIVATE_KEY` — the full PEM (including `BEGIN/END` lines)

3) The release workflow mints a short-lived installation token and passes it to semantic-release as `GH_TOKEN`.

### Branch rules: main must allow release automation

Because `@semantic-release/git` pushes a changelog commit to `main`, your `main` ruleset must allow
the **GitHub App** (release actor) in the **Bypass list**.

If bypass is not configured, releases will fail with a “protected branch update failed” style error.

> If you switch back to `GITHUB_TOKEN`, add **GitHub Actions** to the bypass list instead.

## 🆘 Troubleshooting

### Release ran but no version was published

- The commit that landed on `main` was not a Conventional Commit (`feat:`, `fix:`, etc.)
- Fix: use a Conventional Commit **squash message** for the `staging → main` PR

### Protected branch update failed

- `main` ruleset blocks direct pushes and the release actor isn’t in the bypass list
- Fix: add the **GitHub App** (or GitHub Actions, if using `GITHUB_TOKEN`) to **Bypass list** for the `main` ruleset

### No JAR attached to GitHub Release

- `bootJar` did not run or output path differs
- Fix: confirm the release workflow builds `bootJar` and that artifacts are in `build/libs/`

### JAR still ends in `-SNAPSHOT`

- `releaseVersion` was not passed to Gradle
- Fix: confirm your semantic-release config runs Gradle with `-PreleaseVersion=${nextRelease.version}`
