# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

.PHONY: hooks format lint quality test test-ci bootstrap

hooks:
	./scripts/install-hooks.sh

# Auto-format (mutates files)
format:
	./gradlew --no-daemon --no-configuration-cache -q spotlessApply

# Static analysis only (fast-ish)
lint:
	./gradlew --no-daemon -q checkstyleMain pmdMain spotbugsMain

# Full local quality gate (matches CI intent)
# Note: clean is optional here — keep it if you want "fresh" checks every time.
quality: format
	rm -rf .gradle/configuration-cache
	./gradlew --no-daemon -q clean check

test:
	./gradlew --no-daemon -q test

test-ci:
	CI=true SPRING_PROFILES_ACTIVE=test ./gradlew --no-daemon --stacktrace clean check

# Install hooks + run the full quality gate (recommended after clone)
bootstrap: hooks quality
	@echo "Bootstrap complete: hooks installed and quality gate passed."
