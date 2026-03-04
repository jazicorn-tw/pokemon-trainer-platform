# -----------------------------------------------------------------------------
# 41-preconditions-act.mk (40s — Preconditions)
#
# Responsibility: Verify *act-specific* workstation prerequisites (no side effects).
#
# Why a separate file?
# - `act` is an optional local CI simulation tool.
# - Contributors should not be forced to configure act just to run the app/tests.
# - This isolates act-only contracts (like `.vars`, `~/.actrc`, `.secrets`) from baseline onboarding.
#
# Rule: Checks only. Do not start/stop services here.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# ENV / ACT — local CI simulation helpers
# -------------------------------------------------------------------

.PHONY: env-help-act env-init-act env-init-act-force check-env-act

env-help-act: ## 📖 act environment setup docs
	$(call section,📖  act environment setup)
	@echo "See: docs/environment/ENV_SPEC_ACT.md"

env-init-act: ## 🧪 Create act-only local env files from examples (non-destructive)
	$(call section,🧪  Environment init (act))
	@set -euo pipefail
	@changed=0
	$(call copy_idempotent,.vars,.vars.example,.vars,create .vars manually (see docs/onboarding/ENVIRONMENT.md))
	$(call copy_idempotent,.secrets,.secrets.example,.secrets,create .secrets manually (see SECRETS.md))
	$(call copy_idempotent,$$HOME/.actrc,.actrc.example,$$HOME/.actrc,create $$HOME/.actrc manually (see docs/onboarding/ENVIRONMENT.md),chmod 600 "$$HOME/.actrc")
	@if [[ "$$changed" -eq 0 ]]; then \
	  printf "%b\n" "$(GRAY)No changes made.$(RESET)"; \
	else \
	  printf "%b\n" "$(GREEN)Done. Next: make bootstrap-act$(RESET)"; \
	fi

env-init-act-force: ## 🚨 Force overwrite act-only env files from examples (destructive)
	$(call section,🚨  Environment init (act, force))
	@set -euo pipefail
	$(call copy_force,.vars,.vars.example,.vars)
	$(call copy_force,.secrets,.secrets.example,.secrets)
	$(call copy_force,$$HOME/.actrc,.actrc.example,$$HOME/.actrc,chmod 600 "$$HOME/.actrc")
	@printf "%b\n" "$(GREEN)Done.$(RESET)"

check-env-act: ## 🧪 Verify act-only local env files (.vars + .secrets + ~/.actrc)
	$(call section,🧪  Environment check (act))
	$(call require_exec,./scripts/check/check-required-files-act.sh)
	@./scripts/check/check-required-files-act.sh
