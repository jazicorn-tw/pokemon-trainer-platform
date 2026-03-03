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
# CI publish hooks (called by GitHub Actions)
# -------------------------------------------------------------------
#
# Publishing is handled entirely by the release.yml publish job via
# GitHub Actions steps (docker/build-push-action, helm push to GHCR).
# These Make targets exist only to surface a clear error when called locally.
#
# To enable publishing:
# - Set PUBLISH_DOCKER_IMAGE=true as a GitHub repo variable
# - Set PUBLISH_HELM_CHART=true as a GitHub repo variable
# - Set CANONICAL_REPOSITORY=<owner>/<repo> as a GitHub repo variable
# -------------------------------------------------------------------

docker-publish: ## 🐳 Publish Docker image (CI only — release.yml publish job)
	$(call step,🐳 Docker publish)
	@printf "%b\n" "$(YELLOW)docker-publish$(RESET) runs in CI only (release.yml publish job)."
	@echo "To publish: set PUBLISH_DOCKER_IMAGE=true as a repo variable, then push a releasable commit to main."
	@exit 1

helm-publish: ## ⎈ Publish Helm chart (CI only — release.yml publish job)
	$(call step,⎈ Helm publish)
	@printf "%b\n" "$(YELLOW)helm-publish$(RESET) runs in CI only (release.yml publish job)."
	@echo "To publish: set PUBLISH_HELM_CHART=true as a repo variable, then push a releasable commit to main."
	@exit 1
