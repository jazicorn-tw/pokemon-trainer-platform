# -----------------------------------------------------------------------------
# 50-library.mk (50s — Library)
#
# Responsibility: Shared helper macros and utilities.
#
# Rule: Prefer helpers over user-facing targets.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# CONFIG / UTIL
# -------------------------------------------------------------------

.PHONY: local-settings exec-bits hooks \
		doctor doctor-json doctor-json-strict doctor-json-pretty \
		clean clean-all

# -------------------------------------------------------------------
# EXEC BIT GUARDS (DX) — context-aware + polished
# -------------------------------------------------------------------

# copy_idempotent dest_label src_example dest_path missing_msg [post_copy_cmd]
# Non-destructive: skips if dest already exists; increments $$changed if copied.
define copy_idempotent
	@if [[ -f "$(3)" ]]; then \
	  printf "%b\n" "$(GRAY)$(1) already exists (skipping)$(RESET)"; \
	elif [[ -f "$(2)" ]]; then \
	  cp "$(2)" "$(3)"; \
	  $(if $(5),$(5);) \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created $(1) from $(2)$(RESET)"; \
	  changed=$$((changed + 1)); \
	else \
	  printf "%b\n" "$(YELLOW)Missing $(2) — $(4)$(RESET)"; \
	fi
endef

# copy_force dest_label src_example dest_path [post_copy_cmd]
# Destructive: overwrites dest from src example if src exists.
define copy_force
	@if [[ -f "$(2)" ]]; then \
	  cp "$(2)" "$(3)"; \
	  $(if $(4),$(4);) \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote $(1) from $(2)$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing $(2) — cannot overwrite $(1)$(RESET)"; \
	fi
endef

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
	$(call require_exec,./scripts/inspect/inspect-local-settings.sh)
	@./scripts/inspect/inspect-local-settings.sh

exec-bits: ## 🔧 Check & (optionally) auto-fix executable bits for tracked scripts
	$(call require_exec,./scripts/check/check-executable-bits.sh)
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check/check-executable-bits.sh

hooks: ## 🪝 Configure repo-local git hooks
	$(call require_exec,./scripts/bootstrap/install-hooks.sh)
	@./scripts/bootstrap/install-hooks.sh

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
	@$(GRADLE) clean

clean-all: ## 🧹 Clean build + purge local caches (use sparingly)
	$(call step,🧹 Clean + purge local caches)
	$(call info,Running Gradle…)
	@$(GRADLE) clean
	@rm -rf .gradle build
