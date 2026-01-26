# -------------------------------------------------------------------
# DOCKER / DB
# -------------------------------------------------------------------

.PHONY: docker-volume docker-up docker-down docker-reset db-shell

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
	@docker compose exec postgres psql -U $${POSTGRES_USER:-trainer} -d $${POSTGRES_DB:-trainer}
