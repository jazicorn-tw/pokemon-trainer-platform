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

.PHONY: contributor reviewer maintainer

# Allow devs to skip expensive parts explicitly (still defaults to safe).
RUN_ACT ?= 1
RUN_HELM ?= 0

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
