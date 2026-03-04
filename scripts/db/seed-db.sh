#!/bin/bash

# Inserts 5 sample trainers into the local Postgres container for development use.
# Safe to re-run — uses ON CONFLICT DO NOTHING so existing rows are left untouched.
#
# Requires:
#   - Docker Compose postgres container running (make docker-up)
#
# Reads POSTGRES_USER / POSTGRES_DB from environment; falls back to docker-compose defaults.

POSTGRES_USER="${POSTGRES_USER:-trainer}"
POSTGRES_DB="${POSTGRES_DB:-trainer}"

echo "🌱 Seeding database with sample trainers..."

docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<'SQL'
INSERT INTO trainer (id, username, display_name) VALUES
  (gen_random_uuid(), 'ash',   'Ash Ketchum'),
  (gen_random_uuid(), 'misty', 'Misty Waterflower'),
  (gen_random_uuid(), 'brock', 'Brock Harrison'),
  (gen_random_uuid(), 'gary',  'Gary Oak'),
  (gen_random_uuid(), 'dawn',  'Dawn')
ON CONFLICT (username) DO NOTHING;

SELECT id, username, display_name, created_at FROM trainer ORDER BY created_at;
SQL

if [ $? -eq 0 ]; then
    echo "✅ Seed complete!"
else
    echo "❌ Seed failed. Is the postgres container running? Try: make docker-up"
    exit 1
fi
