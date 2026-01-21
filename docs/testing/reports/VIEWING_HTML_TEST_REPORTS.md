# Viewing HTML Test Reports

When a test fails, Gradle generates detailed **HTML reports** that often contain
more information than the console output (especially for Spring context
`initializationError`s).

## Location

From the project root:

```bash
build/reports/tests/test/
```

Per-test-class reports live under:

```bash
build/reports/tests/test/classes/
```

Example:

```bash
build/reports/tests/test/classes/com.pokedex.platform.PlatformApplicationTest.html
```

---

## macOS (recommended)

Open the report directly in your default browser:

```bash
open build/reports/tests/test/classes/com.pokedex.platform.PlatformApplicationTest.html
```

---

## Finder

1. Open the project directory
2. Navigate to:

   ```text
   build → reports → tests → test → classes
   ```

3. Double-click the `.html` file for the failing test

---

## VS Code

1. Press **⌘ + P**
2. Paste the path:

   ```bash
   build/reports/tests/test/classes/com.pokedex.platform.PlatformApplicationTest.html
   ```

3. Press Enter  
   (VS Code will open it or offer to open it in a browser)

---

## What to Look For

In the HTML report, scroll to the **stacktrace** section and focus on:

- The **first `Caused by:`** line with an actual message
- Errors mentioning:
  - `DataSourceAutoConfiguration`
  - `Testcontainers`
  - `Mapped port`
  - `ConditionEvaluationReport`

These lines explain *why* the test failed and are more reliable than the
high-level Gradle output.

> If the console output is unclear, the HTML report is the source of truth.
