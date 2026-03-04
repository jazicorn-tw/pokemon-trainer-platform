package com.pokedex.platform.pokemon;

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
import com.pokedex.platform.trainer.TrainerRepository;
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
class OwnedPokemonIntegrationTest extends BaseIntegrationTest {

  @Autowired private MockMvc mockMvc;
  @Autowired private TrainerRepository trainerRepository;
  @Autowired private OwnedPokemonRepository pokemonRepository;

  private final ObjectMapper objectMapper = new ObjectMapper();

  @BeforeEach
  void cleanup() {
    pokemonRepository.deleteAll();
    trainerRepository.deleteAll();
  }

  private String createTrainer(String username) throws Exception {
    MvcResult result =
        mockMvc
            .perform(
                post("/trainers")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"" + username + "\"}"))
            .andExpect(status().isCreated())
            .andReturn();
    return objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
  }

  private String addPokemon(String trainerId, String speciesName) throws Exception {
    MvcResult result =
        mockMvc
            .perform(
                post("/trainers/{trainerId}/pokemon", trainerId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"speciesName\":\"" + speciesName + "\"}"))
            .andExpect(status().isCreated())
            .andReturn();
    return objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
  }

  @Test
  void addAndGetByIdFullRoundTrip() throws Exception {
    String trainerId = createTrainer("ash");

    MvcResult created =
        mockMvc
            .perform(
                post("/trainers/{trainerId}/pokemon", trainerId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        "{\"speciesName\":\"pikachu\",\"nickname\":\"Pika\",\"level\":5,\"shiny\":false}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.speciesName").value("pikachu"))
            .andExpect(jsonPath("$.nickname").value("Pika"))
            .andExpect(jsonPath("$.level").value(5))
            .andExpect(jsonPath("$.status").value("ACTIVE"))
            .andExpect(jsonPath("$.trainerId").value(trainerId))
            .andExpect(jsonPath("$.id").isNotEmpty())
            .andReturn();

    String pokemonId =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.speciesName").value("pikachu"));
  }

  @Test
  void getAllReturnsAllPokemonForTrainer() throws Exception {
    String trainerId = createTrainer("ash");
    addPokemon(trainerId, "pikachu");
    addPokemon(trainerId, "charmander");

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon", trainerId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void getAllReturnsEmptyListForTrainerWithNoPokemon() throws Exception {
    String trainerId = createTrainer("misty");

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon", trainerId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(0));
  }

  @Test
  void updateChangesNicknameAndLevel() throws Exception {
    String trainerId = createTrainer("ash");
    String pokemonId = addPokemon(trainerId, "pikachu");

    mockMvc
        .perform(
            put("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nickname\":\"Sparky\",\"level\":20}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.nickname").value("Sparky"))
        .andExpect(jsonPath("$.level").value(20));
  }

  @Test
  void deleteRemovesPokemon() throws Exception {
    String trainerId = createTrainer("ash");
    String pokemonId = addPokemon(trainerId, "pikachu");

    mockMvc
        .perform(delete("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isNoContent());

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isNotFound());

    assertThat(pokemonRepository.count()).isZero();
  }

  @Test
  void addReturns404WhenTrainerNotFound() throws Exception {
    String unknownTrainerId = UUID.randomUUID().toString();

    mockMvc
        .perform(
            post("/trainers/{trainerId}/pokemon", unknownTrainerId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"speciesName\":\"pikachu\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    String trainerId = createTrainer("ash");
    String unknownId = UUID.randomUUID().toString();

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon/{id}", trainerId, unknownId))
        .andExpect(status().isNotFound());
  }

  @Test
  void addDefaultsLevelToOne() throws Exception {
    String trainerId = createTrainer("ash");

    mockMvc
        .perform(
            post("/trainers/{trainerId}/pokemon", trainerId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"speciesName\":\"bulbasaur\"}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.level").value(1))
        .andExpect(jsonPath("$.shiny").value(false));
  }

  @Test
  void pokemonDeletedWhenTrainerDeleted() throws Exception {
    String trainerId = createTrainer("ash");
    addPokemon(trainerId, "pikachu");
    addPokemon(trainerId, "charmander");

    mockMvc.perform(delete("/trainers/{id}", trainerId)).andExpect(status().isNoContent());

    assertThat(pokemonRepository.count()).isZero();
  }
}
