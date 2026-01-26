# Top-level Makefile (loader)
MAKE_DIR := make

# Load foundations first (order matters)
include $(MAKE_DIR)/00-core.mk
include $(MAKE_DIR)/10-style.mk
include $(MAKE_DIR)/20-config.mk

# Auto-include everything else in make/ (including 31-help-categories.mk)
MK_REST := $(filter-out \
  $(MAKE_DIR)/00-core.mk \
  $(MAKE_DIR)/10-style.mk \
  $(MAKE_DIR)/20-config.mk, \
  $(sort $(wildcard $(MAKE_DIR)/*.mk)) \
)

-include $(MK_REST)
