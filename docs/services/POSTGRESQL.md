<!-- markdownlint-disable-file MD036 MD041 -->
<!-- markdownlint-disable-file MD036 MD060 -->

# 🐘 PostgreSQL (Service)

This project **standardizes on PostgreSQL everywhere** — local development, CI, and production-like environments.

> Goal: production parity. No H2, no in‑memory fallbacks, no surprises.

---

## ✅ Scope of this document

This document explains:

- How PostgreSQL is run locally
- How applications connect to it
- How it integrates with Flyway and Testcontainers
- Common workflows and troubleshooting steps

---

## 🧩 Service overview

| Item | Value |
|----|----|
| Service name (Docker Compose) | `postgres` |
| Default port | `5432` |
| Database name | Defined in `.env` |
| Persistence | Docker volume |
| CI usage | Testcontainers |

> In CI and tests, PostgreSQL is **not shared** — each run uses an isolated container.

---

## 🚀 Local startup

From the repository root:

```bash
make up
```

This starts PostgreSQL (and any other required local services).

To stop services:

```bash
make down
```

To stop services **and remove volumes** (⚠️ wipes all DB data):

```bash
make nuke
```

---

## 🔐 Configuration & environment variables

Local configuration is controlled via `.env`.

Typical values:

```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/pokemon_trainer_platform
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=postgres
```

> Your `.env` file is the source of truth.  
> Helm / Kubernetes values should mirror these variables.

---

## 🔍 Verifying PostgreSQL is running

Check container status:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Follow logs:

```bash
docker logs -f postgres
```

---

## 🧪 Connecting with `psql`

### From your host machine

```bash
psql "postgresql://postgres:postgres@localhost:5432/pokemon_trainer_platform"
```

### From inside the container

```bash
docker exec -it postgres psql -U postgres -d pokemon_trainer_platform
```

Helpful `psql` commands:

```sql
\l        -- list databases
\dt       -- list tables
\d+ name  -- describe table
\x on     -- expanded output
```

---

## 🧱 Flyway migrations

Database schema is managed using **Flyway**.

- Migrations live in: `src/main/resources/db/migration`
- Applied automatically on app startup and during integration tests
- Versioned, ordered, and repeatable by design

Inspect applied migrations:

```sql
SELECT * FROM flyway_schema_history ORDER BY installed_rank;
```

---

## 🧫 Testcontainers behavior

### Local dev

- You usually connect to the shared local PostgreSQL service.

### Tests / CI

- Testcontainers launches a **fresh PostgreSQL container**
- Database state is isolated per test run
- No reliance on your local DB

This ensures:

- Reproducibility
- Parallel-safe test execution
- Zero cross-test contamination

---

## 🧯 Troubleshooting

### Port 5432 already in use

Check what’s using it:

```bash
lsof -nP -iTCP:5432 -sTCP:LISTEN
```

Options:

- Stop the conflicting service
- Or remap the port in Compose and update your datasource URL

---

### Docker / Colima issues

Verify Docker:

```bash
docker info >/dev/null && echo "docker OK"
```

If using Colima:

```bash
colima status
```

---

### `act` requires `/var/run/docker.sock`

When simulating GitHub Actions locally with `act` on macOS + Colima:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

---

### Resetting the database

⚠️ **Destructive**

Full reset:

```bash
make nuke
make up
```

Manual schema reset:

```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
```

Then restart the app to re-run Flyway migrations.

---

## 📚 Related documentation

- `docs/onboarding/ENVIRONMENT.md`
- `docs/adr/ADR-001-postgresql-baseline.md`
- `docs/adr/ADR-002-flyway.md`
- `README.md`
