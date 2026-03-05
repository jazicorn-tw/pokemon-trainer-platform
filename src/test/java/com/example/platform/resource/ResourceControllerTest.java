package com.example.platform.resource;

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

import com.example.platform.resource.dto.ResourceResponse;
import com.example.platform.resource.exception.ResourceNotFoundException;
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
@WebMvcTest(ResourceController.class)
class ResourceControllerTest {

  @Autowired private MockMvc mockMvc;
  @MockitoBean private ResourceService resourceService;

  @Test
  void createReturns201WhenValidRequest() throws Exception {
    UUID id = UUID.randomUUID();
    when(resourceService.create(any()))
        .thenReturn(new ResourceResponse(id, "alice", "Alice Example", LocalDateTime.now()));

    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"alice\",\"displayName\":\"Alice Example\"}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.username").value("alice"))
        .andExpect(jsonPath("$.displayName").value("Alice Example"));
  }

  @Test
  void createReturns400WhenUsernameBlank() throws Exception {
    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createReturns400WhenUsernameTooShort() throws Exception {
    mockMvc
        .perform(
            post("/resources")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"ab\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void getByIdReturns200WhenFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(resourceService.getById(id))
        .thenReturn(new ResourceResponse(id, "alice", "Alice Example", LocalDateTime.now()));

    mockMvc
        .perform(get("/resources/{id}", id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.username").value("alice"));
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(resourceService.getById(id)).thenThrow(new ResourceNotFoundException(id));

    mockMvc.perform(get("/resources/{id}", id)).andExpect(status().isNotFound());
  }

  @Test
  void getAllReturns200WithList() throws Exception {
    when(resourceService.getAll())
        .thenReturn(
            List.of(
                new ResourceResponse(UUID.randomUUID(), "alice", "alice", LocalDateTime.now()),
                new ResourceResponse(UUID.randomUUID(), "bob_jones", "bob", LocalDateTime.now())));

    mockMvc
        .perform(get("/resources"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void updateReturns200WhenFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(resourceService.update(eq(id), any()))
        .thenReturn(new ResourceResponse(id, "alice", "Champion Ash", LocalDateTime.now()));

    mockMvc
        .perform(
            put("/resources/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Champion Ash\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.displayName").value("Champion Ash"));
  }

  @Test
  void updateReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    when(resourceService.update(eq(id), any())).thenThrow(new ResourceNotFoundException(id));

    mockMvc
        .perform(
            put("/resources/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"displayName\":\"Name\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void deleteReturns204WhenFound() throws Exception {
    UUID id = UUID.randomUUID();

    mockMvc.perform(delete("/resources/{id}", id)).andExpect(status().isNoContent());
  }

  @Test
  void deleteReturns404WhenNotFound() throws Exception {
    UUID id = UUID.randomUUID();
    doThrow(new ResourceNotFoundException(id)).when(resourceService).delete(id);

    mockMvc.perform(delete("/resources/{id}", id)).andExpect(status().isNotFound());
  }
}
