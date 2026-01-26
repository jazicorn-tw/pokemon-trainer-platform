# -------------------------------------------------------------------
# CONFIG / UTIL
# -------------------------------------------------------------------

.PHONY: local-settings exec-bits hooks doctor doctor-json doctor-json-strict doctor-json-pretty clean clean-all list-make-files check-make-order

# -------------------------------------------------------------------
# EXEC BIT GUARDS (DX) — context-aware + polished
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

list-make-files: ## 📂 List all Make modules (sorted)
	@ls -1 make | sort

check-make-order: ## 🔢 Verify make/ modules use numeric prefixes (00-, 10-, etc.)
	@bad=0; \
	for f in make/*.mk; do \
	  base="$$(basename "$$f")"; \
	  if ! echo "$$base" | grep -Eq '^[0-9]{2}-.*\.mk$$'; then \
	    printf "%b\n" "$(RED)❌ Invalid make module name: $$base$(RESET)"; \
	    bad=1; \
	  fi; \
	done; \
	if [ "$$bad" -eq 1 ]; then \
	  printf "%b\n" "$(GRAY)Expected format: NN-name.mk (e.g. 00-core.mk, 31-help-categories.mk)$(RESET)"; \
	  exit 1; \
	else \
	  printf "%b\n" "$(GREEN)✅ All make modules use numeric prefixes$(RESET)"; \
	fi
