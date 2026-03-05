#!/bin/bash

# Credentials — reads from environment if set (make db-flyway-clean exports SPRING_DATASOURCE_*
# from .env automatically). Falls back to local-settings.json local.db.*, then hard defaults.
_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
_LS_FILE="${_REPO_ROOT}/.config/local-settings.json"
_ls_db_host=""
_ls_db_port=""
_ls_db_name=""
if [[ -f "${_LS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  _ls_db_host="$(jq -r '.local.db.host // empty' "${_LS_FILE}" 2>/dev/null || true)"
  _ls_db_port="$(jq -r '.local.db.port // empty' "${_LS_FILE}" 2>/dev/null || true)"
  _ls_db_name="$(jq -r '.local.db.name // empty' "${_LS_FILE}" 2>/dev/null || true)"
fi

_db_host="${_ls_db_host:-localhost}"
_db_port="${_ls_db_port:-5432}"
_db_name="${_ls_db_name:-${APP_NAME:-app}}"

# Precedence: env var > local-settings.json > APP_NAME > hard default
DB_URL="${SPRING_DATASOURCE_URL:-jdbc:postgresql://${_db_host}:${_db_port}/${_db_name}}"
DB_USER="${SPRING_DATASOURCE_USERNAME:-${APP_NAME:-app}}"
DB_PASS="${SPRING_DATASOURCE_PASSWORD:-changeme}"

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