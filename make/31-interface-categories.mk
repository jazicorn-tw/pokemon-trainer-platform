# -----------------------------------------------------------------------------
# 31-interface-categories.mk (30s — Interface)
#
# Responsibility: Help grouping taxonomy (categories).
#
# Rule: Interface-only. No business logic.
# -----------------------------------------------------------------------------

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
        help-onboarding help-env help-quality help-docker help-local-hygiene \
        help-category-inspection help-act help-ci

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

help-roles: ## 🧑‍💼 Opinionated role/workflow entrypoints
	$(call section,🧑‍💼  Roles & Workflow Entrypoints)
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "contributor" "→ PR-ready checks (format + verify)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "reviewer" "→ CI-parity checks (quality)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "maintainer" "→ heaviest local confidence (quality + optional act/helm)"
	$(call println,)
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "dev-up" "→ start local dev prerequisites (env-up)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "dev-down" "→ stop local dev prerequisites (env-down)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "dev-status" "→ show local dev prerequisite status (env-status)"
	$(call println,)
	@printf "$(GRAY)Note: role/workflow entrypoints live in make/51-role-entrypoint.mk.$(RESET)\n"
	$(call println,)

# -------------------------------------------------------------------
# Category sections
# -------------------------------------------------------------------

help-onboarding: ## 🧰 First-time setup & onboarding
	$(call section,🧰  Onboarding & Setup)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init" "→ create .env from example"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init-act" "→ create act env (.vars + .secrets + ~/.actrc) from examples"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-help" "→ docs: local environment setup"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "bootstrap" "→ first-time setup (dev)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "bootstrap-act" "→ first-time setup for local CI simulation (act)"
	$(call println,)

help-env: ## 🧰 Local env & configuration
	$(call section,🧰  Env & Local Config)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "check-env" "→ verify required env file (.env)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init" "→ init baseline env from examples (safe)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init-force" "→ overwrite baseline env from examples ($(RED)⚠️ destructive$(RESET))"
	$(call println,)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "check-env-act" "→ verify act env files (.vars + .secrets + ~/.actrc)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init-act" "→ init act env files from examples (safe)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-init-act-force" "→ overwrite act env files from examples ($(RED)⚠️ destructive$(RESET))"
	$(call println,)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-help" "→ docs: local environment setup"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "env-help-act" "→ docs: act environment setup"
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

help-local-hygiene: ## 🧼 Local hygiene (disk pressure relief)
	$(call section,🧼  Local Hygiene)
	@printf "%b\n" "$(GRAY)Tip: for act commands and workflow simulation, see: make help-act$(RESET)"
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "clean-local-info" "→ snapshot (act cache + docker + colima status)"
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "clean-local" "→ act + docker hygiene (Colima reset is explicit)"
	$(call println,)
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "clean-act" "→ warn + optional remove of .gradle-act"
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "clean-docker" "→ docker prune (explicit opt-in; supports auto mode)"
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "docker-cache-info" "→ docker disk usage breakdown"
	$(call println,)
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "colima-info" "→ show colima status"
	@printf "  $(BOLD)%-20s$(RESET) %s\n" "clean-colima" "→ reset colima VM ($(RED)☢️ nuclear$(RESET))"
	$(call println,)
	@printf "  $(GRAY)%s$(RESET)\n" "Docs: docs/tooling/LOCAL_HYGIENE.md"
	$(call println,)

help-inspect: ## 🧭 Inspection / Navigation
	$(call section,🧭  Inspection / Navigation)
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "tree [path]"              "→ inspect repo structure (read-only)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "inspect-mk"              "→ list make modules (read-only)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "inspect-mk 50"           "→ inspect targets in a decade mk file"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "inspect-mk FLAG=a"       "→ inspect all make modules"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "inspect-mk 50 FLAG=a"    "→ inspect all mk files in a decade"
	@printf "  $(GRAY)%s$(RESET)\n" "Docs: docs/make/TREE.md, docs/make/INSPECT.md, scripts/inspect/make/"
	$(call println,)


help-act: ## 🧪 Local CI with act
	$(call section,🧪  act — Local GitHub Actions)
	@printf "%b\n" "$(GRAY)Tip: disk errors / containerd failures? See: make help-local-hygiene$(RESET)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "bootstrap-act" "→ first-time setup for local CI simulation"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "run-ci" "→ run via act (default wf=ci-test)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "list-ci" "→ list jobs for workflow via act"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act" "→ alias: run-ci"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act-all" "→ run ALL workflows (auto-discovered)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "act-all-ci" "→ run CI-only workflows (skips image workflows)"
	$(call println,)

help-ci: ## 🧰 CI-relevant targets only
	$(call section,🧰  CI-relevant Make Targets)
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "verify" "→ doctor + lint + test"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "quality" "→ doctor + spotlessCheck + clean check"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "test-ci" "→ clean test (CI-like)"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "bootstrap-act" "→ setup local CI simulation prereqs"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "run-ci" "→ run workflows via act"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "list-ci" "→ list act jobs"
	@printf "  $(BOLD)%-18s$(RESET) %s\n" "release-dry-run" "→ preview next semantic-release version (no publish)"
	$(call println,)
