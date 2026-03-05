<!-- markdownlint-disable-file MD036 -->

# 🚨 Common First-Day Failures

This document lists **frequent issues new contributors hit on day one**, why they happen, and how to fix them quickly.

The goal is fast unblocking — not blame.

---

## ❌ Docker / Testcontainers Not Running

**Symptom**

* Tests hang or fail immediately
* Errors mentioning `Mapped port can only be obtained after the container is started`
* PostgreSQL connection failures during tests

**Cause**

* Docker (or Colima) is not running
* Testcontainers cannot start PostgreSQL

**Diagnose first**

```bash
docker context list   # shows which context is active
docker info           # confirms the daemon is reachable
```

If the wrong context is active, switch it:

```bash
docker context use colima     # macOS + Colima
docker context use default    # Docker Desktop or Linux
```

**Fix**

Run the repo’s environment sanity check first:

```bash
make doctor
```

If you’re on macOS with Colima:

```bash
colima start --cpu 6 --memory 8   # ensure sufficient resources
```

Quick verification:

```bash
docker ps
```

---

## ❌ Pre-commit Hook Fails Immediately

**Symptom**

* `cz commit` (or `git commit`) fails before opening the editor
* Messages mentioning Spotless, PMD, Checkstyle, or tests

**Cause**

* This repo enforces **local quality gates** by design

**Fix**

* Fix the first reported error — later errors are often cascading
* Re-run the commit

📄 Per-tool error messages and exact fixes:
[`QUALITY_GATE_EXPLAINED.md`](../faq/QUALITY_GATE_EXPLAINED.md)

📄 Hook behaviour details: `docs/commit/PRECOMMIT.md`

**One-time bypass (not recommended):**

```bash
SKIP_QUALITY=1 cz commit
# or: SKIP_QUALITY=1 git commit -m "message"
```

---

## ❌ Spotless Reformats Files and Aborts Commit

**Symptom**

* Commit stops after formatting
* Message says files were modified

**Cause**

* Spotless auto-formats code and requires re-staging

**Fix**

```bash
git status
git add .
cz commit
```

(Using `git commit` is fine too — `cz commit` is just the preferred workflow.)

---

## ❌ Tests Expect PostgreSQL (Not H2)

**Symptom**

* Assumptions about in-memory databases
* Confusion about why PostgreSQL is required locally

**Cause**

* This project enforces **production parity** (PostgreSQL everywhere)

**Fix**

* Ensure Docker/Colima is running (`make doctor` will tell you)
* Do not attempt to switch tests to H2

See:

* `docs/adr/ADR-001-database-postgresql.md`
* `docs/adr/ADR-002-testcontainers.md`

---

## ❌ CI Passes but Local Fails (or Vice Versa)

**Symptom**

* Works on GitHub Actions but not locally
* Or works locally but fails CI

**Cause**

* Local environment drift
* Docker not running / not reachable
* Skipped hooks locally

**Fix**

```bash
make doctor
make verify
```

If you’re still stuck, do the full first-time setup again:

```bash
make bootstrap
```

Local and CI use the **same commands** by contract.

---

## ❌ Tracked Scripts Missing Executable Bit

**Symptom**

* Errors like:

  * `Permission denied: ./scripts/...`
  * `check-executable-bits: Found tracked files missing executable bit`

**Cause**

* The executable bit is tracked by Git.
* If it’s wrong locally, checks will complain (and CI may too).

**Fix**

Use the repo’s exec-bit fixer/checker (preferred), then commit the change:

```bash
make exec-bits
git status
git commit -m "chore(dev): fix executable bits for scripts"
```

(If your workflow auto-stages, the `git add` step may not be needed.)

---

## ✅ If You're Still Stuck

1. Re-run:

   ```bash
   make doctor
   ```

2. If needed:

   ```bash
   make bootstrap
   ```

3. Check logs carefully (first error matters most)

4. Ask for help — include:

   * Full error output
   * OS
   * Docker/Colima status (`colima status` or Docker Desktop state)

---

> **Design note:** These failures are intentional guardrails. If day-one setup feels strict,
> it’s because production is stricter.
