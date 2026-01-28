# Colima Resource Check Script

## Purpose

This script ensures that **Colima** (Docker runtime on macOS) is running with enough
resources to reliably support this project’s development workflow, including:

- Gradle builds
- Spring Boot test contexts
- Testcontainers (PostgreSQL)
- Flyway migrations

It is designed to be **safe for local developer use** and **non-blocking** by default.

---

## Requirements Enforced

| Resource | Required | Notes |
| -------- | ---------- | ------- |
| Memory | 6 GiB | Docker may report slightly less due to VM overhead |
| CPUs | 4 | Required for parallel Gradle + containers |

A small tolerance is applied to memory checks to account for virtualization overhead.

---

## How It Works

1. **Checks that Colima and Docker are installed**
2. **Ensures Colima is running**
   - If stopped, starts it with the required CPU and memory
3. **Reads actual resources from Docker**
   - Uses `docker info` (authoritative for Testcontainers)
4. **Validates resources**
   - Memory is compared using decimals with a tolerance
   - CPUs must meet or exceed the requirement
5. **Auto-restarts Colima if needed**
   - Stops Colima
   - Waits until it is fully stopped
   - Restarts with the required configuration
6. **Re-checks once**
   - If still below requirements, prints a warning (no restart loop)

---

## Why Docker Info Is Used

Some versions of Colima do **not** report CPU or memory in:

```bash
colima status
```

However, Docker always reports the actual usable resources:

```bash
docker info | egrep 'CPUs|Total Memory'
```

Since Docker/Testcontainers rely on these values, they are the authoritative source.

---

## Expected Output Examples

### Resources already sufficient

```text
✅ Docker resources OK: 5.773GiB RAM, 4 CPUs
```

### Auto-fix triggered

```text
⚠️  Docker reports insufficient resources:
   Memory: 1.9GiB (required: 6GiB)
   CPUs:   2 (required: 4)

🔄 Restarting Colima with correct settings...
✅ Restarted. Total Memory: 5.773GiB | CPUs: 4
```

---

## Intended Usage

This script is invoked automatically by:

```bash
make hooks
make bootstrap
```

It should **not** be run inside Git hooks directly.

---

## Design Principles

- ✅ Safe for local machines
- ✅ No infinite restart loops
- ✅ Warns instead of failing builds
- ✅ Aligns with ADR-000 quality gates
- ❌ Does not modify CI behavior
- ❌ Does not assume Docker Desktop

---

## Manual Verification

If you ever need to verify manually:

```bash
colima status --profile default
docker info | egrep 'CPUs|Total Memory'
```

---

## Troubleshooting

If Docker still reports low resources after restart:

1. Check active Docker context:

   ```bash
   docker context show
   ```

2. Ensure Colima is the active runtime
3. Restart manually:

   ```bash
   colima stop
   colima start --memory 6 --cpu 4
   ```

---

## Location

```text
scripts/check-colima.sh
```

---

## Summary

This script exists to **prevent flaky tests and wasted debugging time** by enforcing
a known-good local Docker environment before development or testing begins.
