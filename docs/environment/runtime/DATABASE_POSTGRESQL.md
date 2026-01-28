# 🗄️ Database — PostgreSQL

Used by both the application and Flyway migrations.

## Required

```text
SPRING_DATASOURCE_URL
SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_PASSWORD
```

## Pooling (HikariCP)

```text
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE
SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT
```

## Flyway

```text
SPRING_FLYWAY_ENABLED
SPRING_FLYWAY_BASELINE_ON_MIGRATE
SPRING_FLYWAY_LOCATIONS
```

## Render Postgres (SSL)

When using Render-managed Postgres, SSL is usually required.

**Recommended:** include SSL parameters directly in the JDBC URL so the app
remains portable and 12-factor compliant.
