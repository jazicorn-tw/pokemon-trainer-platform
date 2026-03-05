# Debugging Checklist (When Tests Fail)

Use this checklist before changing code or configuration. Most test failures can be diagnosed
quickly by following these steps in order.

---

## 1. Identify the Failing Test

Run the tests locally to confirm the failure:

```bash
./gradlew test
```

Note:

- The **test class name**
- The **test method name** (or `initializationError`)

---

## 2. Open the HTML Test Report (Source of Truth)

Gradle generates detailed HTML reports that often contain **more information than console output**.

**Location:**

```bash
build/reports/tests/test/classes/
```

Example:

```bash
build/reports/tests/test/classes/com.{{app-name}}.inventory.InventoryApplicationTest.html
```

**macOS:**

```bash
open build/reports/tests/test/classes/com.{{app-name}}.inventory.InventoryApplicationTest.html
```

---

## 3. Read the Stacktrace Correctly

In the HTML report, scroll to the **stacktrace** section and focus on:

- The **first `Caused by:`** line with an actual message
- Ignore framework noise below it

Common keywords to look for:

- `DataSourceAutoConfiguration`
- `Testcontainers`
- `Mapped port`
- `Flyway`
- `ConditionEvaluationReport`

> The first meaningful `Caused by:` explains *why* the test failed.

---

## 4. Determine the Failure Category

Use the error message to classify the failure:

### Spring context fails to start

- `Failed to load ApplicationContext`
- Usually caused by datasource, security, or auto-configuration issues

### Testcontainers errors

- `Mapped port can only be obtained after the container is started`
- `Could not find a valid Docker environment`

### Migration / schema issues

- Flyway validation failures
- Missing or out-of-order migrations

### Security / endpoint failures

- `401`, `403`, or `404` instead of expected `200`

---

## 5. Verify Environment Assumptions

Confirm the following before debugging deeper:

- Docker is running (Docker Desktop or Colima)
- No local PostgreSQL dependency is required
- Tests are run via:

  ```bash
  ./gradlew test
  ```

- No secrets or `.env` files are required for tests

---

## 6. Re-run with More Detail (If Needed)

If the HTML report is still unclear:

```bash
./gradlew test --no-daemon --stacktrace --info
```

Or inspect the JUnit XML directly:

```bash
sed -n '1,200p' build/test-results/test/TEST-<TestClass>.xml
```

---

## 7. Stop and Document Before Fixing

Before applying a fix, ask:

- What assumption did the test make?
- What changed recently (config, dependency, profile)?
- Does this violate any ADRs?

If the fix changes test wiring, **update `TESTING.md` or the relevant ADR** so future refactors
do not reintroduce the same failure.

---

> **Rule of thumb:**  
> A green test suite means the database, migrations, and configuration are production-safe.
