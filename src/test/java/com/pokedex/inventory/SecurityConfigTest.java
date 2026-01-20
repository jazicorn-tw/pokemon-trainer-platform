package com.pokedex.inventory;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest(
    properties = {
      // This test validates security rules for public endpoints.
      // It must NOT require a database or Flyway to run.
      "spring.autoconfigure.exclude="
          + "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,"
          + "org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration,"
          + "org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration"
    })
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityConfigTest {

  @Autowired private MockMvc mockMvc;

  @Test
  void pingIsPublicReturns200() throws Exception {
    MvcResult result = mockMvc.perform(get("/ping")).andExpect(status().isOk()).andReturn();

    assertEquals(
        200, result.getResponse().getStatus(), "GET /ping should be public and return HTTP 200");
  }

  @Test
  void actuatorHealthIsPublicReturns200() throws Exception {
    MvcResult result =
        mockMvc.perform(get("/actuator/health")).andExpect(status().isOk()).andReturn();

    assertEquals(
        200,
        result.getResponse().getStatus(),
        "GET /actuator/health should be public and return HTTP 200");
  }
}
