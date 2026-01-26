# -----------------------------------------------------------------------------
# 81-tree.mk
#
# Repo structure inspection helpers (read-only)
#
# Purpose:
# - Fast mental model of the repository
# - Developer navigation and discovery
#
# Non-goals:
# - No mutation
# - No verification
# - No delivery
# -----------------------------------------------------------------------------

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# -----------------------------
# Config (override as needed)
# -----------------------------

TREE_DEPTH ?= 3
TREE_IGNORE ?= .git|node_modules|.gradle|build|target|dist|out|coverage|.idea|.vscode
TREE_FLAGS  ?= --dirsfirst

# -----------------------------
# Internal helpers
# -----------------------------

define require_tree
	@command -v tree >/dev/null 2>&1 || { 	  echo "❌ 'tree' is not installed."; 	  echo "👉 macOS:  brew install tree"; 	  echo "👉 Ubuntu: sudo apt-get install -y tree"; 	  exit 1; 	}
endef

# -----------------------------
# Public targets
# -----------------------------

.PHONY: tree

# Usage:
#   make tree <path>
#   make tree
#
# Example:
#   make tree docs
#   → shows the immediate folders/files inside ./docs
#
# Behavior:
#   - Lists the directory structure for <path>
#   - Defaults to the repo root (.) if no path is provided
#   - Shows ONE level deep by default (shallow inspection)
#   - Output is read-only; no files are modified
#
# Customization:
#   - Override depth explicitly:
#       make tree docs TREE_DEPTH=4
#
#   - Ignore additional paths:
#       make tree src TREE_IGNORE=".git|node_modules|build"
#
# Notes:
#   - Requires `tree` to be installed locally
#   - Extra arguments are treated as the target path (via MAKECMDGOALS)
#
# Documentation:
#   See docs/tooling/TREE.md for full rationale, examples, and design intent.

tree:
	$(call require_tree)
	@set -- $(filter-out $@,$(MAKECMDGOALS)); \
	if [ "$$#" -eq 0 ]; then \
	  path="."; \
	else \
	  path="$$1"; \
	fi; \
	if [ ! -e "$$path" ]; then \
	  echo "❌ Path not found: $$path"; \
	  exit 1; \
	fi; \
	depth="$${TREE_DEPTH:-1}"; \
	tree $(TREE_FLAGS) -L "$$depth" -I "$(TREE_IGNORE)" "$$path"

# Swallow extra args so `make tree docs` doesn't error
%:
	@:
