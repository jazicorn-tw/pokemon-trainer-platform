# Executable Bits: What’s Actually Going On

This document clarifies a common point of confusion when working with scripts, Git, and local tooling in this repository.

If you’ve ever wondered:

> “Why does this script run, but the checker still complains?”

— this document answers that question.

---

## Two different kinds of “executable”

There are **two separate layers** involved when we talk about executable scripts.

They solve **different problems**.

---

## 1️⃣ Filesystem executable bit (your OS)

This is the **operating system permission**.

Example:

```bash
chmod +x scripts/bootstrap-macos.sh
./scripts/bootstrap-macos.sh
```

If this bit is set:

- The script **can run locally**
- The OS allows execution
- Errors like `permission denied` go away

This is a **local concern only**.

Bootstrap scripts exist primarily to repair this layer.

---

## 2️⃣ Git executable bit (the repository index)

Git separately tracks whether a file *should be executable* when checked out.

Git file modes:

| Mode    | Meaning |
|--------|--------|
| `100644` | Not executable |
| `100755` | Executable |

You can inspect this with:

```bash
git ls-files --stage scripts/bootstrap-macos.sh
```

If Git tracks a script as `100644`:

- Fresh clones will **not** have the script executable
- ZIP downloads will lose permissions
- Every new contributor must run `chmod` manually

This is a **repository guarantee**, not a local fix.

The executable-bit checker enforces this layer.

---

## Why bootstrap fixing permissions is not enough

Bootstrap scripts do things like:

```bash
chmod +x scripts/*.sh
```

This:
- fixes **your local machine**
- does **not** update Git’s record
- does **not** help the next clone

That’s intentional.

Bootstrap is designed to be:

- best-effort
- local-only
- side-effect safe

It must **not** rewrite repository history.

---

## Why the checker still warns

`scripts/check-executable-bits.sh` checks **Git’s index**, not your filesystem.

It is asking:

> “If someone clones this repo fresh, will this script be executable immediately?”

If the answer is “no”, it warns — even if the script runs locally.

This is correct behavior.

---

## How local-settings.json fits in

With this configuration:

```json
{
  "checks": {
    "executableBits": {
      "strict": 2,
      "autoStage": true
    }
  }
}
```

The checker will:

1. Detect non-executable tracked scripts
2. Run `chmod +x` locally
3. Automatically `git add` the file-mode change
4. Ask you to commit

This automates the **repair**, but it still requires an **explicit commit**.

---

## Why a commit is required (once)

A commit is required to:

- Record that the file is *meant* to be executable
- Make fresh clones work immediately
- Eliminate repeat warnings permanently

This is a **one-time normalization step** for each script.

After the commit:
- Bootstrap won’t need to repair it again
- The checker stays quiet
- New contributors don’t hit permission issues

---

## Mental model (the important part)

Think of it like this:

| Responsibility | Tool |
|---------------|------|
| Fix my machine right now | Bootstrap scripts |
| Define repo guarantees | Git commit |
| Enforce correctness | `check-executable-bits.sh` |
| Decide what fails | CI |

Each layer does **one job**.

---

## TL;DR

- A script can **run locally** and still be **wrong in Git**
- Bootstrap fixes your machine, not the repo
- The checker enforces repo guarantees
- `local-settings.json` automates the fix, not the commit
- You must commit executable bits **once**

After that, this entire class of issues disappears.

---

## When to use what

- Seeing `permission denied` locally? → Run `make bootstrap`
- Seeing executable-bit warnings? → Run `make exec-bits` and commit
- CI failing on permissions? → Something is wrong with Git state

---

## Summary

Nothing is broken.

You’re seeing the system work exactly as designed:

- explicit
- safe
- predictable
- future-proof

Once executable intent is committed, you won’t have to think about this again.
