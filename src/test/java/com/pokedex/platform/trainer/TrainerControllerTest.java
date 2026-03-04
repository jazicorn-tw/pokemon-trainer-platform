package com.pokedex.platform.trainer;

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

import com.pokedex.platform.trainer.dto.TrainerResponse;
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
@WebMvcTest(TrainerController.class)
class TrainerControllerTest {

  @Autowired private MockMvc mockMvc;
  @MockitoBean private TrainerService trainerService;

  @Test
  void createReturns201WhenValidRequest() throws Exception {
    UUID id = UUID.randomUUID();
    when(trainerService.create(any()))
        .thenReturn(new TrainerResponse(id, "ash", "Ash Ketchum", LocalDateTime.now()));

    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ash\",\"displayName\":\"Ash Ketchum\"}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.username").value("ash"))
        .andExpect(jsonPath("$.displayName").value("Ash Ketchum"));
  }

  @Test
  void createReturns400WhenUsernameBlank() throws Exception {
    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createReturns400WhenUsernameTooShort() throws Exception {
    mockMvc
        .perform(
            post("/trainers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ab\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void getByIdReturns200WhenFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(trainerService.getById(id))
        .thenReturn(new TrainerResponse(id, "ash", "Ash Ketchum", LocalDateTime.now()));

    mockMvc
        .perform(get("/trainers/{id}", id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.username").value("ash"));
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(trainerService.getById(id)).thenThrow(new TrainerNotFoundException(id));

    mockMvc.perform(get("/trainers/{id}", id)).andExpect(status().isNotFound());
  }

  @Test
  void getAllReturns200WithList() throws Exception {
    when(trainerService.getAll())
        .thenReturn(
            List.of(
                new TrainerResponse(UUID.randomUUID(), "ash", "Ash", LocalDateTime.now()),
                new TrainerResponse(UUID.randomUUID(), "misty", "Misty", LocalDateTime.now())));

    mockMvc
        .perform(get("/trainers"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void updateReturns200WhenFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(trainerService.update(eq(id), any()))
        .thenReturn(new TrainerResponse(id, "ash", "Champion Ash", LocalDateTime.now()));

    mockMvc
        .perform(
            put("/trainers/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Champion Ash\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.displayName").value("Champion Ash"));
  }

  @Test
  void updateReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(trainerService.update(eq(id), any())).thenThrow(new TrainerNotFoundException(id));

    mockMvc
        .perform(
            put("/trainers/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Name\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void deleteReturns204WhenFound() throws Exception {
    UUID id = UUID.randomUUID();

    mockMvc.perform(delete("/trainers/{id}", id)).andExpect(status().isNoContent());
  }

  @Test
  void deleteReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    doThrow(new TrainerNotFoundException(id)).when(trainerService).delete(id);

    mockMvc.perform(delete("/trainers/{id}", id)).andExpect(status().isNotFound());
  }
}
