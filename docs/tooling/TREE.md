<!-- markdownlint-disable-file MD036 -->

# 🌳 TREE — Repository Structure Inspection

This document describes the **`make tree`** command provided by the project’s Make tooling.

The goal of `make tree` is to give contributors a **fast mental model of the repository**
without overwhelming output or requiring deep knowledge of the codebase.

This is **inspection tooling**, not execution tooling.

---

## Why this exists

Large repositories are hard to navigate quickly.

`make tree` exists to:

- Provide **read-only visibility** into repo structure
- Encourage **shallow inspection by default**
- Reduce context-switching to IDE file explorers
- Make onboarding and review faster

This command is intentionally:

- ✅ safe
- ✅ local-only
- ❌ non-mutating
- ❌ non-verifying

---

## Basic usage

```bash
make tree <path>
```

If no path is provided, the command defaults to the **repository root**.

```bash
make tree
```

---

## Example

```bash
make tree docs
```

This will show **only the immediate contents** of the `docs/` directory:

```bash
docs
├── adr
├── onboarding
├── services
└── TREE.md
```

By default, the command shows **one level deep** only.

This keeps output readable and focused.

---

## Controlling depth

If you want to explore deeper, you may explicitly override the depth:

```bash
make tree docs TREE_DEPTH=4
```

Notes:

- The default depth is **1**
- Deeper inspection is always **opt-in**
- This prevents accidental “wall of files” output

---

## Ignoring paths

The command ignores common noise by default:

- `.git`
- `node_modules`
- `build`, `target`, `dist`
- IDE metadata

You can override or extend this behavior:

```bash
make tree src TREE_IGNORE=".git|node_modules|coverage"
```

This uses the `tree -I` pattern syntax.

---

## Error handling

If a path does not exist, the command fails fast:

```bash
make tree does-not-exist
```

Output:

```bash
❌ Path not found: does-not-exist
```

No partial output is printed.

---

## How it works (implementation notes)

Internally, `make tree`:

- Uses `MAKECMDGOALS` to treat extra arguments as a path
- Defaults the path to `.` when none is provided
- Defaults depth to `1` unless `TREE_DEPTH` is explicitly set
- Requires the `tree` binary to be installed locally

This behavior is documented inline in the Makefile comments.

---

## Where this lives

The implementation is defined in:

```bash
make/81-tree.mk
```

It is part of the **80-series (Simulation / Inspection)** tooling and intentionally kept
separate from verification, runtime, and delivery logic.

---

## Non-goals

`make tree` is **not** intended to:

- Replace IDE navigation
- Validate repo structure
- Enforce conventions
- Run in CI
- Be used by automation

If you need verification or enforcement, that belongs in **60-verification** tooling.

---

## Related documentation

- `make/81-tree.mk` — implementation
- Onboarding docs — where `make tree` is commonly referenced
- ADRs — for architectural intent around developer tooling

---

## Summary

`make tree` is a small tool with a very specific job:

> **Help humans understand the shape of the repository, quickly and safely.**

Nothing more. Nothing less.
