package com.example.platform.item;

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

import com.example.platform.item.dto.ItemResponse;
import com.example.platform.item.exception.ItemNotFoundException;
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
@WebMvcTest(ItemController.class)
class ItemControllerTest {

  @Autowired private MockMvc mockMvc;
  @MockitoBean private ItemService itemService;

  private static ItemResponse sampleResponse(UUID resourceId, UUID id) {
    return new ItemResponse(
        id,
        resourceId,
        "item-alpha",
        null,
        "Pika",
        5,
        false,
        ItemStatus.ACTIVE,
        LocalDateTime.now());
  }

  @Test
  void addReturns201WhenValidRequest() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemService.add(eq(resourceId), any())).thenReturn(sampleResponse(resourceId, itemId));

    mockMvc
        .perform(
            post("/resources/{resourceId}/item", resourceId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"itemName\":\"item-alpha\",\"label\":\"Pika\",\"level\":5}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.itemName").value("item-alpha"))
        .andExpect(jsonPath("$.status").value("ACTIVE"));
  }

  @Test
  void addReturns400WhenSpeciesNameBlank() throws Exception {
    UUID resourceId = UUID.randomUUID();

    mockMvc
        .perform(
            post("/resources/{resourceId}/item", resourceId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"itemName\":\"\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void addReturns404WhenResourceNotFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    when(itemService.add(eq(resourceId), any()))
        .thenThrow(new ResourceNotFoundException(resourceId));

    mockMvc
        .perform(
            post("/resources/{resourceId}/item", resourceId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"itemName\":\"item-gamma\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void getAllReturns200WithList() throws Exception {
    UUID resourceId = UUID.randomUUID();
    when(itemService.getAllForResource(resourceId))
        .thenReturn(
            List.of(
                sampleResponse(resourceId, UUID.randomUUID()),
                sampleResponse(resourceId, UUID.randomUUID())));

    mockMvc
        .perform(get("/resources/{resourceId}/item", resourceId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void getByIdReturns200WhenFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemService.getById(resourceId, itemId)).thenReturn(sampleResponse(resourceId, itemId));

    mockMvc
        .perform(get("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.itemName").value("item-alpha"));
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemService.getById(resourceId, itemId)).thenThrow(new ItemNotFoundException(itemId));

    mockMvc
        .perform(get("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isNotFound());
  }

  @Test
  void updateReturns200WhenFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemService.update(eq(resourceId), eq(itemId), any()))
        .thenReturn(sampleResponse(resourceId, itemId));

    mockMvc
        .perform(
            put("/resources/{resourceId}/item/{id}", resourceId, itemId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"label\":\"Sparky\",\"level\":10}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.itemName").value("item-alpha"));
  }

  @Test
  void updateAcceptsExternalIdAndStatus() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var updated =
        new ItemResponse(
            itemId,
            resourceId,
            "item-alpha",
            25,
            "Sparky",
            10,
            true,
            ItemStatus.TRANSFERRED,
            LocalDateTime.now());
    when(itemService.update(eq(resourceId), eq(itemId), any())).thenReturn(updated);

    mockMvc
        .perform(
            put("/resources/{resourceId}/item/{id}", resourceId, itemId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"externalId\":25,\"shiny\":true,\"status\":\"TRANSFERRED\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.externalId").value(25))
        .andExpect(jsonPath("$.shiny").value(true))
        .andExpect(jsonPath("$.status").value("TRANSFERRED"));
  }

  @Test
  void updateReturns404WhenNotFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemService.update(eq(resourceId), eq(itemId), any()))
        .thenThrow(new ItemNotFoundException(itemId));

    mockMvc
        .perform(
            put("/resources/{resourceId}/item/{id}", resourceId, itemId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"label\":\"Sparky\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void deleteReturns204WhenFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();

    mockMvc
        .perform(delete("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isNoContent());
  }

  @Test
  void deleteReturns404WhenNotFound() throws Exception {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    doThrow(new ItemNotFoundException(itemId)).when(itemService).delete(resourceId, itemId);

    mockMvc
        .perform(delete("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isNotFound());
  }
}
