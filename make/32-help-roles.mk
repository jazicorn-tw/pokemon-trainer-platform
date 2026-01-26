# -------------------------------------------------------------------
# HELP ROLES
# -------------------------------------------------------------------
#
# Role-based aliases that compose existing help categories.
#
# This file intentionally contains ONLY role targets.
# -------------------------------------------------------------------

.PHONY: help-reviewer help-contributor help-maintainer

help-reviewer: help-ci ## 🧑‍🔍 Reviewer / CI triage (alias for help-ci)

help-contributor: help-onboarding help-env help-quality ## 🧑‍💻 Contributor starter pack (onboarding + env + quality)

help-maintainer: help-ci help-act help-docker help-helm ## 🧑‍🔧 Maintainer pack (ci + act + docker + helm)
