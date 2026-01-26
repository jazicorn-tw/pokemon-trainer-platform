# ✅ Conventional Commits Cheat Sheet (1 page)

Use this project’s commit format:

```text
<type>(optional scope): <description>
```

Examples:

- `feat(trades): add accept trade endpoint`
- `fix(db): handle null trainer id`
- `docs(onboarding): clarify doctor vs verify`
- `chore(ci): tighten release artifact guard`
- `refactor(service): extract trade validation`
- `test(api): add trade rule coverage`
- `build(gradle): pin spotless version`

---

## 🚀 Recommended workflow

Create commits interactively:

```bash
cz commit
```

This helps you pick the right type and keeps messages consistent.

---

## ✅ Types (what to use)

| Type        | When to use it                | Release signal  |
|-------------|-------------------------------|-----------------|
| `feat`      | New user-facing capability    | **minor**       |
| `fix`       | Bug fix                       | **patch**       |
| `docs`      | Docs only                     | none            |
| `test`      | Tests only                    | none            |
| `refactor`  | No behavior change            | none            |
| `perf`      | Performance improvement       | patch/minor*    |
| `build`     | Build tooling / dependencies  | none            |
| `ci`        | GitHub Actions / CI changes   | none            |
| `chore`     | Maintenance / housekeeping    | none            |
| `revert`    | Revert a commit               | depends         |

\* depends on analyzer rules; default is usually patch if it’s a fix-like change.

---

## 💥 Breaking changes (pre-1.0)

This project is currently `0.x`.

Use `!` for breaking changes:

```text
feat!: change API contract
```

Or add a footer (also counts as breaking):

```text
BREAKING CHANGE: describe what changed and why
```

> Note: breaking changes won’t automatically jump to `1.0.0` unless you decide to stabilize the API.

---

## 🧠 Scopes (optional but helpful)

Good scopes: `api`, `service`, `domain`, `db`, `security`, `ci`, `docs`, `build`

Example:

```text
fix(security): require auth for trade accept
```

---

## ✍️ Style rules

- Use **imperative** mood: “add”, “fix”, “update” (not “added”, “fixed”)
- Keep the subject **short** (≈ 50 chars is a good target)
- **No period** at the end of the subject line
- Explain “why” in the body if needed

Body example:

```text
feat(trades): add accept endpoint

Includes validation for ownership and availability.
Adds integration tests using Testcontainers.
```

---

## ⚠️ Releases are CI-owned (important)

Avoid local release commands like:

```bash
cz bump
cz changelog
```

Releases (versions, tags, `CHANGELOG.md`, GitHub Releases) are handled by **semantic-release in CI**.
PRs that modify release artifacts (like `CHANGELOG.md`) may be rejected by CI guards.

---

## 🔎 Quick self-check

Before pushing:

```bash
make quality
```

Before opening a PR:

```bash
make verify
```

---

## 🧩 If your commit gets rejected

- Run `cz commit` instead of `git commit`
- Fix the message to match the schema
- If formatting tools changed files (Spotless), re-stage and re-commit:

  ```bash
  git add -A
  git commit -m "your message"
  ```
