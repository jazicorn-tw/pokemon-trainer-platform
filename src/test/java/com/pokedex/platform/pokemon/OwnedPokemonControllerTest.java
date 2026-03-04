package com.pokedex.platform.pokemon;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.pokedex.platform.pokemon.dto.OwnedPokemonResponse;
import com.pokedex.platform.pokemon.exception.OwnedPokemonNotFoundException;
import com.pokedex.platform.trainer.exception.TrainerNotFoundException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@SuppressWarnings({"PMD.JUnitTestsShouldIncludeAssert", "PMD.AvoidDuplicateLiterals"})
@WebMvcTest(OwnedPokemonController.class)
class OwnedPokemonControllerTest {

  @Autowired private MockMvc mockMvc;
  @MockitoBean private OwnedPokemonService pokemonService;

  private static OwnedPokemonResponse sampleResponse(UUID trainerId, UUID id) {
    return new OwnedPokemonResponse(
        id,
        trainerId,
        "pikachu",
        null,
        "Pika",
        5,
        false,
        PokemonStatus.ACTIVE,
        LocalDateTime.now());
  }

  @Test
  void addReturns201WhenValidRequest() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonService.add(eq(trainerId), any())).thenReturn(sampleResponse(trainerId, pokemonId));

    mockMvc
        .perform(
            post("/trainers/{trainerId}/pokemon", trainerId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"speciesName\":\"pikachu\",\"nickname\":\"Pika\",\"level\":5}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.speciesName").value("pikachu"))
        .andExpect(jsonPath("$.status").value("ACTIVE"));
  }

  @Test
  void addReturns400WhenSpeciesNameBlank() throws Exception {
    UUID trainerId = UUID.randomUUID();

    mockMvc
        .perform(
            post("/trainers/{trainerId}/pokemon", trainerId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"speciesName\":\"\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void addReturns404WhenTrainerNotFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    when(pokemonService.add(eq(trainerId), any()))
        .thenThrow(new TrainerNotFoundException(trainerId));

    mockMvc
        .perform(
            post("/trainers/{trainerId}/pokemon", trainerId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"speciesName\":\"bulbasaur\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void getAllReturns200WithList() throws Exception {
    UUID trainerId = UUID.randomUUID();
    when(pokemonService.getAllForTrainer(trainerId))
        .thenReturn(
            List.of(
                sampleResponse(trainerId, UUID.randomUUID()),
                sampleResponse(trainerId, UUID.randomUUID())));

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon", trainerId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void getByIdReturns200WhenFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonService.getById(trainerId, pokemonId))
        .thenReturn(sampleResponse(trainerId, pokemonId));

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.speciesName").value("pikachu"));
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonService.getById(trainerId, pokemonId))
        .thenThrow(new OwnedPokemonNotFoundException(pokemonId));

    mockMvc
        .perform(get("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isNotFound());
  }

  @Test
  void updateReturns200WhenFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonService.update(eq(trainerId), eq(pokemonId), any()))
        .thenReturn(sampleResponse(trainerId, pokemonId));

    mockMvc
        .perform(
            put("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nickname\":\"Sparky\",\"level\":10}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.speciesName").value("pikachu"));
  }

  @Test
  void updateReturns404WhenNotFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonService.update(eq(trainerId), eq(pokemonId), any()))
        .thenThrow(new OwnedPokemonNotFoundException(pokemonId));

    mockMvc
        .perform(
            put("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nickname\":\"Sparky\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void deleteReturns204WhenFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();

    mockMvc
        .perform(delete("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isNoContent());
  }

  @Test
  void deleteReturns404WhenNotFound() throws Exception {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    doThrow(new OwnedPokemonNotFoundException(pokemonId))
        .when(pokemonService)
        .delete(trainerId, pokemonId);

    mockMvc
        .perform(delete("/trainers/{trainerId}/pokemon/{id}", trainerId, pokemonId))
        .andExpect(status().isNotFound());
  }
}
