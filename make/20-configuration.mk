# -----------------------------------------------------------------------------
# 20-config.mk (20s — Configuration)
#
# Responsibility: Decide what should happen (no side effects).
# - feature flags, derived variables, CI/local toggles
#
# Rule: Safe to evaluate (make -pn) without mutating state.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Project config + act config
# -------------------------------------------------------------------

LOCAL_SETTINGS ?= .config/local-settings.json

# Gradle wrapper shorthand (shared by all targets that invoke Gradle)
GRADLE ?= ./gradlew --no-daemon -q

# -------------------------------------------------------------------
# act workflow discovery
# -------------------------------------------------------------------

AUTO_DISCOVERED_WORKFLOWS := $(sort $(basename $(notdir $(wildcard .github/workflows/*.yml .github/workflows/*.yaml))))

# Workflows that use `workflow_run` or other events act cannot simulate.
# Excluded from both act-all and act-all-ci.
ACT_UNSUPPORTED_WORKFLOWS ?= ci-failure-comment

IMAGE_WORKFLOWS ?= image-build image-publish
CI_WORKFLOWS ?= $(filter-out $(IMAGE_WORKFLOWS) $(ACT_UNSUPPORTED_WORKFLOWS),$(AUTO_DISCOVERED_WORKFLOWS))

# Final workflow lists used by make targets
ACT_WORKFLOWS ?= $(sort $(filter-out $(ACT_UNSUPPORTED_WORKFLOWS),$(AUTO_DISCOVERED_WORKFLOWS)))
ACT_CI_WORKFLOWS ?= $(sort $(CI_WORKFLOWS))

# --- act (local GitHub Actions) ---
ACT ?= act
ACT_IMAGE ?= catthehacker/ubuntu:full-latest
ACT_PLATFORM ?= linux/amd64

# Make's $(shell) runs with a minimal PATH (/usr/bin:/bin:/usr/sbin:/sbin) that
# excludes /opt/homebrew/bin and /usr/local/bin. Probe known locations explicitly
# so docker context inspect works on both Apple Silicon (Homebrew) and Intel Macs.
_DOCKER_BIN := $(firstword $(wildcard \
  /opt/homebrew/bin/docker \
  /usr/local/bin/docker \
  /usr/bin/docker))

_COLIMA_BIN := $(firstword $(wildcard \
  /opt/homebrew/bin/colima \
  /usr/local/bin/colima))

# Derive the Docker socket from the active context so Colima, Docker Desktop,
# and plain Docker all work without manual override.
# Override with ACT_DOCKER_SOCK=/path/to/docker.sock if needed.
#
# NOTE: This is the HOST-SIDE socket (macOS path). Used only for DOCKER_HOST so
# act can reach the daemon for its own API calls (image pulls, container create).
# It is NOT used for the container bind-mount — see ACT_CONTAINER_DAEMON_SOCKET.
ACT_DOCKER_SOCK ?= $(or \
  $(if $(_DOCKER_BIN),$(shell $(_DOCKER_BIN) context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null | sed 's|unix://||'),), \
  /var/run/docker.sock)

# Socket path to bind-mount INTO act containers (i.e. the path as seen from
# inside the Docker daemon's VM, not the macOS host).
#
# For Colima/Lima: the VM-internal Docker socket is always /var/run/docker.sock.
# ACT_DOCKER_SOCK (~/.colima/default/docker.sock) is the macOS proxy — the VM
# cannot bind-mount it (you'd get "operation not supported").
#
# For Docker Desktop: /var/run/docker.sock also works inside the VM.
# Use "-" to disable the bind-mount entirely if workflows don't need DinD.
ACT_CONTAINER_DAEMON_SOCKET ?= /var/run/docker.sock

# GID of the Docker socket inside the Colima/Docker VM.
# The runner user (uid 1001) is in the 'docker' group inside the container, but
# the VM-side socket may have a different gid than the container's docker group.
# Adding the VM socket's gid via --group-add ensures runner can access the socket
# for DinD workflows (Testcontainers, docker build, etc.).
#
# Detection order:
# 1. colima ssh — no image pull needed; reliable for Colima setups.
#    Requires PATH to include /opt/homebrew/bin so 'lima' (colima's VM backend)
#    is found. The full colima path is probed via _COLIMA_BIN above.
# 2. docker run alpine --pull=never — works when alpine is already cached.
# 3. Fall back to 999 (conventional docker gid) if detection fails.
_DOCKER_SOCK_GID := $(or \
  $(if $(_COLIMA_BIN),$(shell PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin \
    $(_COLIMA_BIN) ssh -- stat -c '%g' /var/run/docker.sock 2>/dev/null),), \
  $(if $(_DOCKER_BIN),$(shell DOCKER_HOST="unix://$(ACT_DOCKER_SOCK)" $(_DOCKER_BIN) run --rm --quiet \
    --pull=never \
    -v /var/run/docker.sock:/var/run/docker.sock \
    alpine stat -c '%g' /var/run/docker.sock 2>/dev/null),), \
  999)

# -----------------------------------------------------------------------------
# act runner tuning (Gradle cache + safer networking defaults)
# -----------------------------------------------------------------------------
ACT_GRADLE_CACHE_DIR ?=
ACT_GRADLE_CACHE_DIR_EFFECTIVE := $(or $(strip $(ACT_GRADLE_CACHE_DIR)),$(CURDIR)/.gradle-act)

# Use JAVA_TOOL_OPTIONS to avoid quoting issues inside `--container-options`
#
# org.gradle.configuration-cache=false: virtiofs (the macOS bind-mount filesystem
# used by Colima) does not support chmod from inside containers, causing Gradle to
# fail with "could not set file mode 600" when it tries to secure the cache entry.
# Disabling the configuration cache for act runs avoids all chmod activity in the
# project's .gradle/ directory.  Local ./gradlew runs still use the cache normally.
ACT_JAVA_TOOL_OPTIONS := \
  -Djava.net.preferIPv4Stack=true \
  -Dorg.gradle.internal.http.connectionTimeout=60000 \
  -Dorg.gradle.internal.http.socketTimeout=60000 \
  -Dorg.gradle.configuration-cache=false

# Use docker-short flags and single-quotes for values containing spaces
ACT_CONTAINER_OPTS ?= \
  --group-add $(_DOCKER_SOCK_GID) \
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
