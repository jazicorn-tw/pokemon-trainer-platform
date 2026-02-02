<!-- markdownlint-disable-file MD036 -->

# 🧭 Planning System

This repository uses a simple, production-style planning workflow:

- `IDEAS.md` = **low-commitment** parking lot for ideas
- `TODO.md` = **intentional work** we actually plan to implement
- `PROMOTION_CHECKLIST.md` = gate to prevent scope creep and vague work
- `CHANGELOG.md` (or release notes) = **what shipped**

The goal is to keep execution **high-signal** while still encouraging exploration.

---

## 📂 Files and responsibilities

### `IDEAS.md`

Capture ideas cheaply and early. No promises.

Good for:

- future features
- experiments
- architecture options
- AI/data concepts
- “what if” thoughts

Not good for:

- commitments
- tasks you intend to start soon

### `TODO.md`

This is the commitment layer.

Every TODO entry should be:

- scoped (in/out)
- measurable (acceptance criteria)
- linked (issues/ADRs where relevant)

### `PROMOTION_CHECKLIST.md`

Before moving an idea → TODO:

- confirm value
- define scope
- decide if an ADR is needed
- write acceptance criteria

---

## 🔁 Promotion flow

1) Start in `IDEAS.md`
2) When approved, run the checklist
3) Copy into `TODO.md` with:
   - Category
   - Why
   - Scope
   - Acceptance criteria
   - ADR link (or ADR TBD)

Optional:

- create a GitHub Issue and link it

---

## 🧼 Lint rules (fast guardrails)

Run locally:

```bash
make planning-lint
```

What it checks:

- files exist and aren’t empty
- TODO doesn’t contain speculative language (e.g., “maybe”, “someday”)
- key sections are present
- checklist includes checkbox items

This is intentionally lightweight: it’s there to catch drift, not police writing.

---

## 🗓️ Weekly ritual (10 minutes)

Run:

```bash
make planning-weekly
```

Suggested routine:

- Promote at most **0–2** ideas
- Reject or ice at least **1** idea (keeps IDEAS honest)
- Split any TODO that’s too big to explain “done”

---

## 🔗 Optional: GitHub Issues linkage

You can keep everything in Markdown, but if you want Issue tracking:

**When to create an Issue**

- cross-cutting work
- multi-day tasks
- anything that benefits from discussion/review
- anything you want to reference in PRs

**How to link**

- In `TODO.md`, add:
  - `Issue: #123`
  - or `Issue: <url>`
- In PR descriptions, reference:
  - `Closes #123` (auto-closes on merge)

**Recommended convention**

- keep `TODO.md` as the human-friendly plan
- use Issues when you want a reviewable thread and history

---

## 🧱 ADR guidance

Create an ADR when you:

- change data models or persistence strategy
- introduce new integration boundaries
- change security posture
- introduce new infra (queues, caches, vector DBs)
- make a decision you’ll want to defend later

Link ADRs from both `IDEAS.md` and `TODO.md`.
