# -----------------------------------------------------------------------------
# 40-pre-conditions.mk (40s — Preconditions)
#
# Responsibility: Verify workstation prerequisites (no side effects).
# - required files, tool existence, version checks
#
# Rule: Checks only. Do not start/stop services here.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# ENV (baseline) — local development (non-act)
# -------------------------------------------------------------------

.PHONY: env-help env-init env-init-force check-env check-all

env-help: ## 📖 Environment setup docs
	$(call section,📖  Environment setup)
	@echo "See: docs/onboarding/ENVIRONMENT.md"

env-init: ## 🌱 Create baseline local env files from examples (non-destructive)
	$(call section,🌱  Environment init)
	@set -euo pipefail
	@changed=0
	$(call copy_idempotent,.env,.env.example,.env,create .env manually (see docs/onboarding/ENVIRONMENT.md))
	@if [[ "$$changed" -eq 0 ]]; then \
	  printf "%b\n" "$(GRAY)No changes made.$(RESET)"; \
	else \
	  printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"; \
	fi

env-init-force: ## 🚨 Force overwrite baseline env files from examples (destructive)
	$(call section,🚨  Environment init (force))
	@set -euo pipefail
	$(call copy_force,.env,.env.example,.env)
	@printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"

check-env: ## 🌱 Verify required baseline local env file (.env)
	$(call section,🌱  Environment check (baseline))
	$(call require_exec,./scripts/check/check-required-files.sh)
	@./scripts/check/check-required-files.sh

check-all: ## 🔍 Run all scripts in scripts/check/
	$(call section,🔍  Run all checks)
	$(call require_exec,./scripts/check/check-all.sh)
	@./scripts/check/check-all.sh
