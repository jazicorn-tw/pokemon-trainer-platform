# -------------------------------------------------------------------
# HELP / DOCS
# -------------------------------------------------------------------

.PHONY: help help-short help-auto help-ci explain debug

help: ## 🧰 Show developer help (curated)
	$(call section,🧰  Pokémon Trainer Platform — Make Targets)

	$(call println,$(YELLOW)🚀 Recommended flow$(RESET))
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make demo" "→ onboarding walkthrough"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make env-init" "→ create .env + ~/.actrc from examples"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make bootstrap" "→ first-time setup"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make verify" "→ before pushing"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make run-ci" "→ simulate CI locally (act)"
	$(call println,)

	$(call println,$(YELLOW)🧪 Quality gates$(RESET))
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make doctor" "→ local environment sanity checks"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make check-env" "→ verify required env files (.env + ~/.actrc)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make env-init" "→ init env files from examples (safe)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make env-init-force" "→ overwrite env files from examples ($(RED)⚠️ destructive$(RESET))"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make env-help" "→ docs: local environment setup"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make lint" "→ static analysis only (fast-ish)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make test" "→ unit tests"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make verify" "→ doctor + lint + test"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make quality" "→ doctor + spotlessCheck + clean check"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make pre-commit" "→ smart gate (main strict, branches fast)"
	$(call println,)

	$(call println,$(YELLOW)🐳 Docker / DB$(RESET))
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make docker-up" "→ start local Docker Compose services"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make docker-down" "→ stop local Docker Compose services"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make docker-reset" "→ stop + delete volumes + restart"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make db-shell" "→ psql shell into local postgres container"
	$(call println,)

	$(call println,$(YELLOW)🧪 act (local GitHub Actions)$(RESET))
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make run-ci [wf] [job]" "→ run via act (default wf=ci-test)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make list-ci [wf]" "→ list jobs for workflow via act"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make act" "→ alias: make run-ci"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make act-all" "→ run ALL workflows (auto-discovered) via act"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make act-all-ci" "→ run CI-only workflows (skips image workflows) via act"
	$(call println,)

	$(call println,$(YELLOW)📦 Helm / Deploy (prep-only)$(RESET))
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make helm" "→ prep-only (ADR-009)"
	@printf "  $(BOLD)%-22s$(RESET) %s\n" "make deploy" "→ not wired yet"
	$(call println,)

	$(call println,$(GRAY)More: make help-short | make help-auto | make banner | make demo-ci | make doctor-json-demo | NO_COLOR=1 make help$(RESET))
	$(call println,)


help-short: ## 🧰 Quick help (minimal)
	$(call section,🧰  Quick Make Targets)
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "demo" "onboarding walkthrough"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "demo-ci" "onboarding walkthrough (no color)"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "verify" "doctor + lint + test"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "quality" "CI-parity gate"
	@printf "  $(BOLD)%-16s$(RESET) %s\n" "run-ci" "simulate CI via act"
	$(call println,)

help-auto: ## 🧾 Auto-generated help (from ## comments)
	$(call section,🧾  Auto-generated help)
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  $(BOLD)%-24s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	$(call println,)

explain: ## 🧠 Explain a target: make explain <target>
	@t="$(word 2,$(MAKECMDGOALS))"; \
	if [[ -z "$$t" ]]; then \
	  printf "%b\n" "$(RED)❌ Usage: make explain <target>$(RESET)"; \
	  printf "%b\n" "$(GRAY)Try one of: doctor check-env env-init env-init-force env-help bootstrap verify quality pre-commit run-ci$(RESET)"; \
	  exit 1; \
	fi; \
	$(call section,🧠  explain → $${t}); \
	case "$$t" in \
	  doctor)  printf "%b\n" "  $(BOLD)doctor$(RESET): runs local sanity checks (java, gradle, docker, colima, socket, env files)";; \
	  check-env) printf "%b\n" "  $(BOLD)check-env$(RESET): verifies required local env files (.env and ~/.actrc) and permissions";; \
	  env-init) printf "%b\n" "  $(BOLD)env-init$(RESET): create .env and ~/.actrc from example files (safe, non-destructive)";; \
	  env-init-force) printf "%b\n" "  $(BOLD)env-init-force$(RESET): overwrite .env and ~/.actrc from examples ($(RED)⚠️ destructive$(RESET))";; \
	  env-help) printf "%b\n" "  $(BOLD)env-help$(RESET): prints link to local environment setup documentation";; \
	  bootstrap) printf "%b\n" "  $(BOLD)bootstrap$(RESET): env-init + hooks + exec-bits + full quality gate (first-time setup)";; \
	  verify)  printf "%b\n" "  $(BOLD)verify$(RESET): doctor + lint + test (recommended before pushing)";; \
	  quality) printf "%b\n" "  $(BOLD)quality$(RESET): doctor + spotlessCheck + clean + check (matches CI intent)";; \
	  pre-commit) printf "%b\n" "  $(BOLD)pre-commit$(RESET): smart gate (main → quality, other branches → fast gate)";; \
	  run-ci)  printf "%b\n" "  $(BOLD)run-ci$(RESET): run GitHub Actions workflows locally via act (wf defaults to ci-test; optional job)";; \
	  *) \
	    printf "%b\n" "$(YELLOW)⚠️  No extended explanation available for '$$t'.$(RESET)"; \
	    printf "%b\n" "$(GRAY)Known: doctor check-env env-init env-init-force env-help bootstrap verify quality pre-commit run-ci$(RESET)"; \
	    printf "%b\n" "$(GRAY)More: docs/MAKEFILE.md$(RESET)"; \
	    ;; \
	esac; \
	$(call println,)

debug: ## 🧾 Print effective tool configuration
	$(call section,🧾  Effective configuration)
	@printf "$(BOLD)%-28s$(RESET) %s\n" "ACT" "$(ACT)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "ACT_IMAGE" "$(ACT_IMAGE)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "ACT_PLATFORM" "$(ACT_PLATFORM)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "ACT_DOCKER_SOCK" "$(ACT_DOCKER_SOCK)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "ACT_GRADLE_CACHE_DIR_EFFECTIVE" "$(ACT_GRADLE_CACHE_DIR_EFFECTIVE)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "WORKFLOW" "$(WORKFLOW)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "JOB" "$(JOB)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "WORKFLOW_FILE" "$(WORKFLOW_FILE)"
	@printf "$(BOLD)%-28s$(RESET) %s\n" "GIT_BRANCH" "$(GIT_BRANCH)"
	$(call println,)
