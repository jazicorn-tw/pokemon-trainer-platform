# -------------------------------------------------------------------
# Console styling + printing helpers + grouped logs
# -------------------------------------------------------------------

ESC := \033
RESET := $(ESC)[0m
BOLD := $(ESC)[1m
DIM := $(ESC)[2m

CYAN := $(ESC)[1;36m
YELLOW := $(ESC)[1;33m
GREEN := $(ESC)[1;32m
RED := $(ESC)[1;31m
GRAY := $(ESC)[90m

HR := $(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)
HR2 := $(CYAN)════════════════════════════════════════════════$(RESET)

# Auto-disable colors when stdout is not a TTY (pipes / CI logs)
ifneq ($(shell test -t 1 && echo tty),tty)
NO_COLOR := 1
endif

# Respect NO_COLOR=1
ifeq ($(NO_COLOR),1)
RESET :=
BOLD :=
DIM :=
CYAN :=
YELLOW :=
GREEN :=
RED :=
GRAY :=
HR := ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HR2 := ════════════════════════════════════════════════
endif

# -------------------------------------------------------------------
# Printing helpers (portable; printf interprets \033 correctly)
# -------------------------------------------------------------------

define println
	@printf "%b\n" "$1"
endef

define print
	@printf "%b" "$1"
endef

define section
	$(call println,)
	$(call println,$(HR))
	$(call println,$(CYAN)$(BOLD)$1$(RESET))
	$(call println,$(HR))
	$(call println,)
endef

# "Hero-lite" header: bigger divider, no box
define section2
	$(call println,)
	$(call println,$(HR2))
	$(call println,$(CYAN)$(BOLD)$1$(RESET))
	$(call println,$(HR2))
	$(call println,)
endef

define step
	$(call println,$(CYAN)▶$(RESET) $(BOLD)$1$(RESET))
endef

define info
	$(call println,$(GRAY)$1$(RESET))
endef

define warn
	$(call println,$(YELLOW)$1$(RESET))
endef

# =============================================================================
# GROUPED LOGGING (CI-friendly, optional locally)
#
# Behavior:
# - CI=true            → groups ENABLED (GitHub Actions compatible)
# - GROUP_LOGS=1       → groups ENABLED locally
# - default (local)    → groups DISABLED for clean console output
# =============================================================================

GROUP_LOGS ?= $(if $(CI),1,0)

ifeq ($(GROUP_LOGS),1)
define group_start
	$(call println,::group::$1)
endef
define group_end
	$(call println,::endgroup::)
endef
else
define group_start
	@:
endef
define group_end
	@:
endef
endif
