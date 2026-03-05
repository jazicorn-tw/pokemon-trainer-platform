#!/bin/bash

# Inserts sample rows into the local Postgres container for development use.
# Safe to re-run — uses ON CONFLICT DO NOTHING so existing rows are left untouched.
#
# Requires:
#   - Docker Compose postgres container running (make docker-up)
#
# Reads POSTGRES_USER / POSTGRES_DB from environment; falls back to docker-compose defaults.

POSTGRES_USER="${POSTGRES_USER:-${APP_NAME:-app}}"
POSTGRES_DB="${POSTGRES_DB:-${APP_NAME:-app}}"

echo "🌱 Seeding database with sample data..."

docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<'SQL'
-- TODO: Replace with your domain seed data.
-- Example:
-- INSERT INTO "user" (id, username, display_name) VALUES
--   (gen_random_uuid(), 'alice', 'Alice Example'),
--   (gen_random_uuid(), 'bob',   'Bob Example')
-- ON CONFLICT (username) DO NOTHING;
--
-- SELECT id, username, display_name, created_at FROM "user" ORDER BY created_at;
SQL

if [ $? -eq 0 ]; then
    echo "✅ Seed complete!"
else
    echo "❌ Seed failed. Is the postgres container running? Try: make docker-up"
    exit 1
fi
