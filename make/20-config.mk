# -------------------------------------------------------------------
# Project config + act config
# -------------------------------------------------------------------

LOCAL_SETTINGS ?= .config/local-settings.json

# -------------------------------------------------------------------
# act workflow discovery
# -------------------------------------------------------------------

AUTO_DISCOVERED_WORKFLOWS := $(sort $(basename $(notdir $(wildcard .github/workflows/*.yml .github/workflows/*.yaml))))

IMAGE_WORKFLOWS ?= image-build image-publish
CI_WORKFLOWS ?= $(filter-out $(IMAGE_WORKFLOWS),$(AUTO_DISCOVERED_WORKFLOWS))

# Final workflow lists used by make targets
ACT_WORKFLOWS ?= $(sort $(AUTO_DISCOVERED_WORKFLOWS))
ACT_CI_WORKFLOWS ?= $(sort $(CI_WORKFLOWS))

# --- act (local GitHub Actions) ---
ACT ?= act
ACT_IMAGE ?= catthehacker/ubuntu:full-latest
ACT_PLATFORM ?= linux/amd64
ACT_DOCKER_SOCK ?= /var/run/docker.sock

# -----------------------------------------------------------------------------
# act runner tuning (Gradle cache + safer networking defaults)
# -----------------------------------------------------------------------------
ACT_GRADLE_CACHE_DIR ?=
ACT_GRADLE_CACHE_DIR_EFFECTIVE := $(or $(strip $(ACT_GRADLE_CACHE_DIR)),$(CURDIR)/.gradle-act)

# Use JAVA_TOOL_OPTIONS to avoid quoting issues inside `--container-options`
ACT_JAVA_TOOL_OPTIONS := \
  -Djava.net.preferIPv4Stack=true \
  -Dorg.gradle.internal.http.connectionTimeout=60000 \
  -Dorg.gradle.internal.http.socketTimeout=60000

# Use docker-short flags and single-quotes for values containing spaces
ACT_CONTAINER_OPTS ?= \
  -e JAVA_TOOL_OPTIONS='$(ACT_JAVA_TOOL_OPTIONS)' \
  -e GRADLE_USER_HOME=/tmp/gradle \
  -v $(ACT_GRADLE_CACHE_DIR_EFFECTIVE):/tmp/gradle

WORKFLOW_ARG := $(word 1,$(ARGS))
JOB := $(word 2,$(ARGS))
WORKFLOW := $(if $(WORKFLOW_ARG),$(WORKFLOW_ARG),ci-test)

# Support either .yml or .yaml workflow files (prefers .yml if present)
WORKFLOW_FILE_YML := .github/workflows/$(WORKFLOW).yml
WORKFLOW_FILE_YAML := .github/workflows/$(WORKFLOW).yaml
WORKFLOW_FILE := $(if $(wildcard $(WORKFLOW_FILE_YML)),$(WORKFLOW_FILE_YML),$(WORKFLOW_FILE_YAML))
