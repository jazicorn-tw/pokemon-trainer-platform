# Quality Gate FAQ

Error messages from the quality gate explained — with exact fixes.

Run the full gate to see everything at once before committing:

```bash
./gradlew clean check
# or
make quality
```

Fix order matters: **Spotless first** (it rewrites files), then
Checkstyle, then PMD, then SpotBugs, then markdownlint.

---

## Spotless

### `Run './gradlew spotlessApply' to fix formatting violations`

**Cause:** Your Java code doesn't match Google Java Format.

**Fix:**

```bash
./gradlew spotlessApply
git add -u
cz commit
```

Spotless rewrites files in place. Always re-stage after applying.

> ⚠️ If the pre-commit hook aborted your commit because Spotless ran
> and modified files, this is expected — just re-add and recommit.

---

## Checkstyle

Checkstyle version: **10.17.0**. Rules live in `.config/checkstyle/checkstyle.xml`.

### `MethodName: Method name 'foo_bar' must match pattern`

**Cause:** Test method names contain underscores. Checkstyle enforces
camelCase on all method names including tests.

**Fix:** Rename to camelCase.

```java
// ❌
void create_resource_returns_201() {}

// ✅
void createResourceReturns201() {}
```

### `LineLength: Line is longer than 120 characters`

**Cause:** A non-code line exceeds 120 characters. (Package statements,
imports, and URLs are exempt.)

**Fix:** Break the line. In Java, break method chains or string
concatenations. In Markdown, shorten prose or restructure.

### `AvoidStarImport: Using the '.*' form of import should be avoided`

**Cause:** Wildcard import (`import java.util.*`).

**Fix:** Replace with explicit imports. Your IDE can do this automatically
(`Optimize Imports`).

### `UnusedImports: Unused import`

**Fix:** Delete the import. IDE → Optimize Imports handles this.

### `NeedBraces: '{' is missing`

**Cause:** A single-line `if`/`for`/`while` without braces.

**Fix:**

```java
// ❌
if (x) doSomething();

// ✅
if (x) {
    doSomething();
}
```

### `EmptyBlock: Must have at least one statement`

**Cause:** An empty `catch` block or similar.

**Fix:** Add a meaningful statement, log the exception, or add a comment
explaining why the block is intentionally empty.

### `FileTabCharacter: File contains tab characters`

**Cause:** A tab character exists somewhere in the file.

**Fix:** Run `spotlessApply` — it enforces spaces throughout.

---

## PMD

PMD version: **7.5.0**. Rule sets: `bestpractices.xml` + `errorprone.xml`.

### `JUnitTestsShouldIncludeAssert: JUnit tests should include assert() or fail()`

**Cause:** PMD can't see that MockMvc's `andExpect(...)` is asserting.
Commonly triggered on `@WebMvcTest` controller tests.

**Fix:** Suppress at the class level — this is the established pattern:

```java
@SuppressWarnings({"PMD.JUnitTestsShouldIncludeAssert", "PMD.AvoidDuplicateLiterals"})
class ResourceControllerTest {
```

### `JUnitTestContainsTooManyAsserts: JUnit tests should not contain more than 1 assert(s)`

**Cause:** A test has multiple `assertThat` / `assertEquals` calls. Common
in service-layer tests that verify multiple fields at once.

**Fix:** Suppress at the class level:

```java
@SuppressWarnings({"PMD.JUnitTestContainsTooManyAsserts", "PMD.AvoidDuplicateLiterals"})
class ResourceServiceTest {
```

### `AvoidDuplicateLiterals: The String literal "resource" appears N times`

**Cause:** The same string literal (e.g. a URL path or field name) appears
more than once in the file. Commonly triggered in test classes.

**Fix (preferred):** Extract to a constant:

```java
private static final String RESOURCE_PATH = "/api/resources";
```

**Fix (suppress):** If extraction would hurt readability (e.g. short
test-only strings), suppress at the class level alongside other PMD
suppressions:

```java
@SuppressWarnings({"PMD.JUnitTestsShouldIncludeAssert", "PMD.AvoidDuplicateLiterals"})
```

### `GuardLogStatement: Logger calls should be surrounded by log level guards`

