# -----------------------------------------------------------------------------
# mk/65-runtime.mk
#
# Local dev environment helpers.
#
# Notes:
# - `make start` is idempotent: safe to run repeatedly.
# - It only starts prerequisites (Colima + optional Compose), not Gradle/app.
# -----------------------------------------------------------------------------

.PHONY: env-up env-down env-status env-check run

env-up: ## 🚀 Start local dev environment (runtime prerequisites)
	@./scripts/dev/start-dev.sh

env-down: ## 🛑 Stop local dev environment
	@./scripts/dev/stop-dev.sh

env-check: check-all ## 🔍 Run all environment checks

env-status: ## 🔎 Show local dev environment status
	@echo "docker context: $$(docker context show 2>/dev/null || echo 'n/a')"
	@colima status 2>/dev/null || true
	@docker ps 2>/dev/null | head -n 15 || true

run: docker-up ## 🏃 Start the API (loads .env, runs bootRun)
	$(call step,🏃 Starting API)
	@if [ ! -f .env ]; then \
	  printf "%b\n" "$(RED)❌ .env not found — copy .env.example and fill in values$(RESET)"; \
	  exit 1; \
	fi
	@set -a; source .env; set +a; ./gradlew --no-daemon bootRun
