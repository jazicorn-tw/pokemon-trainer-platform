# -------------------------------------------------------------------
# Core Make settings
# -------------------------------------------------------------------

# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

.DEFAULT_GOAL := help

# Capture positional args after the target name (for run-ci/list-ci/explain)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Detect current git branch (Phase 0)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
