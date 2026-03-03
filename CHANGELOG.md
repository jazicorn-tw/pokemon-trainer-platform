# 📦 Release History

## 📦 Release 1.1.0

### ✨ Features

- **helm:** complete chart templates for serviceaccount, hpa, and deployment (840ca8d)



## 1.1.0

### ✨ Features

- **helm:** complete chart templates for serviceaccount, hpa, and deployment

## 📦 Release 1.0.0

### ✨ Features

- **commit-msg:** add semantic-release–aware confirmation guard with strict mode (81320ea)

### 🐛 Fixes

- **build:** enforce spotlessCheck as part of ./gradlew check (abe67d6)
- **ci:** stabilise act for Colima, enable build cache, enforce spotless in check (5146319)
- **doctor:** stop colima auto-scale from re-triggering on every run (55c9007)
- **git-hooks:** surface heuristic fallback reason and drop refactor from patch bucket (28f613f)
- **make:** add release-dry-run target to preview next semantic-release version (c2dff8b)
- **make:** fix act local CI simulation for Colima Docker socket (38adf2c)
- **release:** replace bash default expansion in prepareCmd with (a94e981)
- **scripts:** replace broken colima status grep with exit-code detection (7f12053)

### ✅ Tests

- **ci:** fix Testcontainers datasource wiring and CI parity (fffde4f)
- **infra:** fix Testcontainers startup order and document failure mode (9f7e5c2)
- **security:** fix public endpoint tests without booting full context (f98cb71)

### 📦 Build

- allow CI to set release version via -PreleaseVersion (b53b71e)
- dedupe exec-bits target in makefile (d349ed1)
- establish deployment strategy and local CI simulation; document service roadmap (04094ac)

### 🤖 CI / CD

- add semantic-release workflow and config (bc8e42c)
- gate Docker image publishing via repository variables (d619243)
- **guard:** enforce semantic-release ownership of CHANGELOG updates (fef64c2)
- **release:** migrate to gradle setup-gradle v4 for wrapper validation (6d9d118)
- **release:** run semantic-release via npx with app token (803c91c)
- rename docker image tag to pokemon-trainer-platform (36cec45)

### 🧹 Chores

- **check-colima:** update status emoji (96adb90)
- **ci:** add guard bypass for early development (267a7d9)
- **ci:** document workflow naming and rename workflows (535ae60)
- **ci:** guard release commit scope and document release gating (2192aa4)
- **ci:** improve local act performance and silence cache warnings (1cf80d0)
- **ci:** refine release workflow ergonomics for local act runs (6709146)
- **ci:** split workflows into ci-fast, ci-quality, ci-test (07e183a)
- **config:** fix config directory naming and executable bits check (d76ba1a)
- **db:** reduce phase 0 Flyway schema and update ADR-001 (64aeb3a)
- **dev-env:** add environment checks, bootstrap wiring, and onboarding docs (d5cb52d)
- **dev:** add act-all target to run all workflows locally (0b69a97)
- **dev:** add colima resource guard and developer documentation (5255f74)
- **dev:** add commitizen config and document commit-msg enforcement (7f250bf)
- **dev:** fix executable bits for bootstrap scripts (d87635f)
- **dev:** harden commit-msg hook against installer leakage (8dd2444)
- **dev:** ignore node tooling files for semantic-release (ce66b8e)
- **dev:** make executable-bit checks configurable and auto-fixable (7c496a7)
- **dev:** remove docker container name and add docker reset helpers (16fc71e)
- **dev:** standardize local settings and bootstrap workflow (3386774)
- **doctor:** enhance diagnostics and colima resource reporting (e411f41)
- **doctor:** harden doctor tooling with JSON contract and CI snapshot (15cc0e2)
- **doctor:** removed spacing before enviroment checks passed (4869dfc)
- **dx:** add local environment doctor checks and standardize Makefile workflow (a9ad25a)
- **dx:** harden CI caching, doctor checks, and release config (352bbf7)
- **dx:** prevent pre-commit from modifying files (cc75f7e)
- enforce explicit CI gating and guarded delivery targets (b4f7ecd)
- Ignore .DS_Store files in all subdirectories (5276cf0)
- **make:** add act bootstrap + act-only env/secrets checks (c27242c)
- **make:** add inspect-mk tooling and docs (f34a5c7)
- **make:** add inspection help category (c4dc53b)
- **make:** add role-based help and auto-discovered help categories (be0dc73)
- **make:** add tree inspection helper and docs (ea45b60)
- **make:** correct help menu typo (d1d86c3)
- **make:** document decade layering + harden contributor entrypoint (a0c2776)
- **make:** refine doctor JSON target and improve console output (9e2e9b9)
- **make:** regenerate whitespace-safe Makefile and fix act workflow handling (25a861e)
- **make:** split Makefile into modular includes (6d3374f)
- **make:** tighten pre-commit policy and improve act ergonomics (81b9641)
- **make:** update help output to reflect current commands and role flows (963875d)
- **no-release:** stop docker.sock warning under act (07af5d9)
- **planning:** add structured ideas/todo system with linting and CI integration (cdce93b)
- **release-notes:** refine semantic-release grouping, ordering, and safety guards (07ef173)
- **release:** add semantic-release dependencies (471eeca)
- remove .DS_Store (e27d788)
- **tooling:** add local hygiene system for act, docker, and colima (1da81be)

