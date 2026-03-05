# -----------------------------------------------------------------------------
# 54-inspect.mk
#
# Responsibility: Makefile introspection & discoverability.
#
# This file exposes a small, discoverable Make interface and delegates
# all heavy inspection logic to scripts under scripts/inspect/.
#
# Scripts:
# - scripts/inspect/make/make-router.sh        (router + single-file inspector)
# - scripts/inspect/make/make-list.sh          (no-arg: list make modules)
# - scripts/inspect/make/make-all.sh           (inspect all modules)
# - scripts/inspect/make/make-decade-all.sh    (inspect all modules in a decade)
#
# Design:
# - Read-only / no side effects
# - Make = orchestration, scripts = logic
# - Ordering contract matches: `ls -1 make | sort`
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Configuration (defaults)
# -------------------------------------------------------------------
# Override per-run:
#   make inspect-mk
#   make inspect-mk 50
#   make inspect-mk FLAG=a
#   make inspect-mk 50 FLAG=a
#   make inspect-mk FILE=make/70-runtime.mk
#   make inspect-mk FILE=make/70-runtime.mk FLAG=a
#
# Notes:
# - Use FLAG=a (NOT -a). `-a` is a Make option and will be intercepted by make.
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Script paths (overrideable)
# -------------------------------------------------------------------
PATH_INSPECT              ?= ./scripts/inspect/make/make-router.sh
PATH_INSPECT_LIST_MODULES ?= ./scripts/inspect/make/make-list.sh
PATH_INSPECT_ALL          ?= ./scripts/inspect/make/make-all.sh
PATH_INSPECT_DECADE_ALL   ?= ./scripts/inspect/make/make-decade-all.sh

.PHONY: inspect-mk

inspect-mk: ## Inspect make modules (use FLAG=a for "all")
	@EXTRA="$(filter-out inspect-mk,$(MAKECMDGOALS))" \
	FILE="$(FILE)" \
	FLAG="$(FLAG)" \
	PATH_INSPECT_LIST_MODULES="$(PATH_INSPECT_LIST_MODULES)" \
	PATH_INSPECT_ALL="$(PATH_INSPECT_ALL)" \
	PATH_INSPECT_DECADE_ALL="$(PATH_INSPECT_DECADE_ALL)" \
	bash "$(PATH_INSPECT)"
