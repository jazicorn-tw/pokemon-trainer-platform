# Top-level Makefile (loader)
# This file is intentionally small and stable.
#
# It loads the real implementation from ./make/*.mk

MAKE_DIR := make

include $(MAKE_DIR)/00-core.mk
include $(MAKE_DIR)/10-style.mk
include $(MAKE_DIR)/20-config.mk
include $(MAKE_DIR)/30-help.mk
include $(MAKE_DIR)/40-env.mk
include $(MAKE_DIR)/50-util.mk
include $(MAKE_DIR)/60-quality.mk
include $(MAKE_DIR)/70-docker.mk
include $(MAKE_DIR)/80-act.mk
include $(MAKE_DIR)/90-helm.mk
