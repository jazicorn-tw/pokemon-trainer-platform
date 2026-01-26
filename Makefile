# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

.DEFAULT_GOAL := help

# -------------------------------------------------------------------
# Console styling
# -------------------------------------------------------------------

ESC := \033
RESET := $(ESC)[0m
BOLD := $(ESC)[1m
DIM := $(ESC)[2m

CYAN := $(ESC)[1;36m
YELLOW := $(ESC)[1;33m
GREEN := $(ESC)[1;32m
RED := $(ESC)[1;31m
GRAY := $(ESC)[90m

HR := $(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)
HR2 := $(CYAN)════════════════════════════════════════════════$(RESET)

# Auto-disable colors when stdout is not a TTY (pipes / CI logs)
ifneq ($(shell test -t 1 && echo tty),tty)
NO_COLOR := 1
endif

# Respect NO_COLOR=1
ifeq ($(NO_COLOR),1)
RESET :=
BOLD :=
DIM :=
CYAN :=
YELLOW :=
GREEN :=
RED :=
GRAY :=
HR := ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HR2 := ════════════════════════════════════════════════
endif

# -------------------------------------------------------------------
# Printing helpers (portable; printf interprets \033 correctly)
# -------------------------------------------------------------------

define println
	@printf "%b\n" "$1"
endef

define print
	@printf "%b" "$1"
endef

define section
	$(call println,)
	$(call println,$(HR))
	$(call println,$(CYAN)$(BOLD)$1$(RESET))
	$(call println,$(HR))
	$(call println,)
endef

# "Hero-lite" header: bigger divider, no box
define section2
	$(call println,)
	$(call println,$(HR2))
	$(call println,$(CYAN)$(BOLD)$1$(RESET))
	$(call println,$(HR2))
	$(call println,)
endef

define step
	$(call println,$(CYAN)▶$(RESET) $(BOLD)$1$(RESET))
endef

define info
	$(call println,$(GRAY)$1$(RESET))
endef

define warn
	$(call println,$(YELLOW)$1$(RESET))
endef

# =============================================================================
# GROUPED LOGGING (CI-friendly, optional locally)
#
# IMPORTANT:
# - Do NOT redefine `group_start` / `group_end` elsewhere in this file.
# - These macros are intentionally centralized here so log grouping behavior
#   can be toggled globally.
#
# Behavior:
# - CI=true            → groups ENABLED (GitHub Actions compatible)
# - GROUP_LOGS=1       → groups ENABLED locally
# - default (local)    → groups DISABLED for clean console output
#
# Usage:
#   $(call group_start,<name>)
#     … commands …
#   $(call group_end)
#
# This design keeps:
# - CI logs structured and collapsible
# - Local DX clean and readable
# =============================================================================

GROUP_LOGS ?= $(if $(CI),1,0)

ifeq ($(GROUP_LOGS),1)
define group_start
	$(call println,::group::$1)
endef
define group_end
	$(call println,::endgroup::)
endef
else
define group_start
	@:
endef
define group_end
	@:
endef
endif

# -------------------------------------------------------------------
# EXEC BIT GUARDS (DX) — context-aware + polished
#
# Features:
# - Detects non-executable scripts
# - Prints copy-pasteable chmod commands
# - Only prints `cd <repo-root>` if NOT already in repo root
# - Shows a thumbs up (👍) when already in repo root
# - .ONESHELL-safe (uses plain printf)
#
# Usage:
#   $(call require_exec,./scripts/foo.sh ./scripts/bar.sh)
# -------------------------------------------------------------------

define require_exec
	@missing=""; \
	for f in $(1); do \
	  if [ ! -x "$$f" ]; then missing="$$missing $$f"; fi; \
	done; \
	if [ -n "$$missing" ]; then \
	  repo_root="$$(git rev-parse --show-toplevel 2>/dev/null)"; \
	  cwd="$$(pwd)"; \
	  printf "%b\n" "$(RED)❌ Permission denied: non-executable script(s) detected$(RESET)"; \
	  printf "%b\n" "$(GRAY)Fix by running the following commands:$(RESET)"; \
	  printf "%b\n" ""; \
	  if [ "$$cwd" = "$$repo_root" ]; then \
	    printf "%b\n" "$(GREEN)👍 You are already in the repo root$(RESET)"; \
	  else \
	    printf "%b\n" "$(BOLD)cd \"$$repo_root\"$(RESET)"; \
	  fi; \
	  for f in $$missing; do \
	    f="$${f#./}"; \
	    printf "%b\n" "$(BOLD)chmod +x $$f$(RESET)"; \
	  done; \
	  printf "%b\n" ""; \
	  exit 126; \
	fi
endef

# -------------------------------------------------------------------
# Developer settings
# -------------------------------------------------------------------

LOCAL_SETTINGS ?= .config/local-settings.json

# -------------------------------------------------------------------
# act workflow discovery
#
# - AUTO_DISCOVERED_WORKFLOWS: all workflows in .github/workflows
# - CI_WORKFLOWS: CI-only (excludes image build/publish by default)
# - IMAGE_WORKFLOWS: image-related workflows
#
# You can still override manually:
#   make act-all CI_WORKFLOWS="ci-test ci-quality"
# -------------------------------------------------------------------

AUTO_DISCOVERED_WORKFLOWS := $(sort $(basename $(notdir $(wildcard .github/workflows/*.yml .github/workflows/*.yaml))))

IMAGE_WORKFLOWS ?= image-build image-publish
CI_WORKFLOWS ?= $(filter-out $(IMAGE_WORKFLOWS),$(AUTO_DISCOVERED_WORKFLOWS))

# Final workflow lists used by make targets
ACT_WORKFLOWS ?= $(sort $(AUTO_DISCOVERED_WORKFLOWS))
ACT_CI_WORKFLOWS ?= $(sort $(CI_WORKFLOWS))

# --- act (local GitHub Actions) ---
ACT ?= act
ACT_IMAGE ?= catthehacker/ubuntu:full-latest
ACT_PLATFORM ?= linux/amd64
ACT_DOCKER_SOCK ?= /var/run/docker.sock

# -----------------------------------------------------------------------------
# act runner tuning (Gradle cache + safer networking defaults)
# -----------------------------------------------------------------------------
ACT_GRADLE_CACHE_DIR ?=
ACT_GRADLE_CACHE_DIR_EFFECTIVE := $(or $(strip $(ACT_GRADLE_CACHE_DIR)),$(CURDIR)/.gradle-act)

# Use JAVA_TOOL_OPTIONS to avoid quoting issues inside `--container-options`
ACT_JAVA_TOOL_OPTIONS := \
  -Djava.net.preferIPv4Stack=true \
  -Dorg.gradle.internal.http.connectionTimeout=60000 \
  -Dorg.gradle.internal.http.socketTimeout=60000

# Use docker-short flags and single-quotes for values containing spaces
ACT_CONTAINER_OPTS ?= \
  -e JAVA_TOOL_OPTIONS='$(ACT_JAVA_TOOL_OPTIONS)' \
  -e GRADLE_USER_HOME=/tmp/gradle \
  -v $(ACT_GRADLE_CACHE_DIR_EFFECTIVE):/tmp/gradle

# Capture positional args after the target name (for run-ci/list-ci/explain)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
WORKFLOW_ARG := $(word 1,$(ARGS))
JOB := $(word 2,$(ARGS))
WORKFLOW := $(if $(WORKFLOW_ARG),$(WORKFLOW_ARG),ci-test)

# Support either .yml or .yaml workflow files (prefers .yml if present)
WORKFLOW_FILE_YML := .github/workflows/$(WORKFLOW).yml
WORKFLOW_FILE_YAML := .github/workflows/$(WORKFLOW).yaml
WORKFLOW_FILE := $(if $(wildcard $(WORKFLOW_FILE_YML)),$(WORKFLOW_FILE_YML),$(WORKFLOW_FILE_YAML))

# Detect current git branch (Phase 0)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

.PHONY: \
  help help-short help-auto help-ci \
  explain debug \
  local-settings exec-bits hooks doctor doctor-json doctor-json-strict doctor-json-pretty \
  check-env env-init env-init-force env-help \
  clean clean-all \
  format lint test verify quality test-ci bootstrap pre-commit \
  docker-volume docker-up docker-down docker-reset db-shell \
  act act-all act-all-ci run-ci list-ci \
  helm deploy

# -------------------------------------------------------------------
# HELP / DOCS
# -------------------------------------------------------------------

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

help-ci: ## 🧰 Show only CI-relevant targets
	$(call section,🧰  CI-relevant Make Targets)
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "verify" "→ doctor + lint + test"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "quality" "→ doctor + spotlessCheck + clean check"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "test-ci" "→ clean test (CI-like)"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "run-ci" "→ run workflows via act"
	@printf "  $(BOLD)%-12s$(RESET) %s\n" "list-ci" "→ list act jobs"
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

# -------------------------------------------------------------------
# ENV / ACT (bootstrap helpers)
# -------------------------------------------------------------------

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

# -------------------------------------------------------------------
# CONFIG / UTIL
# -------------------------------------------------------------------

check-env: ## 🌱 Verify required local env files (.env + ~/.actrc)
	$(call require_exec,./scripts/check-required-files.sh)
	@./scripts/check-required-files.sh

local-settings: ## 🧩 Print effective local settings
	$(call section,🧩  Local settings)
	@echo "LOCAL_SETTINGS=$(LOCAL_SETTINGS)"
	@test -f "$(LOCAL_SETTINGS)" && cat "$(LOCAL_SETTINGS)" || printf "%b\n" "$(GRAY)No local settings file found.$(RESET)"

exec-bits: ## 🔧 Check & (optionally) auto-fix executable bits for tracked scripts
	$(call require_exec,./scripts/check-executable-bits.sh)
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check-executable-bits.sh

hooks: ## 🪝 Configure repo-local git hooks
	$(call require_exec,./scripts/install-hooks.sh)
	@./scripts/install-hooks.sh

doctor: check-env ## 🩺 Local environment sanity checks
	$(call require_exec,./scripts/doctor.sh)
	$(call group_start,doctor)
	$(call step,🩺 Running doctor checks)
	@./scripts/doctor.sh
	$(call group_end)

doctor-json: ## 🧪 Doctor JSON output
	@DOCTOR_JSON=1 ./scripts/doctor.sh | jq .

doctor-json-strict: ## 🚨 Doctor JSON strict (fail on warnings)
	@DOCTOR_JSON=1 ./scripts/doctor.sh --strict | jq .

doctor-json-pretty: ## 🧪 Doctor JSON output (pretty-printed for humans)
	@if command -v jq >/dev/null 2>&1; then \
	  DOCTOR_JSON=1 ./scripts/doctor.sh | jq . ; \
	else \
	  echo "⚠️  jq not found; printing raw JSON (install with: brew install jq)"; \
	  DOCTOR_JSON=1 ./scripts/doctor.sh ; \
	fi

clean: ## 🧹 Clean build outputs
	$(call step,🧹 Gradle clean)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q clean

clean-all: ## 🧹 Clean build + purge local caches (use sparingly)
	$(call step,🧹 Clean + purge local caches)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q clean
	@rm -rf .gradle build

# -------------------------------------------------------------------
# PRE-COMMIT POLICY (Phase 0 aware)
# -------------------------------------------------------------------

pre-commit: ## 🪝 Smart pre-commit gate (strict on main)
	@if [ "$(GIT_BRANCH)" = "main" ]; then \
	  printf "%b\n" "$(CYAN)🪝 pre-commit$(RESET): on '$(BOLD)main$(RESET)' → running $(BOLD)quality$(RESET)"; \
	  $(MAKE) quality; \
	else \
	  printf "%b\n" "$(CYAN)🪝 pre-commit$(RESET): on '$(BOLD)$(GIT_BRANCH)$(RESET)' → running fast gate ($(BOLD)format + lint + test$(RESET))"; \
	  $(MAKE) format lint test; \
	fi

format: ## ✨ Auto-format sources
	$(call group_start,format)
	$(call step,✨ spotlessApply)
	@if [ "$${NUKE_GRADLE_CACHE:-0}" = "1" ]; then \
	  printf "%b\n" "$(YELLOW)⚠️  NUKE_GRADLE_CACHE=1$(RESET) → removing Gradle caches"; \
	  rm -rf .gradle/configuration-cache .gradle/caches; \
	fi
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q --no-configuration-cache spotlessApply
	$(call group_end)

lint: ## 🔎 Static analysis only (fast-ish)
	$(call group_start,lint)
	$(call step,🔎 Static analysis)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q --no-configuration-cache checkstyleMain checkstyleTest pmdMain pmdTest spotbugsMain spotbugsTest
	$(call group_end)

test: ## 🧪 Unit tests
	$(call group_start,test)
	$(call step,🧪 Unit tests)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q test
	$(call group_end)

verify: doctor lint test ## ✅ Doctor + lint + test
	@printf "%b\n" "$(GREEN)✅ verify complete$(RESET)"

quality: doctor ## ✅ Doctor + spotlessCheck + clean check (matches CI intent)
	$(call group_start,quality)
	$(call step,✅ CI-parity quality gate)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q spotlessCheck clean check
	$(call group_end)

test-ci: ## CI: Run CI-equivalent test suite locally
	$(call group_start,test-ci)
	$(call step,🧪 CI-like test run)
	$(call info,Running Gradle…)
	@./gradlew --no-daemon -q clean test
	$(call group_end)

bootstrap: env-init hooks exec-bits quality ## 🚀 Install env + hooks + run full local quality gate
	$(call step,🚀 bootstrap complete)
	@printf "%b\n" "$(GREEN)✅ bootstrap complete$(RESET)"

# -------------------------------------------------------------------
# DOCKER / DB
# -------------------------------------------------------------------

docker-volume: ## 🐳 List local Docker volumes (postgres-focused)
	$(call step,🐳 Listing postgres volumes)
	@docker volume ls | grep -i postgres || true

docker-up: ## 🐳 Start local Docker Compose services
	$(call step,🐳 Starting Docker Compose)
	@docker compose up -d

docker-down: ## 🐳 Stop local Docker Compose services
	$(call step,🐳 Stopping Docker Compose)
	@docker compose down

docker-reset: ## 🧨 Reset local Docker environment (containers + volumes)
	$(call step,🧨 Resetting Docker (containers + volumes))
	@printf "%b\n" "$(YELLOW)⚠️  This will delete volumes.$(RESET)"
	@docker compose down -v
	@docker compose up -d

db-shell: ## 🐘 Open a psql shell in the postgres container
	$(call step,🐘 Opening psql shell)
	@docker compose exec postgres psql -U $${POSTGRES_USER:-trainer} -d $${POSTGRES_DB:-trainer}

# -------------------------------------------------------------------
# act — Local GitHub Actions simulation
# -------------------------------------------------------------------

act: run-ci ## 🧪 Alias: run one workflow via act

act-all: ## 🧪 Run ALL workflows via act (auto-discovered)
	$(call section,🧪  act — running ALL workflows)
	@for wf in $(ACT_WORKFLOWS); do \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)workflow$(RESET)=$$wf"; \
	  $(MAKE) run-ci $$wf || exit $$?; \
	done

act-all-ci: ## 🧪 Run CI-only workflows via act (skips image workflows)
	$(call section,🧪  act — running CI-only workflows)
	@for wf in $(ACT_CI_WORKFLOWS); do \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)workflow$(RESET)=$$wf"; \
	  $(MAKE) run-ci $$wf || exit $$?; \
	done

run-ci: ## 🧪 Run workflow/job via act (auto-detect event)
	$(call group_start,act)
	@if [ ! -f "$(WORKFLOW_FILE)" ]; then \
	  printf "%b\n" "$(RED)❌ Workflow not found: $(WORKFLOW_FILE)$(RESET)"; \
	  echo "👉 Try: ls .github/workflows"; \
	  exit 1; \
	fi

	@mkdir -p "$(ACT_GRADLE_CACHE_DIR_EFFECTIVE)"
	$(call step,🧪 act run)
	@printf "%b\n" "$(GRAY)wf=$(WORKFLOW) job=$(JOB) file=$(WORKFLOW_FILE)$(RESET)"
	@printf "%b\n" "$(GRAY)img=$(ACT_IMAGE) arch=$(ACT_PLATFORM) sock=$(ACT_DOCKER_SOCK) cache=$(ACT_GRADLE_CACHE_DIR_EFFECTIVE)$(RESET)"

	@events="push pull_request workflow_dispatch"; \
	if [ -n "$(JOB)" ]; then events="workflow_dispatch push pull_request"; fi; \
	for ev in $$events; do \
	  printf "%b\n" "$(GRAY)↳ trying event=$$ev$(RESET)"; \
	  tmp="$$(mktemp)"; \
	  set +e; \
	  ACT=true $(ACT) $$ev \
	    -W $(WORKFLOW_FILE) \
	    $(if $(JOB),-j $(JOB),) \
	    -P ubuntu-latest=$(ACT_IMAGE) \
	    --container-daemon-socket $(ACT_DOCKER_SOCK) \
	    --container-architecture $(ACT_PLATFORM) \
	    --container-options "--user 0:0 $(ACT_CONTAINER_OPTS)" \
	    2>&1 | tee "$$tmp"; \
	  status="$$?"; \
	  set -e; \
	  if ! grep -q "Could not find any stages to run" "$$tmp"; then \
	    rm -f "$$tmp"; \
	    exit "$$status"; \
	  fi; \
	  rm -f "$$tmp"; \
	done; \
	printf "%b\n" "$(RED)❌ No runnable jobs found for workflow=$(WORKFLOW)$(RESET)"; \
	printf "%b\n" "$(GRAY)Tip: run: $(ACT) -W $(WORKFLOW_FILE) --list$(RESET)"; \
	exit 1
	$(call group_end)

list-ci: ## 📋 List jobs for a workflow via act
	$(call step,📋 Listing act jobs)
	@$(ACT) -W $(WORKFLOW_FILE) --list

# Swallow extra args ONLY for targets that accept positionals
.PHONY: $(ARGS)
$(ARGS):
	@:

# -------------------------------------------------------------------
# Helm / Deploy (prep-only)
# -------------------------------------------------------------------

helm: ## 🧰 Helm is prep-only (ADR-009)
	$(call step,🧰 Helm (prep-only))
	@printf "%b\n" "$(CYAN)Helm$(RESET) is prep-only $(GRAY)(ADR-009)$(RESET)."
	@echo "See: docs/onboarding/HELM.md"

deploy: ## 🚧 Deploy is not wired yet
	$(call step,🚧 Deploy (not wired))
	@printf "%b\n" "$(YELLOW)Deploy$(RESET) is not wired yet."
	@echo "See: docs/onboarding/DEPLOY.md"
