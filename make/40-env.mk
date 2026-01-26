# -------------------------------------------------------------------
# ENV / ACT (bootstrap helpers)
# -------------------------------------------------------------------

.PHONY: env-help env-init env-init-force check-env

env-help: ## 📖 Environment setup docs
	$(call section,📖  Environment setup)
	@echo "See: docs/onboarding/ENVIRONMENT.md"

env-init: ## 🌱 Create local env files from examples (non-destructive)
	$(call section,🌱  Environment init)
	@set -euo pipefail
	@changed=0

	# .env (project root)
	@if [[ -f ".env" ]]; then \
	  printf "%b\n" "$(GRAY).env already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".env.example" ]]; then \
	    cp ".env.example" ".env"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created .env from .env.example$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .env.example — create .env manually (see docs/onboarding/ENVIRONMENT.md)$(RESET)"; \
	  fi; \
	fi

	# ~/.actrc (home directory)
	@if [[ -f "$$HOME/.actrc" ]]; then \
	  printf "%b\n" "$(GRAY)$$HOME/.actrc already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".actrc.example" ]]; then \
	    cp ".actrc.example" "$$HOME/.actrc"; \
	    chmod 600 "$$HOME/.actrc"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created $$HOME/.actrc from .actrc.example (chmod 600)$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .actrc.example — create $$HOME/.actrc manually (see docs/onboarding/ENVIRONMENT.md)$(RESET)"; \
	  fi; \
	fi

	@if [[ "$$changed" -eq 0 ]]; then \
	  printf "%b\n" "$(GRAY)No changes made.$(RESET)"; \
	else \
	  printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"; \
	fi

env-init-force: ## 🚨 Force overwrite env files from examples (destructive)
	$(call section,🚨  Environment init (force))
	@set -euo pipefail

	@if [[ -f ".env.example" ]]; then \
	  cp ".env.example" ".env"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote .env from .env.example$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .env.example — cannot overwrite .env$(RESET)"; \
	fi

	@if [[ -f ".actrc.example" ]]; then \
	  cp ".actrc.example" "$$HOME/.actrc"; \
	  chmod 600 "$$HOME/.actrc"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote $$HOME/.actrc from .actrc.example (chmod 600)$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .actrc.example — cannot overwrite $$HOME/.actrc$(RESET)"; \
	fi

	@printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"

check-env: ## 🌱 Verify required local env files (.env + ~/.actrc)
	$(call require_exec,./scripts/check-required-files.sh)
	@./scripts/check-required-files.sh
