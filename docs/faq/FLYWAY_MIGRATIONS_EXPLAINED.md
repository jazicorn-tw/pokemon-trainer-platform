# Flyway Migrations: What's Actually Going On

If you've wondered why all the tables are in one file, what happens if
you edit a migration, or how to reset your local database — this
document explains it.

---

## What Flyway does

Flyway tracks which SQL migration scripts have been applied to a database
and runs any that haven't been applied yet, in version order.

Each migration is a versioned SQL file:

```text
src/main/resources/db/migration/
  V1__init.sql       ← applied once, never modified
  V2__add_column.sql ← applied after V1, once
  ...
```

Flyway stores a `flyway_schema_history` table in the database to track
what has run. If a file that was already applied is modified, Flyway
detects the checksum mismatch and refuses to start the application.

---

## Why all tables are in `V1__init.sql`

Opening `V1__init.sql` you will see tables for Phase 1 through Phase 7:
`resource`, `{{resource}}`, `trade`, `trade_{{resource}}`, `trade_offer`,
`sale_listing`, `user_account`.

This is intentional — **not** a mistake or over-engineering.

All tables are defined upfront so that:

- **Foreign key constraints are consistent from day one** — adding a
  table later that references an existing table requires the referenced
  table to already exist
- **Schema evolves through `ALTER TABLE` migrations** (V2+), not by
  rewriting V1
- **Testcontainers gets a complete schema** without needing to apply
  a sequence of partial migrations

Tables for future phases exist but their application code does not.
A Phase 2 contributor adds business logic, not new tables.

---

## Flyway versioning rules

| Rule | Detail |
| ---- | ------ |
| Filename format | `V{number}__{description}.sql` (two underscores) |
| Version number | Integers only — `V2`, `V3`, not `V1.1` |
| Order | Applied in ascending version order |
| Immutability | **Never edit a migration that has already run** |
| Idempotency | Each file runs exactly once per database |

Version numbers do not need to be sequential. `V2`, `V10`, `V100` all
work — Flyway sorts numerically.

---

## Adding a new migration

1. Create a new file in `src/main/resources/db/migration/`:

   ```text
   V2__add_nickname_index.sql
   ```

2. Write valid PostgreSQL:

   ```sql
   CREATE INDEX idx_{{resource}}_nickname ON {{resource}}(nickname);
   ```

3. Start the application or run tests — Flyway applies it automatically.

> ⚠️ Check `git log -- src/main/resources/db/migration/` before choosing
> a version number to avoid conflicts with other branches.

---

## What happens if you edit an existing migration

Flyway computes a checksum of every applied migration file. If a file
changes after it has been applied, the next startup fails:

```text
FlywayException: Validate failed:
Migration checksum mismatch for migration version 1
-> Applied to database : 1234567890
-> Resolved locally    : 0987654321
```

**Fix:** Do not modify applied migrations. Instead, write a new `V2__`
migration that alters or corrects what `V1` did.

If you are working locally and genuinely need to change `V1` (e.g.
during early schema design), clean and reapply:

```bash
docker compose down -v          # wipe the volume and data
docker compose up -d postgres   # fresh container
./gradlew bootRun               # Flyway re-applies from V1
```

---

## Resetting your local database

### Option 1 — Wipe the Docker volume (recommended)

```bash
docker compose down -v
docker compose up -d postgres
```

This destroys all data and the `flyway_schema_history` table. The next
application startup runs all migrations from V1.

### Option 2 — Flyway clean (requires `clean-disabled=false`)

```bash
./gradlew flywayClean -DSPRING_DATASOURCE_URL=... \
                      -DSPRING_DATASOURCE_USERNAME=... \
                      -DSPRING_DATASOURCE_PASSWORD=...
```

`spring.flyway.clean-disabled=false` is set in `application.properties`
so this command works locally. It drops all objects in the schema and
allows `flywayMigrate` to reapply from V1.

> ⚠️ `flywayClean` destroys all data. Never run it against a shared or
> production database.

### Option 3 — Manual reset via psql

```bash
docker exec -it $(docker compose ps -q postgres) \
  psql -U resource -d resource -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

Then restart the application to trigger Flyway.

---

## How Testcontainers and Flyway interact

Integration tests use Testcontainers (a fresh PostgreSQL container per
test class). Flyway runs automatically on that container when the Spring
context loads, applying all migrations from V1.

This means:

- Each test class starts with a clean, fully-migrated schema
- You never need to seed the schema manually in tests
- `@BeforeEach` is used for **data** cleanup, not schema setup

```java
@BeforeEach
void cleanup() {
    resourceRepository.deleteAll();   // wipe rows, not tables
}
```

The test profile (`application-test.yml`) enables
`baseline-on-migrate: true` as a safety net for the first Flyway run
against a fresh container.

---

## Related

- `src/main/resources/db/migration/V1__init.sql` — full schema
- `docs/adr/ADR-001-database-postgresql.md` — why PostgreSQL everywhere
- `docs/adr/ADR-002-testcontainers.md` — why Testcontainers, not H2
- [`TESTCONTAINERS_EXPLAINED.md`](./TESTCONTAINERS_EXPLAINED.md) — container lifecycle detail
