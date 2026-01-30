<!-- markdownlint-disable MD036 -->

# Where Does This Make Target Go?

Use this decision tree when adding a new target or deciding which `XX-*.mk` file should own it.

The goal is to place targets by **responsibility**, not by the tool used today.

---

## Quick decision tree

### 1) Does it *change* machine state?

Examples of **changing state**

- starting/stopping services
- creating/removing containers
- writing files (outside build outputs)
- installing tools
- switching Docker contexts

✅ Yes → go to **70s Runtime Orchestration**  
❌ No → go to step 2

---

### 2) Is it primarily about code correctness?

Examples

- format, lint, tests
- static analysis (SpotBugs/PMD/etc.)
- coverage reports
- “quality gates”

✅ Yes → go to **60s Build & Verification**  
❌ No → go to step 3

---

### 3) Is it about packaging, release, or deploy?

Examples

- build/push images
- Helm packaging/linting
- releases/versioning
- deployment commands

✅ Yes → go to **90s Delivery**  
❌ No → go to step 4

---

### 4) Is it about simulating CI/workflows locally?

Examples

- `act`
- “run the workflow the way GitHub Actions would”
- orchestration of multiple jobs to mirror CI

✅ Yes → go to **80s Simulation & Automation**  
❌ No → go to step 5

---

### 5) Is it a prerequisite check (no side effects)?

Examples

- “is tool installed?”
- “does file exist?”
- “are permissions safe?”
- “is Java version acceptable?”

✅ Yes → go to **40s Preconditions**  
❌ No → go to step 6

---

### 6) Is it configuration/selection logic (no side effects)?

Examples

- feature flags
- derived variables
- env selection (local vs CI)
- defaults that change behavior elsewhere

✅ Yes → go to **20s Configuration**  
❌ No → go to step 7

---

### 7) Is it presentation or CLI interface?

**Presentation (10s)**

- colors, log formatting, group/step output helpers

**Interface (30s)**

- help output, categories, role mapping, discoverability

✅ Yes → go to **10s** or **30s**  
❌ No → go to step 8

---

### 8) Is it a shared helper used by many targets?

Examples

- generic macros/functions
- wrappers around common commands
- JSON emitters

✅ Yes → go to **50s Library**  
❌ Otherwise → default to the *closest* decade and document why.

---

## “If it uses Docker, is it automatically 70s?”

No. Ask: **is it orchestrating runtime?**

- `docker compose up -d` → **70s Runtime**
- `act` (uses Docker) → **80s Simulation**
- `docker build` for release → **90s Delivery**
- `docker` presence checks → **40s Preconditions**

---

## Common placements

- `start/stop/status` → **70s Runtime**
- `doctor` checks → **40s Preconditions** (even though it may *query* runtime)
- `verify/quality` → **60s Build & Verification**
- `run-ci` / `act-*` → **80s Simulation**
- image publish + helm packaging → **90s Delivery**
