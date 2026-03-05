package com.example.platform;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.example.platform.testinfra.AbstractIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ActiveProfiles;

/**
 * Smoke test: verifies the full Spring Boot application context boots under the {@code test}
 * profile.
 *
 * <p>This is an integration test (requires PostgreSQL via Testcontainers). It intentionally extends
 * {@link AbstractIntegrationTest} so the datasource is provided by the shared Testcontainers setup.
 *
 * <p>Note: We explicitly point {@code @SpringBootTest} at the application class to avoid "can't
 * locate @SpringBootConfiguration" failures if package structure changes.
 */
@SpringBootTest(classes = Application.class)
@ActiveProfiles("test")
class ApplicationTest extends AbstractIntegrationTest {

  @Autowired private ApplicationContext applicationContext;

  @Override
  protected void onContainerReady() {
    // No-op for now.
    // Hook reserved for future integration-test setup or verification.
  }

  @Test
  void contextLoads() {
    assertNotNull(
        applicationContext,
        "Spring application context should load successfully for integration tests.");
  }
}