**Cause:** A `LOG.debug(...)` call is not guarded, which causes string
concatenation even when debug logging is disabled.

**Fix:**

```java
// ❌
LOG.debug("Value: {}", someExpensiveCall());

// ✅
if (LOG.isDebugEnabled()) {
    LOG.debug("Value: {}", someExpensiveCall());
}
```

### `AbstractClassWithoutAbstractMethod: An abstract class should have abstract methods`

**Cause:** A base class (e.g. `BaseIntegrationTest`) is declared abstract
but has no abstract methods — it only provides shared setup.

**Fix:** Suppress on the class:

```java
@SuppressWarnings({
    "PMD.AbstractClassWithoutAbstractMethod",
    "PMD.TestClassWithoutTestCases"
})
abstract class BaseIntegrationTest {
```

### `TestClassWithoutTestCases: Test class has no test cases`

**Cause:** A class in the test source tree has no `@Test` methods — again,
typical for base/helper classes.

**Fix:** Suppress alongside `AbstractClassWithoutAbstractMethod` (see above).

---

## SpotBugs

SpotBugs version: **4.8.6**. Exclusions live in `.config/spotbugs/spotbugs-exclude.xml`.

DTOs, models, request/response classes, and config classes are already
excluded globally. You should not need SpotBugs suppressions in those packages.

### `EI_EXPOSE_REP / EI_EXPOSE_REP2: Returning a reference to a mutable object`

**Cause:** A getter returns a mutable collection or array directly.

**Fix (preferred):** Return an unmodifiable copy:

```java
public List<String> getTags() {
    return Collections.unmodifiableList(tags);
}
```

**Fix (suppress):** If the class is already excluded by the global filter
(DTOs, models, entities), you shouldn't see this. If you do, check that
your class is in the right package.

### `NP_NULL_ON_SOME_PATH_FROM_RETURN_VALUE`

**Cause:** SpotBugs believes a method can return null and the result is
used without a null check.

**Fix:** Add a null check, use `Optional`, or annotate with
`@NonNull` to signal intent.

---

## markdownlint

markdownlint config: `.markdownlint.json` — 120-char line limit;
**code blocks and tables are exempt** from line length.

### `MD013/line-length: Line length [N] exceeds maximum [120]`

**Cause:** A prose line in a Markdown file is over 120 characters.
(Code fences and table rows are not checked.)

**Fix:** Break the line at a natural word boundary. For URLs, placing
them on their own line or using a reference link is acceptable.

### `MD036/no-emphasis-as-heading: Emphasis used instead of a heading`

**Cause:** Bold or italic used as a section label on its own line:

```markdown
**My Section**    ❌
_My Section_      ❌
```

**Fix:** Use a proper heading:

```markdown
### My Section    ✅
```

### `MD040/fenced-code-language: Fenced code blocks should have a language`

**Cause:** A code fence has no language tag.

**Fix:** Add a language specifier. Use `text` for plain-text blocks:

````markdown
```text         ✅
Some output here
```
````

### `MD060/table-column-style: Table column separator should be consistent`

**Cause:** Table separator row uses `|---|` instead of `| --- |`.

**Fix:** Pad the dashes with spaces:

```markdown
| Column A | Column B |
| -------- | -------- |   ✅
```

### `MD033/no-inline-html: Inline HTML`

**Not an error in this repo** — MD033 is disabled in `.markdownlint.json`.

### `MD041/first-line-heading`

**Not an error in this repo** — MD041 is disabled in `.markdownlint.json`.

---

## Quick-reference suppression patterns

| Tool | Suppression syntax |
| ---- | ------------------ |
| PMD | `@SuppressWarnings("PMD.RuleName")` on the class |
| Checkstyle | `@SuppressWarnings("checkstyle:RuleName")` on the method |
| SpotBugs | Covered by global exclusions for DTOs/models/config |

When in doubt, fix the root cause rather than suppress.
Suppressions in production code (outside `src/test/`) require justification.

---

📄 Related: [`COMMON_FIRST_DAY_FAILURES.md`](../onboarding/COMMON_FIRST_DAY_FAILURES.md)
