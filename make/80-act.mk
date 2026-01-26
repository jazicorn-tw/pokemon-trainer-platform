# -------------------------------------------------------------------
# act — Local GitHub Actions simulation
# -------------------------------------------------------------------

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
POSITIONAL_TARGETS := run-ci list-ci

ifneq (,$(filter $(POSITIONAL_TARGETS),$(firstword $(MAKECMDGOALS))))
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
.PHONY: $(ARGS)
$(ARGS): ; @:
endif