### ♻️ Refactors

- **ci:** extract setup-java-gradle composite action (f9adc95)
- **ci:** extract setup-java-gradle composite action, migrate workflows (0575e4d)
- **core:** rename application and root package to platform (c8e0ffc)
- **make:** extract GRADLE variable and shared macros to reduce recipe duplication (a42fcf4)
- **make:** move makefiles from repo root into docs/make/ directory (d448220)
- **make:** namespace runtime lifecycle targets under env-* (dd42717)
- **make:** rename mk files to responsibility-based decades (2177422)
- **scripts:** consolidate die() across cache scripts via shell-utils.sh (52221eb)
- **scripts:** extract shared doctor-check helpers into scripts/lib/ (1e043f5)
- **scripts:** extract shared shell utilities into scripts/lib/ (8f1aef6)

### 📝 Docs

- **act:** update act docs for colima and socket routing (f3cdca9)
- add macos bootstrap script documentation (2c9ecfa)
- **adr:** add ADR-007 for commit-msg enforcement via commitizen (99bad65)
- **adr:** add ADR-008 for CI-managed releases with semantic-release (66fe919)
- **adr:** added missing adr's to adr index file (2b4193b)
- **adr:** editorial refinements to ADR-006 (82b54e9)
- **adr:** update ADR index and documentation rules (e2057b8)
- **architecture:** clarify layered design and phased components (27a10cc)
- **badges:** add badge documentation and update README badges (9aa9de2)
- **badges:** document badge policy and deferred signals (7d1b258)
- **badges:** formalize badge philosophy and document current CI signals (87ab4c6)
- **ci:** clarify act usage and local CI simulation (2d36ef7)
- **ci:** document act colima, arch mismatch, and pip warnings (6999ed0)
- **commit:** add 1-page conventional commits cheat sheet (8debd13)
- **dev:** align pre-commit documentation with ADR-000 quality gates (d33adf1)
- **devops:** add accidental release recovery guide and gate semantic-release (7a8abe2)
- **dev:** updated developer documentation (c6ac0d5)
- document local-settings scope and bootstrap responsibilities (11ad6b9)
- document release intent, CI gating, and delivery boundaries (9f00f4e)
- **env:** restructure environment documentation into specs and quick references (4711fdb)
- **make:** add documentation TOC and tree navigation helpers (fbf5b92)
- **onboarding:** add environment checklist and link it from onboarding README (94d67b3)
- **onboarding:** recommend cz commit over git commit (e34f934)
- **readme:** clarify phased features and testing stack (f7e2474)
- **readme:** condensed readme and moved full version to docs (b9e74a9)
- **readme:** delete badges.md after consolidating badges (c46b259)
- **readme:** fixed file name error (b9accf8)
- **readme:** fixed line error (817988b)
- **readme:** restore project badges (9a91a7c)
- **readme:** simplify README structure and focus (2be8e58)
- refactor md placement and fix stale cross-references (0f58b82)
- rename precheck to doctor and align onboarding and ADRs (ea09d02)
- reorganize developer documentation structure (c24ccea)
- **secrets:** add secrets template and documentation (b9289d0)
- tighten README and contributing guidelines (56ada4f)
- **tooling:** reorganize Make docs into docs/tooling/make (3dbfde1)



## 1.0.0

### ✨ Features

- **commit-msg:** add semantic-release–aware confirmation guard with strict mode

### 🐛 Fixes

- **build:** enforce spotlessCheck as part of ./gradlew check
- **ci:** stabilise act for Colima, enable build cache, enforce spotless in check
- **doctor:** stop colima auto-scale from re-triggering on every run
- **git-hooks:** surface heuristic fallback reason and drop refactor from patch bucket
- **make:** add release-dry-run target to preview next semantic-release version
- **make:** fix act local CI simulation for Colima Docker socket
- **release:** replace bash default expansion in prepareCmd with
- **scripts:** replace broken colima status grep with exit-code detection

### ✅ Tests

- **ci:** fix Testcontainers datasource wiring and CI parity
- **infra:** fix Testcontainers startup order and document failure mode
- **security:** fix public endpoint tests without booting full context

### 📦 Build

- allow CI to set release version via -PreleaseVersion
- dedupe exec-bits target in makefile
- establish deployment strategy and local CI simulation; document service roadmap

### 🤖 CI / CD

- add semantic-release workflow and config
- gate Docker image publishing via repository variables
- **guard:** enforce semantic-release ownership of CHANGELOG updates
- **release:** migrate to gradle setup-gradle v4 for wrapper validation
- **release:** run semantic-release via npx with app token
- rename docker image tag to pokemon-trainer-platform

