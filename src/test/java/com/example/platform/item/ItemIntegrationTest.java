package com.example.platform.item;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.example.platform.Application;
import com.example.platform.resource.ResourceRepository;
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
class ItemIntegrationTest extends AbstractIntegrationTest {

  @Autowired private MockMvc mockMvc;
  @Autowired private ResourceRepository resourceRepository;
  @Autowired private ItemRepository itemRepository;

  private final ObjectMapper objectMapper = new ObjectMapper();

  @BeforeEach
  void cleanup() {
    itemRepository.deleteAll();
    resourceRepository.deleteAll();
  }

  private String createResource(String username) throws Exception {
    MvcResult result =
        mockMvc
            .perform(
                post("/resources")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"username\":\"" + username + "\"}"))
            .andExpect(status().isCreated())
            .andReturn();
    return objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
  }

  private String addItem(String resourceId, String itemName) throws Exception {
    MvcResult result =
        mockMvc
            .perform(
                post("/resources/{resourceId}/item", resourceId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"itemName\":\"" + itemName + "\"}"))
            .andExpect(status().isCreated())
            .andReturn();
    return objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
  }

  @Test
  void addAndGetByIdFullRoundTrip() throws Exception {
    String resourceId = createResource("alice");

    MvcResult created =
        mockMvc
            .perform(
                post("/resources/{resourceId}/item", resourceId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        "{\"itemName\":\"item-alpha\",\"label\":\"Pika\",\"level\":5,\"shiny\":false}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.itemName").value("item-alpha"))
            .andExpect(jsonPath("$.label").value("Pika"))
            .andExpect(jsonPath("$.level").value(5))
            .andExpect(jsonPath("$.status").value("ACTIVE"))
            .andExpect(jsonPath("$.resourceId").value(resourceId))
            .andExpect(jsonPath("$.id").isNotEmpty())
            .andReturn();

    String itemId =
        objectMapper.readTree(created.getResponse().getContentAsString()).get("id").asText();

    mockMvc
        .perform(get("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.itemName").value("item-alpha"));
  }

  @Test
  void getAllReturnsAllItemForResource() throws Exception {
    String resourceId = createResource("alice");
    addItem(resourceId, "item-alpha");
    addItem(resourceId, "item-beta");

    mockMvc
        .perform(get("/resources/{resourceId}/item", resourceId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(2));
  }

  @Test
  void getAllReturnsEmptyListForResourceWithNoItem() throws Exception {
    String resourceId = createResource("bob_jones");

    mockMvc
        .perform(get("/resources/{resourceId}/item", resourceId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.length()").value(0));
  }

  @Test
  void updateChangesNicknameAndLevel() throws Exception {
    String resourceId = createResource("alice");
    String itemId = addItem(resourceId, "item-alpha");

    mockMvc
        .perform(
            put("/resources/{resourceId}/item/{id}", resourceId, itemId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"label\":\"Sparky\",\"level\":20}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.label").value("Sparky"))
        .andExpect(jsonPath("$.level").value(20));
  }

  @Test
  void updateChangesStatusAndExternalId() throws Exception {
    String resourceId = createResource("alice");
    String itemId = addItem(resourceId, "item-alpha");

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
  void deleteRemovesItem() throws Exception {
    String resourceId = createResource("alice");
    String itemId = addItem(resourceId, "item-alpha");

    mockMvc
        .perform(delete("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isNoContent());

    mockMvc
        .perform(get("/resources/{resourceId}/item/{id}", resourceId, itemId))
        .andExpect(status().isNotFound());

    assertThat(itemRepository.count()).isZero();
  }

  @Test
  void addReturns404WhenResourceNotFound() throws Exception {
    String unknownResourceId = UUID.randomUUID().toString();

    mockMvc
        .perform(
            post("/resources/{resourceId}/item", unknownResourceId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"itemName\":\"item-alpha\"}"))
        .andExpect(status().isNotFound());
  }

  @Test
  void getByIdReturns404WhenNotFound() throws Exception {
    String resourceId = createResource("alice");
    String unknownId = UUID.randomUUID().toString();

    mockMvc
        .perform(get("/resources/{resourceId}/item/{id}", resourceId, unknownId))
        .andExpect(status().isNotFound());
  }

  @Test
  void addDefaultsLevelToOne() throws Exception {
    String resourceId = createResource("alice");

    mockMvc
        .perform(
            post("/resources/{resourceId}/item", resourceId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"itemName\":\"item-gamma\"}"))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.level").value(1))
        .andExpect(jsonPath("$.shiny").value(false));
  }

  @Test
  void itemDeletedWhenResourceDeleted() throws Exception {
    String resourceId = createResource("alice");
    addItem(resourceId, "item-alpha");
    addItem(resourceId, "item-beta");

    mockMvc.perform(delete("/resources/{id}", resourceId)).andExpect(status().isNoContent());

    assertThat(itemRepository.count()).isZero();
  }
}
