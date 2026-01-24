# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

.DEFAULT_GOAL := help

# --- Developer settings ---
LOCAL_SETTINGS ?= .config/local-settings.json

# --- act (local GitHub Actions) ---
ACT ?= act
ACT_IMAGE ?= catthehacker/ubuntu:full-latest
ACT_PLATFORM ?= linux/amd64
ACT_DOCKER_SOCK ?= /var/run/docker.sock

# Capture positional args after the target name (for run-ci/list-ci)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
WORKFLOW_ARG := $(word 1,$(ARGS))
JOB := $(word 2,$(ARGS))
WORKFLOW := $(if $(WORKFLOW_ARG),$(WORKFLOW_ARG),ci-test)
WORKFLOW_FILE := .github/workflows/$(WORKFLOW).yml

.PHONY: \
  help \
  help-ci \
  explain \
  local-settings \
  exec-bits \
  hooks \
  doctor \
  clean \
  clean-all \
  format \
  lint \
  quality \
  test \
  verify \
  test-ci \
  bootstrap \
  docker-volume \
  docker-up \
  docker-down \
  docker-reset \
  db-shell \
  act \
  run-ci \
  list-ci \
  helm \
  deploy

# -------------------------------------------------------------------
# HELP / DOCS
#
# Docs format:
#   target: deps ## 🧪 Description here
#   target: deps ## CI: Description here
# -------------------------------------------------------------------

help: ## 🧰 Show developer help (grouped)
	@echo ""
	@echo "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo "\033[1;36m🧰  Pokémon Trainer Platform — Make Targets\033[0m"
	@echo "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo ""
	@echo "\033[1;33m🚀 Recommended flow\033[0m"
	@echo "  \033[1mmake bootstrap\033[0m   → first-time setup"
	@echo "  \033[1mmake verify\033[0m      → before pushing"
	@echo "  \033[1mmake run-ci\033[0m      → simulate CI locally (act)"
	@echo ""
	@echo "\033[1;33m🧪 Quality gates\033[0m"
	@echo "  make doctor        - Local environment sanity checks"
	@echo "  make lint          - Static analysis only (fast-ish)"
	@echo "  make test          - Unit tests"
	@echo "  make verify        - Doctor + lint + test (good before pushing)"
	@echo "  make quality       - Doctor + format + clean check (matches CI intent)"
	@echo ""
	@echo "\033[1;33m🐳 Docker / DB\033[0m"
	@echo "  make docker-up     - Start local Docker Compose services"
	@echo "  make docker-down   - Stop local Docker Compose services"
	@echo "  make docker-reset  - Stop services + delete volumes + restart"
	@echo "  make db-shell      - psql shell into local postgres container"
	@echo ""
	@echo "\033[1;33m🧪 act (local GitHub Actions)\033[0m"
	@echo "  make run-ci [wf] [job] - Run workflow/job via act (defaults to wf=ci)"
	@echo "  make list-ci [wf]      - List jobs for workflow via act"
	@echo "  make act               - Alias of: make run-ci"
	@echo ""
	@echo "\033[1;33m📦 Helm / Deploy (prep-only)\033[0m"
	@echo "  make helm          - Helm is prep-only (ADR-009) → docs/onboarding/HELM.md"
	@echo "  make deploy        - Deploy is not wired yet → docs/onboarding/DEPLOY.md"
	@echo ""

help-ci: ## 🧰 Show only CI-relevant targets
	@echo ""
	@echo "CI: verify, quality, test-ci, run-ci, list-ci"
	@echo ""

explain: ## 🧠 Explain a target: make explain <target>
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
	  echo "❌ Usage: make explain <target>"; exit 1; \
	fi
	@t="$(word 2,$(MAKECMDGOALS))"; \
	case "$$t" in \
	  doctor)  echo "doctor: runs local sanity checks (java/gradle/docker/colima/socket)";; \
	  verify)  echo "verify: doctor + lint + test (recommended before pushing)";; \
	  quality) echo "quality: doctor + spotlessCheck + clean + check (matches CI intent)";; \
	  run-ci)  echo "run-ci: run GitHub Actions workflows locally via act (wf defaults to ci; optional job)";; \
	  *) echo "No extended explanation available for '$$t' (see docs/MAKEFILE.md)";; \
	esac

# swallow extra args so make doesn't treat them as targets
%:
	@:

# -------------------------------------------------------------------
# CONFIG / UTIL
# -------------------------------------------------------------------