### 🧹 Chores

- **check-colima:** update status emoji
- **ci:** add guard bypass for early development
- **ci:** document workflow naming and rename workflows
- **ci:** guard release commit scope and document release gating
- **ci:** improve local act performance and silence cache warnings
- **ci:** refine release workflow ergonomics for local act runs
- **ci:** split workflows into ci-fast, ci-quality, ci-test
- **config:** fix config directory naming and executable bits check
- **db:** reduce phase 0 Flyway schema and update ADR-001
- **dev-env:** add environment checks, bootstrap wiring, and onboarding docs
- **dev:** add act-all target to run all workflows locally
- **dev:** add colima resource guard and developer documentation
- **dev:** add commitizen config and document commit-msg enforcement
- **dev:** fix executable bits for bootstrap scripts
- **dev:** harden commit-msg hook against installer leakage
- **dev:** ignore node tooling files for semantic-release
- **dev:** make executable-bit checks configurable and auto-fixable
- **dev:** remove docker container name and add docker reset helpers
- **dev:** standardize local settings and bootstrap workflow
- **doctor:** enhance diagnostics and colima resource reporting
- **doctor:** harden doctor tooling with JSON contract and CI snapshot
- **doctor:** removed spacing before enviroment checks passed
- **dx:** add local environment doctor checks and standardize Makefile workflow
- **dx:** harden CI caching, doctor checks, and release config
- **dx:** prevent pre-commit from modifying files
- enforce explicit CI gating and guarded delivery targets
- Ignore .DS_Store files in all subdirectories
- **make:** add act bootstrap + act-only env/secrets checks
- **make:** add inspect-mk tooling and docs
- **make:** add inspection help category
- **make:** add role-based help and auto-discovered help categories
- **make:** add tree inspection helper and docs
- **make:** correct help menu typo
- **make:** document decade layering + harden contributor entrypoint
- **make:** refine doctor JSON target and improve console output
- **make:** regenerate whitespace-safe Makefile and fix act workflow handling
- **make:** split Makefile into modular includes
- **make:** tighten pre-commit policy and improve act ergonomics
- **make:** update help output to reflect current commands and role flows
- **no-release:** stop docker.sock warning under act
- **planning:** add structured ideas/todo system with linting and CI integration
- **release-notes:** refine semantic-release grouping, ordering, and safety guards
- **release:** add semantic-release dependencies
- remove .DS_Store
- **tooling:** add local hygiene system for act, docker, and colima

### ♻️ Refactors

- **ci:** extract setup-java-gradle composite action
- **ci:** extract setup-java-gradle composite action, migrate workflows
- **core:** rename application and root package to platform
- **make:** extract GRADLE variable and shared macros to reduce recipe duplication
- **make:** move makefiles from repo root into docs/make/ directory
- **make:** namespace runtime lifecycle targets under env-*
- **make:** rename mk files to responsibility-based decades
- **scripts:** consolidate die() across cache scripts via shell-utils.sh
- **scripts:** extract shared doctor-check helpers into scripts/lib/
- **scripts:** extract shared shell utilities into scripts/lib/

### 📝 Docs

- **act:** update act docs for colima and socket routing
- add macos bootstrap script documentation
- **adr:** add ADR-007 for commit-msg enforcement via commitizen
- **adr:** add ADR-008 for CI-managed releases with semantic-release
- **adr:** added missing adr's to adr index file
- **adr:** editorial refinements to ADR-006
- **adr:** update ADR index and documentation rules
- **architecture:** clarify layered design and phased components
- **badges:** add badge documentation and update README badges
- **badges:** document badge policy and deferred signals
- **badges:** formalize badge philosophy and document current CI signals
- **ci:** clarify act usage and local CI simulation
- **ci:** document act colima, arch mismatch, and pip warnings
- **commit:** add 1-page conventional commits cheat sheet
- **dev:** align pre-commit documentation with ADR-000 quality gates
- **devops:** add accidental release recovery guide and gate semantic-release
- **dev:** updated developer documentation
- document local-settings scope and bootstrap responsibilities
- document release intent, CI gating, and delivery boundaries
- **env:** restructure environment documentation into specs and quick references
- **make:** add documentation TOC and tree navigation helpers
- **onboarding:** add environment checklist and link it from onboarding README
- **onboarding:** recommend cz commit over git commit
- **readme:** clarify phased features and testing stack
- **readme:** condensed readme and moved full version to docs
- **readme:** delete badges.md after consolidating badges
- **readme:** fixed file name error
- **readme:** fixed line error
- **readme:** restore project badges
- **readme:** simplify README structure and focus
- refactor md placement and fix stale cross-references
- rename precheck to doctor and align onboarding and ADRs
- reorganize developer documentation structure
- **secrets:** add secrets template and documentation
- tighten README and contributing guidelines
- **tooling:** reorganize Make docs into docs/tooling/make
