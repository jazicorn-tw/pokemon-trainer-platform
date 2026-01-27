<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# 🚑 Undo an accidental semantic-release

This doc captures the **fast, brute-force** recovery flow we used when a commit
accidentally triggered `semantic-release` (e.g. a mistaken `fix: …`)
while we were still in an early phase of the project.

This is written for a **solo repo** where we prioritize getting back to a clean
state quickly.

---

## ✅ What this fixes

When an accidental release happened, you may see:

- A commit like: `fix: 1.0.0 [skip ci]` (often authored by a bot)
- A Git tag like: `v1.0.0` (or `1.0.0`)
- A GitHub Release entry for that tag
- A changelog/version bump commit (depending on plugins)

We want to:

1. **Remove/rename the commit message that triggered release** (so it won't retrigger)
2. **Remove the release commit** from history (if semantic-release pushed one)
3. **Delete the release tag + GitHub Release** so the release is gone

---

## 🧰 Prereqs

- You are on the correct branch (usually `main`)
- Working tree is clean

```bash
git status
```

If you have uncommitted work, commit or stash it first.

---

## 1) Reword the accidental trigger commit (no revert trail)

If a commit message is what caused the release logic to fire (e.g. `fix:` / `feat:` ), **rewrite it**.

### A) Locate the commit SHA

```bash
git log --oneline --decorate -n 30
```

Pick the SHA for the offending commit.

### B) Interactive rebase and reword

Rebase starting from the commit *before* the one you want to edit:

```bash
git rebase -i <BASE_SHA>
```

Change the line for the commit from:

```text
pick <SHA> fix(doctor): ...
```

to:

```text
reword <SHA> fix(doctor): ...
```

When Git opens the editor, change the message to something non-releasing, e.g.:

```text
chore(no-release): stop docker.sock warning under act
```

Finish the rebase.

---

## 2) Remove the bot release commit from history (drop)

If semantic-release created a bot commit like:

```text
fix: 1.0.0 [skip ci]
```

### A) Find the release commit SHA

```bash
git log --oneline --decorate -n 50
```

Copy the SHA for the `fix: …` commit.

### B) Drop it with an interactive rebase

Rebase starting just before it:

```bash
git rebase -i --rebase-merges <RELEASE_SHA>^
```

In the editor, change:

```text
pick <RELEASE_SHA> fix: 1.0.0 [skip ci]
```

to:

```text
drop <RELEASE_SHA> fix: 1.0.0 [skip ci]
```

Save/exit and let the rebase complete.

---

## 3) Push the rewritten history

This is a history rewrite, so you must force push.

```bash
git push --force-with-lease
```

Why `--force-with-lease` even on a solo repo?
It prevents overwriting remote updates you didn't fetch yet (e.g. automation).

---

## 4) Delete the release tag (local + remote)

### A) List tags

```bash
git fetch --tags
git tag --sort=-creatordate | head -n 20
```

Identify the release tag (commonly `v1.0.0` or `1.0.0`).

### B) Delete it

Example for `v1.0.0`:

```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

---

## 5) Delete the GitHub Release entry

From the GitHub UI:

- Repo → **Releases**
- Open the accidental release
- **Delete** it

Or using GitHub CLI:

```bash
gh release delete v1.0.0 -y
```

---

## 6) Verify cleanup

```bash
git log --oneline -n 50 | grep -E "chore\(release\)|\b1\.0\.0\b" || echo "✅ no release commit in recent history"
git ls-remote --tags origin | grep -E "1\.0\.0" || echo "✅ no 1.0.0 tag on origin"
```

---

## 🧯 Optional: prevent this from happening again

The repo includes a release workflow gate:

- Repo Variable: `ENABLE_SEMANTIC_RELEASE`
- Default: `false`
- Set to `true` only when we actually want push-based releases from `main`.

Manual runs can override the gate via workflow dispatch input.

See: `.github/workflows/release.yml`
