#!/bin/bash

# Credentials — reads from environment if set (make db-flyway-clean exports SPRING_DATASOURCE_*
# from .env automatically). Falls back to docker-compose postgres defaults if not set.
DB_URL="${SPRING_DATASOURCE_URL:-jdbc:postgresql://localhost:5432/pokedex}"
DB_USER="${SPRING_DATASOURCE_USERNAME:-trainer}"
DB_PASS="${SPRING_DATASOURCE_PASSWORD:-trainer}"

echo "🧼 Starting Flyway Clean..."

# Check if flyway is installed
if ! command -v flyway &> /dev/null
then
    echo "❌ Error: Flyway CLI is not installed."
    echo "Run 'brew install flyway' first."
    exit 1
fi

# Execute the clean — drops all Flyway-managed objects (tables, sequences, flyway_schema_history)
# so the next app start runs all migrations from scratch.
flyway clean \
  -url="$DB_URL" \
  -user="$DB_USER" \
  -password="$DB_PASS" \
  -cleanDisabled=false

if [ $? -eq 0 ]; then
    echo "✅ Database cleaned successfully!"
else
    echo "❌ Flyway clean failed. Check if your Postgres container is running."
fi