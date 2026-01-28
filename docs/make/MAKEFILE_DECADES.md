<!-- markdownlint-disable MD036 -->

# Makefile Decades & Layering Guide

This document defines the **decade-based structure** used by this repository’s Makefile system.

The goal is **future-proof organization**: files are grouped by *conceptual responsibility*, not by the tools or technologies that happen to exist today.

If a target feels ambiguous, this document is the source of truth.

---

## 🧭 Design Principles

- **Layers over tools** — decades describe *responsibilities*, not implementations
- **Stable meaning** — adding Redis, Vault, Localstack, etc. should not force renames
- **Clear intent** — each target should have one obvious “home”
- **Low churn** — new decades are a last resort

---

## Decade Definitions

### **00–09 — Kernel**

**Purpose:** Make the Makefile itself possible.

**Includes**

- Shell flags (`.ONESHELL`, `pipefail`)
- Global variables and constants
- OS / platform detection
- Include wiring and ordering
- Hard guardrails that everything depends on

**Rule:**  
If this decade breaks, *nothing* else can run.

---

### **10–19 — Presentation**

**Purpose:** Standardize how Make communicates with humans and CI logs.

**Includes**

- Colors, separators, formatting helpers
- `step`, `group`, logging macros
- Emoji conventions and output tone

**Rule:**  
No business logic. No side effects. UX only.

---

### **20–29 — Configuration**

**Purpose:** Decide *what* should happen, not *how*.

**Includes**

- Feature flags and toggles
- Derived variables
- Environment selection logic
- CI vs local behavior switches
- Repo-variable gating

**Rule:**  
Must be safe to evaluate (`make -pn`) with zero side effects.

---

### **30–39 — Interface**

**Purpose:** Define the **public API** of the Makefile.

**Includes**

- Help system
- Categories and roles
- Target discoverability
- Documentation pointers
- “What targets exist and why”

**Rule:**  
This is a CLI contract. Keep it stable and intentional.

---

### **40–49 — Preconditions**

**Purpose:** Verify the workstation is *capable*.

**Includes**

- Tool existence checks
- Required file presence
- Permissions validation
- Version sanity checks

**Rule:**  
Checks only. **No starting or stopping services.**

---

### **50–59 — Library**

**Purpose:** Shared plumbing and reusable helpers.

**Includes**

- Generic macros and functions
- Wrappers around `docker`, `gradle`, `git`, etc.
- JSON emitters
- Small internal utilities

**Rule:**  
Prefer no user-facing targets unless they are purely internal helpers.

---

### **60–69 — Build & Verification**

**Purpose:** Prove the artifact is correct.

**Includes**

- Formatting
- Linting
- Tests
- Static analysis
- Coverage
- Quality gates (`verify`, `check`, etc.)

**Rule:**  
Deterministic and repeatable.  
Should not mutate machine state.

---

### **70–79 — Runtime Orchestration**

**Purpose:** Make the **local development runtime exist**.

**Includes**

- `make start / stop / status`
- Container runtimes (Docker, Colima)
- Compose stacks
- Local emulators
- Background services or agents

**Rule:**  
This decade **mutates machine state by design**.  
Targets must be idempotent and safe to re-run.

---

### **80–89 — Simulation & Automation**

**Purpose:** Run project workflows the way CI/CD would.

**Includes**

- `act`
- Local pipeline simulation
- Scenario runners
- CI-like orchestration

**Rule:**  
Assumes Runtime is ready (or explicitly calls it).

---

### **90–99 — Delivery**

**Purpose:** Package, release, and ship.

**Includes**

- Image builds and publishing
- Helm
- Releases and versioning
- Deployment automation

**Rule:**  
High-consequence operations.  
Require explicit intent and strong guards.

---

## Placement Checklist

When adding a new target, ask:

1. Does this **check** or **mutate** state?
2. Is it **local-runtime**, **build correctness**, or **shipping**?
3. Would this still belong here if Docker disappeared tomorrow?
4. Is this user-facing (Interface) or internal (Library)?

If unsure:

- Prefer **broader responsibility**
- Avoid creating new decades
- Document the intent

---

## Mental Model Summary

- **00–59** → framework (Makefile itself)
- **60s** → correctness
- **70s** → runtime
- **80s** → simulation
- **90s** → shipping

This structure is intentionally conservative.  
It is designed to scale without churn.
