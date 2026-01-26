# -----------------------------------------------------------------------------
# mk/65-runtime.mk
#
# Local dev environment helpers.
#
# Notes:
# - `make start` is idempotent: safe to run repeatedly.
# - It only starts prerequisites (Colima + optional Compose), not Gradle/app.
# -----------------------------------------------------------------------------

.PHONY: env-up env-down env-status

env-up: ## 🚀 Start local dev environment (runtime prerequisites)
	@./scripts/start-dev.sh

env-down: ## 🛑 Stop local dev environment
	@./scripts/stop-dev.sh

env-status: ## 🔎 Show local dev environment status
	@echo "docker context: $$(docker context show 2>/dev/null || echo 'n/a')"
	@colima status 2>/dev/null || true
	@docker ps 2>/dev/null | head -n 15 || true
