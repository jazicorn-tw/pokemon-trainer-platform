# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash

# --- Developer settings ---
LOCAL_SETTINGS ?= .config/local-settings.json

.PHONY: \
  help \
  local-settings \
  exec-bits \
  hooks \
  doctor \
  clean \
  clean-all \
  format \
  lint \
  quality \
  test \
  verify \
  test-ci \
  bootstrap \
  docker-volume \
  docker-up \
  docker-down \
  docker-reset \
  db-shell

help:
	@echo ""
	@echo "🧰 Make targets"
	@echo "  make doctor        - Local environment sanity checks (local only)"
	@echo "  make lint          - Static analysis only (fast-ish)"
	@echo "  make test          - Unit tests"
	@echo "  make verify        - Doctor + lint + test (good before pushing)"
	@echo "  make quality       - Doctor + format + clean check (matches CI intent)"
	@echo "  make bootstrap     - Install hooks + run full local quality gate"
	@echo "  make hooks         - Configure repo-local git hooks (macOS: fixes +x)"
	@echo "  make exec-bits     - Check & auto-fix executable bits for tracked scripts"
	@echo "  make local-settings  - Print effective local settings (merged + OS override)"
	@echo "  make clean         - Clean build outputs only (Gradle clean)"
	@echo "  make clean-all     - Full local reset (removes .gradle state + clean)"
	@echo ""

hooks:
	@bash ./scripts/bootstrap-macos.sh
	@bash ./scripts/install-hooks.sh

## Print effective local settings (merged base + OS override)
local-settings:
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check-executable-bits.sh --print-config

## Check (and possibly auto-fix) executable bits for tracked scripts/hooks
exec-bits:
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check-executable-bits.sh

# Clean build outputs only.
# Fast, safe, and equivalent to Gradle's standard clean.
clean:
	@./gradlew --no-daemon clean

# Full local reset.
# Removes all Gradle state (including configuration cache and Spotless JVM cache)
# to recover from corrupted or stale local builds.
clean-all:
	@rm -rf .gradle
	@./gradlew --no-daemon clean

# Local environment sanity (human-facing)
doctor: clean-all exec-bits
	@bash ./scripts/check-colima.sh
	@bash ./scripts/doctor.sh
	@echo "Doctor complete: environment looks ready."

# Auto-format (mutates files)
format:
	@rm -rf .gradle/configuration-cache
	@./gradlew --no-daemon --no-configuration-cache -q spotlessApply

# Static analysis only (fast-ish)
lint:
	@./gradlew --no-daemon -q checkstyleMain pmdMain spotbugsMain

# Full local quality gate (matches CI intent)
quality: doctor
	@./gradlew --no-daemon -q clean check

# Unit tests (includes doctor to avoid "it works on my machine" failures; use make test or make verify)
test: doctor
	@./gradlew --no-daemon -q test

# Umbrella target: what a developer should run before pushing / opening a PR
verify: doctor lint test
	@echo "Verify complete: environment + code checks passed."

# CI parity run (forces CI semantics; no auto-format)
test-ci: doctor
	@CI=true SPRING_PROFILES_ACTIVE=test ./gradlew --no-daemon --stacktrace clean check

# Install hooks + run the full quality gate (recommended after clone)
bootstrap: hooks quality
	@echo "Bootstrap complete: hooks installed and quality gate passed."

# List local Docker volumes related to Postgres (useful for spotting leftovers after renames)
docker-volume:
	@docker volume ls | grep -i postgres

# Start application and Postgres containers using docker compose (non-destructive)
docker-up:
	@docker compose up -d

# Stop containers without removing volumes (data preserved)
docker-down:
	@docker compose down

# Fully reset local Docker environment:
# - Stops containers
# - Removes volumes (Postgres data)
# - Recreates containers from scratch
# Safe for local development only
docker-reset:
	@echo "⚠️  Resetting local Docker environment (containers + volumes)"
	@docker compose down -v
	@docker compose up -d

# Open an interactive psql shell inside the Postgres service container
db-shell:
	@docker compose exec postgres psql -U $${POSTGRES_USER:-trainer} -d $${POSTGRES_DB:-trainer}
