package com.example.platform.resource;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.example.platform.Application;
import com.example.platform.testinfra.AbstractIntegrationTest;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SuppressWarnings({"PMD.JUnitTestsShouldIncludeAssert", "PMD.AvoidDuplicateLiterals"})
@SpringBootTest(classes = Application.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ResourceIntegrationTest extends AbstractIntegrationTest {

  @Autowired private MockMvc mockMvc;
  @Autowired private ResourceRepository resourceRepository;

  private final ObjectMapper objectMapper = new ObjectMapper();

  @BeforeEach
  void cleanup() {
    resourceRepository.deleteAll();
  }

  @Test
  void createAndGetByIdFullRoundTrip() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/resources")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"alice\",\"displayName\":\"Alice Example\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.username").value("alice"))
            .andExpect(jsonPath("$.id").isNotEmpty())
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(get("/resources/{id}", id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.username").value("alice"))
        .andExpect(jsonPath("$.displayName").value("Alice Example"));
  }

  @Test
  void getAllReturnsAllCreatedResources() throws Exception {
    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"alice\",\"displayName\":\"Ash\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"misty\",\"displayName\":\"Misty\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(get("/resources"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void updateChangesDisplayName() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/resources")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"alice\",\"displayName\":\"Old\"}"))
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(
            put("/resources/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Champion Ash\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.displayName").value("Champion Ash"))
        .andExpect(jsonPath("$.username").value("alice"));
  }

  @Test
  void deleteRemovesResource() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/resources")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"alice\"}"))
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc.perform(delete("/resources/{id}", id)).andExpect(status().isNoContent());
    mockMvc.perform(get("/resources/{id}", id)).andExpect(status().isNotFound());
    assertThat(resourceRepository.count()).isZero();
  }

  @Test
  void createReturns409WhenUsernameDuplicate() throws Exception {
    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"alice\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"alice\"}"))
        .andExpect(status().isConflict());
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    String randomId = UUID.randomUUID().toString();
    mockMvc.perform(get("/resources/{id}", randomId)).andExpect(status().isNotFound());
  }
}
