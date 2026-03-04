# -----------------------------------------------------------------------------
# 60-verification.mk (60s — Build & Verification)
#
# Responsibility: Prove code correctness.
# - format/lint/tests/static analysis/coverage
#
# Rule: Deterministic. Do not mutate machine state.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# QUALITY / TESTS / BOOTSTRAP
# -------------------------------------------------------------------

.PHONY: pre-commit format lint lint-docs test verify quality test-ci bootstrap bootstrap-act

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
	@$(GRADLE) --no-configuration-cache spotlessApply
	$(call group_end)

lint: lint-docs ## 🔎 Static analysis + markdown lint (fast-ish)
	$(call group_start,lint)
	$(call step,🔎 Static analysis)
	$(call info,Running Gradle…)
	@$(GRADLE) --no-configuration-cache checkstyleMain checkstyleTest pmdMain pmdTest spotbugsMain spotbugsTest
	$(call group_end)

lint-docs: ## 📝 Lint all markdown files (markdownlint-cli2)
	$(call group_start,lint-docs)
	$(call step,📝 markdownlint)
	@./node_modules/.bin/markdownlint-cli2 '**/*.md' '#node_modules'
	$(call group_end)

test: ## 🧪 Unit tests
	$(call group_start,test)
	$(call step,🧪 Unit tests)
	$(call info,Running Gradle…)
	@$(GRADLE) test
	$(call group_end)

verify: doctor lint test ## ✅ Doctor + lint + test
	@printf "%b\n" "$(GREEN)✅ verify complete$(RESET)"

quality: doctor ## ✅ Doctor + spotlessCheck + clean check (matches CI intent)
	$(call group_start,quality)
	$(call step,✅ CI-parity quality gate)
	$(call info,Running Gradle…)
	@$(GRADLE) spotlessCheck clean check
	$(call group_end)

test-ci: ## CI: Run CI-equivalent test suite locally
	$(call group_start,test-ci)
	$(call step,🧪 CI-like test run)
	$(call info,Running Gradle…)
	@$(GRADLE) clean test
	$(call group_end)

bootstrap: env-init hooks exec-bits quality ## 🚀 Install env + hooks + run full local quality gate
	$(call step,🚀 bootstrap complete)
	@printf "%b\n" "$(GREEN)✅ bootstrap complete$(RESET)"

bootstrap-act: env-init-act check-env-act hooks exec-bits ## 🧪 Install act env + hooks (enables local CI simulation)
	$(call step,🧪 bootstrap-act complete)
	@printf "%b\n" "$(GREEN)✅ bootstrap-act complete$(RESET)"
	@printf "%b\n" "$(GRAY)Next: make run-ci (or make act-all)$(RESET)"
