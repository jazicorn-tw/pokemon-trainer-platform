# -----------------------------------------------------------------------------
# 51-role-entrypoint.mk (Roles entrypoints)
#
# Responsibility: Role-based orchestration targets (e.g., contributor/maintainer).
#
# Placement note:
# - If these targets are primarily "public entrypoints", treat as Interface.
# - If they’re implementation glue that calls other targets, treat as Library.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# WORKFLOWS / ROLE GATES
# -------------------------------------------------------------------
#
# Opinionated, executable entrypoints that run gates.
# These are NOT help commands.
#
# Examples:
#   make contributor
#   make reviewer
#   make maintainer
# -------------------------------------------------------------------

.PHONY: dev-up dev-down dev-status contributor reviewer maintainer

# Allow devs to skip expensive parts explicitly (still defaults to safe).
RUN_ACT ?= 1
RUN_HELM ?= 0

dev-up: ## 🔼 Start local dev prerequisites (env-up)
	@$(MAKE) --no-print-directory env-up

dev-down: ## 🔽 Stop local dev prerequisites (env-down)
	@$(MAKE) --no-print-directory env-down

dev-status: ## 📋 Show local dev env status (env-status)
	@$(MAKE) --no-print-directory env-status

contributor: ## 🧑‍💻 Run contributor gate (verify)
	@$(MAKE) --no-print-directory format verify

reviewer: ## 🧑‍🔍 Run reviewer gate (CI-parity)
	@$(MAKE) --no-print-directory quality

maintainer: ## 🧑‍🔧 Run maintainer gate (heaviest local confidence)
	@$(MAKE) --no-print-directory quality
	@if [ "$(RUN_ACT)" = "1" ]; then \
	  $(MAKE) --no-print-directory act-all-ci; \
	else \
	  printf "%b\n" "$(GRAY)↪ RUN_ACT=0: skipping act-all-ci$(RESET)"; \
	fi
	@if [ "$(RUN_HELM)" = "1" ]; then \
	  $(MAKE) --no-print-directory helm-lint; \
	else \
	  printf "%b\n" "$(GRAY)↪ RUN_HELM=0: skipping helm-lint$(RESET)"; \
	fi
