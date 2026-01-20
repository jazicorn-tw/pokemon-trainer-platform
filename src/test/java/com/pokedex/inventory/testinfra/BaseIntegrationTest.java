package com.pokedex.inventory.testinfra;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.TestInstance;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Base infrastructure for PostgreSQL-backed integration tests.
 *
 * <p>This class centralizes Testcontainers + Spring wiring so concrete tests only need to extend
 * it.
 *
 * <p>Datasource properties are provided dynamically from the running container. Schema behavior
 * (Flyway + JPA validate, etc.) is owned by {@code application-test.yml} to avoid duplicate
 * configuration sources.
 *
 * <p><strong>Important:</strong> Spring may evaluate {@code @DynamicPropertySource} values during
 * auto-configuration condition checks while the ApplicationContext is being built. If the container
 * is not started yet, {@code getJdbcUrl()} can throw errors like: "Mapped port can only be obtained
 * after the container is started".
 *
 * <p>To keep startup deterministic, we ensure the container is running inside the
 * {@code @DynamicPropertySource} method before registering supplier functions.
 */
@Testcontainers
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@SuppressWarnings({
  "resource",
  "PMD.AbstractClassWithoutAbstractMethod",
  "PMD.TestClassWithoutTestCases"
})
public abstract class BaseIntegrationTest {

  private static final String POSTGRES_IMAGE =
      System.getenv().getOrDefault("TEST_DATASOURCE_IMAGE", "postgres:16-alpine");

  private static final String POSTGRES_DB =
      System.getenv().getOrDefault("TEST_DATASOURCE_DB", "pokedex_test");

  private static final String POSTGRES_USER =
      System.getenv().getOrDefault("TEST_DATASOURCE_USER", "test");

  private static final String POSTGRES_PASSWORD =
      System.getenv().getOrDefault("TEST_DATASOURCE_PASSWORD", "test");

  @Container
  protected static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>(POSTGRES_IMAGE)
          .withDatabaseName(POSTGRES_DB)
          .withUsername(POSTGRES_USER)
          .withPassword(POSTGRES_PASSWORD);

  /**
   * Optional hook for subclasses to perform additional verification or setup once the container is
   * running.
   */
  protected void onContainerReady() {
    // no-op by default
  }

  @BeforeAll
  void verifyContainerIsRunningAndReady() {
    assertTrue(
        POSTGRES.isRunning(), "PostgreSQL Testcontainer should be running for integration tests.");
    onContainerReady();
  }

  @DynamicPropertySource
  static void registerDatasourceProperties(DynamicPropertyRegistry registry) {

    // Spring may evaluate these properties very early (during condition checks) before
    // the Testcontainers JUnit extension starts @Container. Ensure it's running first.
    if (!POSTGRES.isRunning()) {
      POSTGRES.start();
    }

    // Datasource
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);

    // Optional: make driver explicit (Boot usually infers it fine)
    // registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
  }
}
