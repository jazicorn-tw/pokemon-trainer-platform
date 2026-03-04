package com.pokedex.platform.trainer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pokedex.platform.PlatformApplication;
import com.pokedex.platform.testinfra.BaseIntegrationTest;
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
@SpringBootTest(classes = PlatformApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TrainerIntegrationTest extends BaseIntegrationTest {

  @Autowired private MockMvc mockMvc;
  @Autowired private TrainerRepository trainerRepository;

  private final ObjectMapper objectMapper = new ObjectMapper();

  @BeforeEach
  void cleanup() {
    trainerRepository.deleteAll();
  }

  @Test
  void createAndGetByIdFullRoundTrip() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/trainers")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"ash\",\"displayName\":\"Ash Ketchum\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.username").value("ash"))
            .andExpect(jsonPath("$.id").isNotEmpty())
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(get("/trainers/{id}", id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.username").value("ash"))
        .andExpect(jsonPath("$.displayName").value("Ash Ketchum"));
  }

  @Test
  void getAllReturnsAllCreatedTrainers() throws Exception {
    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ash\",\"displayName\":\"Ash\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"misty\",\"displayName\":\"Misty\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(get("/trainers"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void updateChangesDisplayName() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/trainers")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"ash\",\"displayName\":\"Old\"}"))
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(
            put("/trainers/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Champion Ash\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.displayName").value("Champion Ash"))
        .andExpect(jsonPath("$.username").value("ash"));
  }

  @Test
  void deleteRemovesTrainer() throws Exception {
    MvcResult created =
        mockMvc
            .perform(
                post("/trainers")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"ash\"}"))
            .andReturn();

    String id =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc.perform(delete("/trainers/{id}", id)).andExpect(status().isNoContent());
    mockMvc.perform(get("/trainers/{id}", id)).andExpect(status().isNotFound());
    assertThat(trainerRepository.count()).isZero();
  }

  @Test
  void createReturns409WhenUsernameDuplicate() throws Exception {
    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ash\"}"))
        .andExpect(status().isCreated());

    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ash\"}"))
        .andExpect(status().isConflict());
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    String randomId = UUID.randomUUID().toString();
    mockMvc.perform(get("/trainers/{id}", randomId)).andExpect(status().isNotFound());
  }
}
