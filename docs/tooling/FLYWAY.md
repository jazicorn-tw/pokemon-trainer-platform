# 🛠 Database Migration Troubleshooting Guide

This document covers the resolution for `NoClassDefFoundError: JavaPluginConvention` and other Gradle-specific failures
when attempting to run Flyway tasks in modern Gradle environments (v9.0+).

## 1. The Problem: Gradle 9 vs. Flyway Plugin

When running `./gradlew flywayClean`, you may encounter an error similar to:
`java.lang.NoClassDefFoundError: org/gradle/api/plugins/JavaPluginConvention`

### Why it happens

- **API Removal:** Gradle 9 officially removed the `JavaPluginConvention` class, which had been deprecated
  for several versions.
- **Plugin Lag:** Even "modern" versions of the Flyway Gradle plugin (v10-11) may still have internal code paths
  (like `isJavaProject` checks) that attempt to access this missing class during task execution.
- **Configuration Cache:** Gradle 9 enforces strict isolation. If a plugin tries to access the `project` object
  at execution time, the build will fail.

---

## 2. The Solution: Flyway CLI (The "Escape Hatch")

If the Gradle plugin refuses to execute due to classpath or convention errors, bypass the build tool entirely and use
the Flyway Command Line Interface.

### Step 1: Install the CLI

On macOS (using Homebrew):

```bash
brew install flyway
```

### Step 2: Run the Clean Command

The preferred way is via the Make target, which sources credentials from `.env` automatically:

```bash
make db-flyway-clean
```

This requires:

- Flyway CLI installed (`brew install flyway`)
- `.env` present (copy `.env.example` if not)
- Postgres container running (`make docker-up`)

If you need to run the CLI directly (e.g. for debugging), the equivalent command is:

```bash
flyway clean \
  -url="$SPRING_DATASOURCE_URL" \
  -user="$SPRING_DATASOURCE_USERNAME" \
  -password="$SPRING_DATASOURCE_PASSWORD" \
  -cleanDisabled=false
```

> **Note:** `cleanDisabled` is set to `true` by default in Flyway 9+ to prevent accidental data loss.
> You must explicitly set it to `false` to wipe the schema.

---

## 3. Verifying the Connection

If the CLI also fails, the issue is likely your database state rather than your tooling. Use the following checks.

### Check Local Postgres

```bash
# See if any process is listening on the default port
lsof -i :5432
```

### Check Docker Containers

If running via Docker, ensure the port mapping is correctly exposed:

```bash
docker ps
```

Look for `0.0.0.0:5432->5432/tcp`. If you only see `5432/tcp`, the port is internal to the Docker network
and inaccessible to your host machine.

---

## 4. Summary Table: Plugin vs. CLI

| Feature | Gradle Plugin | Flyway CLI |
| --- | --- | --- |
| **Dependency** | Managed in `build.gradle` | Installed on OS (`brew`) |
| **Compatibility** | Subject to Gradle API changes | Independent of Java/Gradle versions |
| **Use Case** | CI/CD pipelines, automated builds | Local dev, emergency maintenance |
| **Configuration** | Uses `System.getProperty` or `flyway {}` | Uses CLI flags or `flyway.conf` |
