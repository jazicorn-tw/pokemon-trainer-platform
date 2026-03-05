# -----------------------------------------------------------------------------
# 70-docker.mk (70s — Runtime Orchestration)
#
# Responsibility: Ensure local runtime prerequisites are running.
# - Colima/Docker, compose stacks, local services/emulators
#
# Rule: Mutates machine state by design. Must be idempotent and safe to re-run.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# DOCKER / DB
# -------------------------------------------------------------------

.PHONY: docker-volume docker-up docker-down docker-reset db-shell db-flyway-clean seed-db

# Read POSTGRES_IMAGE from local-settings.json (docker.postgres.image) if jq is available.
# Falls back to the default in docker-compose.yml (${POSTGRES_IMAGE:-postgres:16-alpine}).
_POSTGRES_IMAGE := $(shell \
  ls=$(LOCAL_SETTINGS); \
  if [ -f "$$ls" ] && command -v jq >/dev/null 2>&1; then \
    jq -r '.docker.postgres.image // empty' "$$ls" 2>/dev/null; \
  fi)
export POSTGRES_IMAGE ?= $(_POSTGRES_IMAGE)

docker-volume: ## 🐳 List local Docker volumes (postgres-focused)
	$(call step,🐳 Listing postgres volumes)
	@docker volume ls | grep -i postgres || true

docker-up: ## 🐳 Start local Docker Compose services
	$(call step,🐳 Starting Docker Compose)
	@docker compose up -d

docker-down: ## 🐳 Stop local Docker Compose services
	$(call step,🐳 Stopping Docker Compose)
	@docker compose down

docker-reset: ## 🧨 Reset local Docker environment (containers + volumes)
	$(call step,🧨 Resetting Docker (containers + volumes))
	@printf "%b\n" "$(YELLOW)⚠️  This will delete volumes.$(RESET)"
	@docker compose down -v
	@docker compose up -d

db-shell: ## 🐘 Open a psql shell in the postgres container
	$(call step,🐘 Opening psql shell)
	@docker compose exec postgres psql -U $${POSTGRES_USER:-$${APP_NAME:-app}} -d $${POSTGRES_DB:-$${APP_NAME:-app}}

# db-flyway-clean runs scripts/db/clean-db-flyway.sh, which calls `flyway clean` to drop ALL
# Flyway-managed objects (tables, sequences, flyway_schema_history) from the local database.
# The next app start (make run) will re-apply every migration from scratch.
#
# Requirements:
#   - Flyway CLI must be installed (brew install flyway)
#   - .env must exist (copy .env.example and fill in values)
#   - Docker Compose postgres container must be running (make docker-up)
#
# Credentials are sourced from .env using SPRING_DATASOURCE_URL / SPRING_DATASOURCE_USERNAME / SPRING_DATASOURCE_PASSWORD —
# the same values the Spring Boot app uses — so no manual credential editing is needed.
db-flyway-clean: ## 🧼 Wipe DB schema via Flyway CLI (requires: flyway installed, .env present)
	$(call step,🧼 Flyway clean — drop all schema objects)
	$(call info,Requires: flyway CLI \(brew install flyway\))
	$(call info,Reads SPRING_DATASOURCE_* from .env)
	@if [ ! -f .env ]; then \
	  printf "%b\n" "$(RED)❌ .env not found — copy .env.example and fill in values$(RESET)"; \
	  exit 1; \
	fi
	@set -a; source .env; set +a; ./scripts/db/clean-db-flyway.sh

# seed-db runs scripts/db/seed-db.sh, which inserts sample rows into the local database
# for development use.
# Safe to re-run — ON CONFLICT DO NOTHING skips rows that already exist.
# Requires the Docker Compose postgres container to be running (make docker-up).
seed-db: ## 🌱 Seed local DB with sample data (idempotent)
	$(call step,🌱 Seeding database)
	$(call info,Requires postgres container \(make docker-up\))
	@./scripts/db/seed-db.sh
