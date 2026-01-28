# -----------------------------------------------------------------------------
# 90-delivery.mk (90s — Delivery)
#
# Responsibility: Packaging and delivery tooling (helm, release packaging).
#
# Rule: High consequence. Require explicit intent and strong guards.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Helm / Deploy (prep-only)
# -------------------------------------------------------------------

.PHONY: helm deploy docker-publish helm-publish

helm: ## 🧰 Helm is prep-only (ADR-009)
	$(call step,🧰 Helm (prep-only))
	@printf "%b\n" "$(CYAN)Helm$(RESET) is prep-only $(GRAY)(ADR-009)$(RESET)."
	@echo "See: docs/onboarding/HELM.md"

deploy: ## 🚧 Deploy is not wired yet
	$(call step,🚧 Deploy (not wired))
	@printf "%b\n" "$(YELLOW)Deploy$(RESET) is not wired yet."
	@echo "See: docs/onboarding/DEPLOY.md"

# -------------------------------------------------------------------
# CI publish hooks (called by GitHub Actions) — intentionally guarded
# -------------------------------------------------------------------
#
# The release workflow calls these targets only when the corresponding
# repo variables are enabled:
# - PUBLISH_DOCKER_IMAGE=true  -> make docker-publish
# - PUBLISH_HELM_CHART=true    -> make helm-publish
#
# Until these are implemented, they FAIL by default to avoid "silent" publishes
# or false confidence. When you are ready to wire publishing, replace the body
# with the real implementation (or delegate to scripts).
#
# To intentionally bypass the guard (e.g., while scaffolding in CI), you can set:
#   ALLOW_UNWIRED_PUBLISH=1
#
# Recommended future wiring:
# - docker-publish -> scripts/release/publish-docker.sh (or docker/build-push-action in workflow)
# - helm-publish   -> scripts/release/publish-helm.sh (OCI to GHCR)
# -------------------------------------------------------------------

ALLOW_UNWIRED_PUBLISH ?= 0

docker-publish: ## 🐳 Publish Docker image (guarded; not wired yet)
	$(call step,🐳 Docker publish)
	@printf "%b\n" "$(YELLOW)docker-publish$(RESET) is not wired yet."
	@echo "See: docs/onboarding/DOCKER_PUBLISH.md"
	@if [ "$(ALLOW_UNWIRED_PUBLISH)" != "1" ]; then \
	  printf "%b\n" "$(RED)❌ Refusing to publish: docker-publish is scaffold-only.$(RESET)"; \
	  echo "👉 Set ALLOW_UNWIRED_PUBLISH=1 to bypass while wiring (NOT recommended long-term)."; \
	  exit 1; \
	fi
	@echo "✅ Bypass enabled (ALLOW_UNWIRED_PUBLISH=1). No-op."

helm-publish: ## ⎈ Publish Helm chart (guarded; not wired yet)
	$(call step,⎈ Helm publish)
	@printf "%b\n" "$(YELLOW)helm-publish$(RESET) is not wired yet."
	@echo "See: docs/onboarding/HELM_PUBLISH.md"
	@if [ "$(ALLOW_UNWIRED_PUBLISH)" != "1" ]; then \
	  printf "%b\n" "$(RED)❌ Refusing to publish: helm-publish is scaffold-only.$(RESET)"; \
	  echo "👉 Set ALLOW_UNWIRED_PUBLISH=1 to bypass while wiring (NOT recommended long-term)."; \
	  exit 1; \
	fi
	@echo "✅ Bypass enabled (ALLOW_UNWIRED_PUBLISH=1). No-op."
