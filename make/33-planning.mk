# -----------------------------------------------------------------------------
# 33-planning.mk (30s — Interface)
#
# Responsibility: Planning workflow entrypoints.
# - Open IDEAS/TODO quickly
# - Lint planning files (local + CI)
# - Weekly reminder helper (manual)
#
# Rule: No side effects (no git writes). Safe to run anytime.
# -----------------------------------------------------------------------------

.PHONY: ideas todo planning planning-lint planning-weekly

EDITOR ?= code

LOCAL_SETTINGS ?= .config/local-settings.json
JSON_GET ?= scripts/config/json-get.sh

# Pull defaults from local settings, but remain overrideable at call time:
#   make planning-lint PLANNING_DIR=docs/other
PLANNING_DIR ?= $(shell $(JSON_GET) $(LOCAL_SETTINGS) planning.dir docs/planning)

IDEAS_BASENAME ?= $(shell $(JSON_GET) $(LOCAL_SETTINGS) planning.ideas IDEAS.md)
TODO_BASENAME ?= $(shell $(JSON_GET) $(LOCAL_SETTINGS) planning.todo TODO.md)
CHECKLIST_BASENAME ?= $(shell $(JSON_GET) $(LOCAL_SETTINGS) planning.checklist PROMOTION_CHECKLIST.md)

IDEAS_FILE ?= $(PLANNING_DIR)/$(IDEAS_BASENAME)
TODO_FILE ?= $(PLANNING_DIR)/$(TODO_BASENAME)
PROMOTION_CHECKLIST_FILE ?= $(PLANNING_DIR)/$(CHECKLIST_BASENAME)

PLANNING_LINT ?= scripts/planning/planning-lint.sh


ideas: ## 💡 Open IDEAS.md
	@${EDITOR} $(IDEAS_FILE)

todo: ## ✅ Open TODO.md
	@${EDITOR} $(TODO_FILE)

planning: ## 🧠 Open IDEAS + TODO side by side
	@${EDITOR} $(IDEAS_FILE) $(TODO_FILE)

planning-lint: ## 🧼 Lint IDEAS/TODO/CHECKLIST for common anti-patterns
	@IDEAS_FILE="$(IDEAS_FILE)" TODO_FILE="$(TODO_FILE)" CHECKLIST_FILE="$(PROMOTION_CHECKLIST_FILE)" \
	  bash $(PLANNING_LINT)

planning-weekly: ## 🗓️ Weekly planning ritual reminder (manual helper)
	@echo ""
	@echo "🗓️ Weekly planning (10 minutes)"
	@echo "  1) make planning           → open IDEAS + TODO"
	@echo "  2) Prune IDEAS: promote 0–2, reject at least 1"
	@echo "  3) Tighten TODO: split big tasks, add acceptance criteria"
	@echo "  4) Run: make planning-lint"
	@echo ""
	@echo "Tip: if a new scope appears during coding, capture it:"
	@echo "  - speculative → IDEAS.md"
	@echo "  - committed   → TODO.md"
	@echo ""
