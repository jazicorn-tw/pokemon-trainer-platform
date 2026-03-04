# -----------------------------------------------------------------------------
# 80-simulation.mk (80s — Simulation & Automation)
#
# Responsibility: Simulate CI/workflows locally (act, CI-like orchestration).
#
# Rule: Assumes runtime is ready (or explicitly calls it).
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# act — Local GitHub Actions simulation
# -------------------------------------------------------------------


# -----------------------------------------------------------------------------
# ACT RUNNER MACRO
#
# Usage:
#   $(call act_run_workflow)
#
# Expects these vars to already be set in the caller context:
#   WORKFLOW         (e.g. ci-fast)
#   WORKFLOW_FILE    (e.g. .github/workflows/ci-fast.yml)
#   JOB              (optional, can be empty)
#   ACT              (act binary, e.g. act)
#   ACT_IMAGE        (e.g. catthehacker/ubuntu:full-latest)
#   ACT_PLATFORM     (e.g. linux/amd64)
#   ACT_DOCKER_SOCK  (e.g. /var/run/docker.sock or colima sock)
#   ACT_CONTAINER_OPTS (optional extra container opts)
#   ACT_GRADLE_CACHE_DIR_EFFECTIVE (effective cache dir path)
#
# Notes:
# - Tries events in a fallback order so local + CI triggers "just work".
# - Exits on first non-"no stages" run attempt.
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# act defaults (safe for bind mounts)
# -----------------------------------------------------------------------------

# Run containers as 'runner' — the catthehacker image user (uid 1001) with a
# home directory at /home/runner and docker group membership.
# Do NOT use the macOS host uid: uid 501 is undefined in the container image,
# so $HOME resolves to '/' which breaks setup-java (/.m2 permission denied),
# Helm config writes, and Docker socket access (runner is in docker group).
# NOTE: bind-mounted cache files (.gradle-act) will be owned by uid 1001 on
# the macOS host; use 'make clean-act' or 'sudo rm -rf .gradle-act' to clean.
ACT_CONTAINER_USER ?= runner

# Optional reuse flag (set to --reuse if enabled elsewhere)
ACT_REUSE_ARG ?=

# Skip pulling images that are already present locally.
# The catthehacker image is 67 GB — pulling triggers a credential-store lookup
# (docker-credential-desktop) that is unavailable inside act's environment.
# Override with ACT_PULL_ARG=--pull to force a fresh pull.
ACT_PULL_ARG ?= --pull=false

define act_run_workflow
	$(call group_start,act)

	@if [ ! -f "$(WORKFLOW_FILE)" ]; then \
	  printf "%b\n" "$(RED)❌ Workflow not found: $(WORKFLOW_FILE)$(RESET)"; \
	  echo "👉 Try: ls .github/workflows"; \
	  exit 1; \
	fi

	@if ! docker -H "unix://$(ACT_DOCKER_SOCK)" info >/dev/null 2>&1; then \
	  printf "%b\n" "$(RED)❌ Docker daemon not reachable at $(ACT_DOCKER_SOCK).$(RESET)"; \
	  printf "%b\n" "$(GRAY)Start it with: make env-up$(RESET)"; \
	  exit 1; \
	fi

	@# Clear any stale configuration-cache entries left by local ./gradlew runs.
	@# The configuration cache is disabled inside act containers via JAVA_TOOL_OPTIONS
	@# (org.gradle.configuration-cache=false) because virtiofs does not support chmod,
	@# causing Gradle to fail with "could not set file mode 600" for every new entry.
	@# This cleanup prevents stale local entries from cluttering the project directory.
	@rm -rf "$(CURDIR)/.gradle/configuration-cache" 2>/dev/null || true

	@# Preflight: ensure required local files exist for act runs (.vars, .env, ~/.actrc).
	@REQUIRE_ACT_VARS=1 ./scripts/check/check-required-files.sh >/dev/null

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
	  DOCKER_HOST="unix://$(ACT_DOCKER_SOCK)" REQUIRE_ACT_VARS=1 ACT=true $(ACT) $$ev \
	    --bind \
	    $(ACT_PULL_ARG) \
	    $(ACT_REUSE_ARG) \
	    -W $(WORKFLOW_FILE) \
	    $(if $(JOB),-j $(JOB),) \
	    -P ubuntu-latest=$(ACT_IMAGE) \
	    --container-daemon-socket "unix://$(ACT_CONTAINER_DAEMON_SOCKET)" \
	    --container-architecture $(ACT_PLATFORM) \
	    --container-options "--user $(ACT_CONTAINER_USER) $(ACT_CONTAINER_OPTS)" \
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
endef

.PHONY: act act-all act-all-ci run-ci list-ci 

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
	$(call act_run_workflow)

run-ci-clean: clean-local ## Cleans Gradle Cache & 🧪 Run workflow/job via act (auto-detect event)
	$(call act_run_workflow)

list-ci: ## 📋 List jobs for a workflow via act
	$(call step,📋 Listing act jobs)
	@$(ACT) -W $(WORKFLOW_FILE) --list

# Swallow extra args ONLY for targets that accept positionals
POSITIONAL_TARGETS := run-ci list-ci

ifneq (,$(filter $(POSITIONAL_TARGETS),$(firstword $(MAKECMDGOALS))))
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
.PHONY: $(ARGS)
$(ARGS): ; @:
endif
