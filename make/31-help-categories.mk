# -------------------------------------------------------------------
# HELP CATEGORIES
# -------------------------------------------------------------------
#
# Categorized help targets + umbrella index.
#
# Include from your loader (auto-discovery recommended):
#   -include make/*.mk
#
# Requires your existing helper macros/vars:
# - $(call section,<title>)
# - $(call println,<text>)
# - Color vars: BOLD RESET YELLOW RED GRAY
# -------------------------------------------------------------------

# Capture *this* file path at include-time so help-categories only lists
# categories defined in this file (not other help-* targets elsewhere).
HELP_CATEGORIES_SRC := $(lastword $(MAKEFILE_LIST))

.PHONY: help-categories help-roles \
        help-onboarding help-env help-quality help-docker help-act help-ci help-helm

help-categories: ## 🧭 List available help-* categories
	$(call section,🧭  Help Categories)
	@awk 'BEGIN {FS = ":.*## "} \
	  /^[[:alnum:]_.-]+:.*## / { \
	    t=$$1; d=$$2; \
	    if (t ~ /^help-[[:alnum:]_.-]+$$/ && t != "help-categories") { \
	      printf "  $(BOLD)%-22s$(RESET) %s\n", t, d \
	    } \
	  }' $(HELP_CATEGORIES_SRC) | LC_ALL=C sort
	$(call println,)
	@printf "$(GRAY)Tip: run 'make <category>' for focused help, or 'make help' for the curated overview.$(RESET)\n"
	$(call println,)

help-roles: ## 🧑‍🤝‍🧑 List role-based help entrypoints
	$(call section,🧑‍🤝‍🧑  Make Roles)
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "help-contributor" "→ onboarding + env + quality (recommended for new contributors)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "help-reviewer" "→ CI-relevant targets (review / triage)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "help-maintainer" "→ maintainer workflow (ci + act + docker + helm)"
	$(call println,)
	@printf "$(GRAY)Note: role aliases are defined in make/32-help-roles.mk.$(RESET)\n"
	$(call println,)

# -------------------------------------------------------------------
# Category sections
# -------------------------------------------------------------------

help-onboarding: ## 🧰 First-time setup & onboarding
	$(call section,🧰  Onboarding & Setup)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "demo" "→ onboarding walkthrough"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "demo-ci" "→ onboarding walkthrough (no color)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init" "→ create .env + ~/.actrc from examples"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-help" "→ docs: local environment setup"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "bootstrap" "→ first-time setup"
	$(call println,)

help-env: ## 🧰 Local env & configuration
	$(call section,🧰  Env & Local Config)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "check-env" "→ verify required env files (.env + ~/.actrc)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init" "→ init env files from examples (safe)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init-force" "→ overwrite env files from examples ($(RED)⚠️ destructive$(RESET))"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-help" "→ docs: local environment setup"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "debug" "→ print effective tool configuration"
	$(call println,)

help-quality: ## 🧪 Quality gates & formatting
	$(call section,🧪  Quality Gates)
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "doctor" "→ local environment sanity checks"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "lint" "→ static analysis only (fast-ish)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "test" "→ unit tests"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "verify" "→ doctor + lint + test"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "quality" "→ doctor + spotlessCheck + clean check (CI-parity intent)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "pre-commit" "→ smart gate (main strict, branches fast)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "format" "→ apply formatting (Spotless)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "format-check" "→ formatting validation only"
	$(call println,)

help-docker: ## 🐳 Docker & database workflows
	$(call section,🐳  Docker & Database)
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "docker-up" "→ start local Docker Compose services"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "docker-down" "→ stop local Docker Compose services"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "docker-reset" "→ stop + delete volumes + restart"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "db-shell" "→ psql shell into local postgres container"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "db-logs" "→ tail postgres logs (if available)"
	$(call println,)

help-act: ## 🧪 Local CI with act
	$(call section,🧪  act — Local GitHub Actions)
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "run-ci" "→ run via act (default wf=ci-test)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "list-ci" "→ list jobs for workflow via act"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act" "→ alias: run-ci"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act-all" "→ run ALL workflows (auto-discovered)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act-all-ci" "→ run CI-only workflows (skips image workflows)"
	$(call println,)

help-ci: ## 🧰 CI-relevant targets only
	$(call section,🧰  CI-relevant Make Targets)
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "verify" "→ doctor + lint + test"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "quality" "→ doctor + spotlessCheck + clean check"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "test-ci" "→ clean test (CI-like)"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "run-ci" "→ run workflows via act"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "list-ci" "→ list act jobs"
	$(call println,)

help-helm: ## 📦 Helm & deploy (prep-only)
	$(call section,📦  Helm & Deploy (prep-only))
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "helm" "→ prep-only (ADR-009)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "helm-lint" "→ lint chart (if wired)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "deploy" "→ not wired yet"
	$(call println,)
