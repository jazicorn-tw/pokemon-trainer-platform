# 🌍 Environment & Configuration

This folder documents **all environment variables and feature flags** used by the platform.

The documentation is intentionally split into focused files to keep each concern clear,
auditable, and easy to evolve over time.

## Files

- **CI_FEATURE_FLAGS.md**  
  GitHub Actions feature flags that control publishing, releases, and deployments.

- **RUNTIME_APPLICATION.md**  
  Core Spring Boot runtime variables shared across all environments.

- **DATABASE_POSTGRESQL.md**  
  PostgreSQL connection, pooling, SSL, and Flyway configuration.

- **SECURITY_AUTH.md**  
  JWT and authentication-related configuration.

- **OBSERVABILITY_LOGGING.md**  
  Actuator, health checks, probes, and logging controls.

- **PLATFORM_NOTES.md**  
  Platform-specific behavior (Render now, Kubernetes later).

## Principles

- Variable **names are stable**
- Values are **environment-specific**
- Secrets are **never committed**
- CI and runtime concerns are **explicitly separated**
