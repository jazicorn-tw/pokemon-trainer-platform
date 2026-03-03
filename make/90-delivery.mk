# -----------------------------------------------------------------------------
# 90-delivery.mk (90s — Delivery)
#
# Responsibility: Packaging and delivery tooling (helm, release packaging).
#
# Rule: High consequence. Require explicit intent and strong guards.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Release
# -------------------------------------------------------------------

.PHONY: release-dry-run

release-dry-run: ## 🔍 Preview next semantic-release version (dry-run, no publish)
	$(call step,🔍 semantic-release dry-run)
	@npx semantic-release --dry-run

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

# unwired_guard step_label target_name docs_path
# Guards scaffold-only publish targets. Fails unless ALLOW_UNWIRED_PUBLISH=1.
define unwired_guard
	$(call step,$(1))
	@printf "%b\n" "$(YELLOW)$(2)$(RESET) is not wired yet."
	@echo "See: $(3)"
	@if [ "$(ALLOW_UNWIRED_PUBLISH)" != "1" ]; then \
	  printf "%b\n" "$(RED)❌ Refusing to publish: $(2) is scaffold-only.$(RESET)"; \
	  echo "👉 Set ALLOW_UNWIRED_PUBLISH=1 to bypass while wiring (NOT recommended long-term)."; \
	  exit 1; \
	fi
	@echo "✅ Bypass enabled (ALLOW_UNWIRED_PUBLISH=1). No-op."
endef

docker-publish: ## 🐳 Publish Docker image (guarded; not wired yet)
	$(call unwired_guard,🐳 Docker publish,docker-publish,docs/onboarding/DOCKER_PUBLISH.md)

helm-publish: ## ⎈ Publish Helm chart (guarded; not wired yet)
	$(call unwired_guard,⎈ Helm publish,helm-publish,docs/onboarding/HELM_PUBLISH.md)
