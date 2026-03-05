# Project Setup

This is the **single reference** for setting up this project from scratch.
Work through the sections in order — each one assumes the previous is complete.

---

## 0. Prerequisites

Install these tools before anything else:

| Tool | Required version | Check |
| ---- | ---------------- | ----- |
| Java | 21 | `java -version` |
| Docker Desktop or Colima | Any recent | `docker ps` |
| Node.js | 20+ | `node --version` |
| Git | Any | `git --version` |
| make | Any | `make --version` |
| jq | Any | `jq --version` |

Verify all at once:

```bash
make doctor
```

`make doctor` is local-only and will tell you exactly what is missing or misconfigured.

---

## 1. Create your repository from this template

If you haven't cloned yet:

```bash
gh repo create my-api --template your-org/{{project-name}} --private
cd my-api
```

If you already cloned the repo directly, skip this step.

---

## 2. Replace template placeholders

There are two kinds of placeholders:

- **Static tokens** — appear in docs, CI workflows, Helm, and `build.gradle`. Replace once.
- **Runtime identity** (`APP_NAME`) — set once in `.env`. Docker Compose and scripts read it
  automatically; no find-and-replace needed.

### Static tokens

| Token | Replace with | Example |
| ----- | ------------ | ------- |
| `{{project-name}}` | Repo / CI pipeline name | `my-api` |
| `your-org` | GitHub org or username | `acme` |
| `com.example` | Your Java base package | `com.acme` |

Run these from the repo root (macOS/Linux):

```bash
# {{project-name}}
grep -rl '{{project-name}}' . \
  --include='*.yml' --include='*.md' --include='*.json' --include='*.toml' \
  | xargs sed -i '' 's/{{project-name}}/my-api/g'

# your-org
grep -rl 'your-org' . \
  --include='*.yml' --include='*.md' --include='*.json' \
  | xargs sed -i '' 's/your-org/acme/g'

# com.example (Java package)
grep -rl 'com\.example' . \
  --include='*.java' --include='*.gradle' --include='*.xml' \
  | xargs sed -i '' 's/com\.example/com.acme/g'
```

### Rename Java source packages

```bash
mv src/main/java/com/example src/main/java/com/acme
mv src/test/java/com/example src/test/java/com/acme
```

---

## 3. Set up environment files

### Required: `.env`

```bash
cp .env.example .env
```

Open `.env` and set these values:

```bash
# Set this first — Docker Compose and scripts read it automatically
APP_NAME=my-app

# Update these to match your APP_NAME
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/my-app
SPRING_DATASOURCE_USERNAME=my-app

# Pick a real password
POSTGRES_PASSWORD=changeme
```

Everything else in `.env` can stay at its default for local development.

### Optional: `.vars` and `.secrets` (for local CI with `act`)

```bash
cp .vars.example .vars
cp .secrets.example .secrets
```

Edit `.vars`:

```bash
ENABLE_SEMANTIC_RELEASE=true
CANONICAL_REPOSITORY=acme/my-api
```

Edit `.secrets` only if you need to run release workflows locally (requires a GitHub App).

---

## 4. Bootstrap

```bash
make doctor     # verify all prerequisites pass
make bootstrap  # install git hooks + run quality gate
```

`make bootstrap` is idempotent — safe to re-run at any time.

What it does:

1. Creates `.env` from `.env.example` (non-destructive — won't overwrite existing `.env`)
2. Installs repo-local Git hooks (commit message validation, pre-add lint)
3. Fixes executable bits on scripts
4. Runs the local quality gate (Spotless formatting + Checkstyle + PMD + SpotBugs)

---

## 5. Start Postgres and run tests

```bash
docker compose up -d postgres   # start the database
./gradlew test                  # run all tests (requires Docker)
```

All tests should pass on a clean checkout. If they don't, see [`docs/testing/TESTING.md`](../testing/TESTING.md).

---

## 6. Start the app

```bash
make run
# or
./gradlew bootRun
```

Verify it's running:

```bash
curl http://localhost:8080/ping
curl http://localhost:8080/actuator/health
```

Both should respond. If not, check that Postgres is up (`docker compose ps`) and `.env` is sourced.

---

## 7. Configure GitHub (for CI and releases)

Go to your GitHub repo → **Settings → Secrets and variables → Actions**.

### Secrets (required for release pipeline)

| Secret | Description |
| ------ | ----------- |
| `GH_APP_ID` | GitHub App ID |
| `GH_APP_PRIVATE_KEY` | GitHub App private key (PEM) |

### Repository variables (required for CI gate and release)

| Variable | Example value |
| -------- | ------------- |
| `ENABLE_SEMANTIC_RELEASE` | `true` |
| `CANONICAL_REPOSITORY` | `acme/my-api` |

> The CI pipelines `ci-fast`, `ci-quality`, and `ci-test` work without secrets.
> Only the `release` and `image-publish` workflows require the GitHub App credentials.

---

## 8. Define your domain

The scaffold ships with two generic example entities:

- `resource/` — primary entity (rename to e.g. `user/`, `order/`, `product/`)
- `item/` — secondary entity (rename to e.g. `lineitem/`, `photo/`, `tag/`)

To adapt them:

- **Schema:** Edit `src/main/resources/db/migration/V1__init.sql` — replace the sample `user` table with your schema
- **Source:** Rename `src/main/java/com/acme/platform/resource/` and `item/` to your entity names
- **Seed data:** Edit `scripts/db/seed-db.sh` — add sample rows for local development
- **Tracking:** Add your first tasks to `docs/planning/TODO.md`

---

## Checklist

- [ ] Prerequisites installed (`make doctor` passes)
- [ ] Repo created from template
- [ ] `{{project-name}}` replaced everywhere
- [ ] `your-org` replaced everywhere
- [ ] `com.example` replaced — Java packages renamed
- [ ] `.env` created and `APP_NAME` set
- [ ] `SPRING_DATASOURCE_URL` and `SPRING_DATASOURCE_USERNAME` updated to match `APP_NAME`
- [ ] `make bootstrap` completed successfully
- [ ] `./gradlew test` passes
- [ ] App starts and `/ping` responds
- [ ] GitHub secrets and variables configured
- [ ] Domain entities renamed to match your project

---

## If something goes wrong

1. Re-run `make doctor` — it explains most environment issues
2. Check [`docs/testing/TESTING.md`](../testing/TESTING.md) for test failures
3. Check [`docs/testing/CI_TROUBLESHOOTING.md`](../testing/CI_TROUBLESHOOTING.md) for CI issues
4. Check [`docs/faq/QUALITY_GATE_EXPLAINED.md`](../faq/QUALITY_GATE_EXPLAINED.md) for linting failures
