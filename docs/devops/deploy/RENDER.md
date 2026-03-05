<!-- markdownlint-disable-file MD033 -->

# 🚀 Deploy to Render (Option A: Single Service)

This project deploys to Render as a **single Docker-based web service** while we build out the modular monolith.

## Recommended approach (start simple)

Use Render's **Dockerfile deploy**:

- Render builds the container directly from this repo
- No registry wiring required initially

You can later switch to pulling a pinned GHCR image tag (release-aligned) if desired.

## Render setup (high level)

1. Create a **Web Service** in Render
2. Connect your GitHub repo
3. Choose:
   - Runtime: Docker
   - Branch: `main`
4. Set environment variables (below)
5. Add a Health Check (below)
6. Deploy

## Environment variables

At minimum, set:

- `SPRING_PROFILES_ACTIVE=prod`

Database (Render Postgres or external):

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

Security (example):

- `JWT_SECRET` (or your app’s secret name)

## Health check

If you use Spring Boot Actuator probes, use one of:

- `/actuator/health`
- `/actuator/health/readiness` (preferred once enabled)

## Notes

- Keep all runtime config in environment variables (12-factor)
- Flyway migrations should run on startup (idempotent, safe)
- Prefer pinning images to a release tag for production stability (later enhancement)

## Future enhancement (release-aligned deploy)

Once you publish images to GHCR on semantic-release tags, you can configure Render to deploy from a specific image tag
(e.g., `ghcr.io/your-org/{{project-name}}:1.2.3`) rather than building from the repo.