local-settings: ## 🧩 Print effective local settings (merged + OS aware)
	@echo "LOCAL_SETTINGS=$(LOCAL_SETTINGS)"
	@test -f "$(LOCAL_SETTINGS)" && cat "$(LOCAL_SETTINGS)" || echo "No local settings file found."

exec-bits: ## 🔧 Check & (optionally) auto-fix executable bits for tracked scripts
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check-executable-bits.sh

hooks: ## 🪝 Configure repo-local git hooks (macOS: fixes +x)
	@./scripts/install-hooks.sh

doctor: ## 🩺 Local environment sanity checks (local only)
	@./scripts/doctor.sh

clean: ## 🧹 Clean build outputs
	@./gradlew --no-daemon -q clean

clean-all: ## 🧹 Clean build + purge local caches (use sparingly)
	@./gradlew --no-daemon -q clean
	@rm -rf .gradle build

pre-commit: format verify test-ci

## ✨ Auto-format sources
format: ## ✨ Auto-format sources
	@rm -rf .gradle/configuration-cache .gradle/caches
	@./gradlew --no-daemon -q spotlessApply

lint: ## 🔎 Static analysis only (fast-ish)
	@./gradlew --no-daemon -q checkstyleMain checkstyleTest pmdMain pmdTest spotbugsMain spotbugsTest

test: ## 🧪 Unit tests
	@./gradlew --no-daemon -q test

verify: doctor lint test ## ✅ Doctor + lint + test (good before pushing)
	@echo "✅ verify complete"

# Full local quality gate (matches CI intent)
quality: doctor ## ✅ Doctor + format + clean check (matches CI intent)
	@./gradlew --no-daemon -q spotlessCheck clean check

test-ci: ## CI: Run CI-equivalent test suite locally
	@./gradlew --no-daemon -q clean test

bootstrap: hooks exec-bits quality ## 🚀 Install hooks + run full local quality gate
	@echo "✅ bootstrap complete"

# -------------------------------------------------------------------
# DOCKER / DB
# -------------------------------------------------------------------

docker-volume: ## 🐳 List local Docker volumes (postgres-focused)
	@docker volume ls | grep -i postgres || true

docker-up: ## 🐳 Start local Docker Compose services
	@docker compose up -d

docker-down: ## 🐳 Stop local Docker Compose services
	@docker compose down

docker-reset: ## 🧨 Reset local Docker environment (containers + volumes)
	@echo "⚠️  Resetting local Docker environment (containers + volumes)"
	@docker compose down -v
	@docker compose up -d

db-shell: ## 🐘 Open a psql shell in the postgres container
	@docker compose exec postgres psql -U $${POSTGRES_USER:-trainer} -d $${POSTGRES_DB:-trainer}

# -------------------------------------------------------------------
# act — Local GitHub Actions simulation
# -------------------------------------------------------------------

act: run-ci ## 🧪 Alias: run-ci

run-ci: ## 🧪 Run workflow/job via act (make run-ci [workflow] [job])
	@if [ ! -f "$(WORKFLOW_FILE)" ]; then \
	  echo "❌ Workflow not found: $(WORKFLOW_FILE)"; \
	  echo "👉 Try: ls .github/workflows"; \
	  exit 1; \
	fi
	@echo "🧪 act → workflow=$(WORKFLOW) job=$(JOB)"
	@ACT=true $(ACT) push \
		-W $(WORKFLOW_FILE) \
		$(if $(JOB),-j $(JOB),) \
		-P ubuntu-latest=$(ACT_IMAGE) \
		--container-daemon-socket $(ACT_DOCKER_SOCK) \
		--container-architecture $(ACT_PLATFORM) \
		--container-options="--user 0:0"

list-ci: ## 📋 List jobs for a workflow via act (make list-ci [workflow])
	@if [ ! -f "$(WORKFLOW_FILE)" ]; then \
	  echo "❌ Workflow not found: $(WORKFLOW_FILE)"; \
	  echo "👉 Try: ls .github/workflows"; \
	  exit 1; \
	fi
	@echo "📋 act jobs → workflow=$(WORKFLOW)"
	@$(ACT) -W $(WORKFLOW_FILE) --list

# -------------------------------------------------------------------
# Helm / Deploy (prep-only)
# -------------------------------------------------------------------

helm: ## 🧰 Helm is prep-only (ADR-009) → docs/onboarding/HELM.md
	@echo "🧰 Helm is prep-only (ADR-009)."
	@echo "See: docs/onboarding/HELM.md"

deploy: ## 🚧 Deploy is not wired yet → docs/onboarding/DEPLOY.md
	@echo "🚧 Deploy is not wired yet."
	@echo "See: docs/onboarding/DEPLOY.md"
