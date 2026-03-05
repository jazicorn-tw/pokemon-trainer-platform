package com.example.platform.item;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.example.platform.item.dto.AddItemRequest;
import com.example.platform.item.dto.ItemResponse;
import com.example.platform.item.dto.UpdateItemRequest;
import com.example.platform.item.exception.ItemNotFoundException;
import com.example.platform.resource.ResourceRepository;
import com.example.platform.resource.exception.ResourceNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@SuppressWarnings({"PMD.JUnitTestContainsTooManyAsserts", "PMD.AvoidDuplicateLiterals"})
@ExtendWith(MockitoExtension.class)
class ItemServiceTest {

  @Mock private ItemRepository itemRepository;
  @Mock private ResourceRepository resourceRepository;
  @InjectMocks private ItemService itemService;

  @Test
  void addSavesAndReturnsResponse() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var request = new AddItemRequest("item-alpha", null, "Pika", 5, false);
    var saved = new Item(itemId, resourceId, "item-alpha", 5, ItemStatus.ACTIVE);

    when(resourceRepository.existsById(resourceId)).thenReturn(true);
    when(itemRepository.save(any(Item.class))).thenReturn(saved);

    ItemResponse response = itemService.add(resourceId, request);

    assertThat(response.itemName()).isEqualTo("item-alpha");
    assertThat(response.status()).isEqualTo(ItemStatus.ACTIVE);
    assertThat(response.id()).isNotNull();
  }

  @Test
  void addThrowsResourceNotFoundWhenResourceMissing() {
    UUID resourceId = UUID.randomUUID();
    when(resourceRepository.existsById(resourceId)).thenReturn(false);

    assertThatThrownBy(
            () ->
                itemService.add(
                    resourceId, new AddItemRequest("item-alpha", null, null, null, null)))
        .isInstanceOf(ResourceNotFoundException.class);
  }

  @Test
  void addDefaultsLevelToOneWhenNull() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var request = new AddItemRequest("item-beta", null, null, null, null);
    var saved = new Item(itemId, resourceId, "item-beta", 1, ItemStatus.ACTIVE);

    when(resourceRepository.existsById(resourceId)).thenReturn(true);
    when(itemRepository.save(any(Item.class))).thenReturn(saved);

    ItemResponse response = itemService.add(resourceId, request);

    assertThat(response.level()).isEqualTo(1);
  }

  @Test
  void getByIdReturnsResponseWhenFound() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var item = new Item(itemId, resourceId, "item-alpha", 5, ItemStatus.ACTIVE);
    when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

    ItemResponse response = itemService.getById(resourceId, itemId);

    assertThat(response.itemName()).isEqualTo("item-alpha");
  }

  @Test
  void getByIdThrowsNotFoundWhenMissing() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemRepository.findById(itemId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> itemService.getById(resourceId, itemId))
        .isInstanceOf(ItemNotFoundException.class);
  }

  @Test
  void getByIdThrowsNotFoundWhenResourceMismatch() {
    UUID resourceId = UUID.randomUUID();
    UUID otherResourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var item = new Item(itemId, otherResourceId, "item-alpha", 5, ItemStatus.ACTIVE);
    when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

    assertThatThrownBy(() -> itemService.getById(resourceId, itemId))
        .isInstanceOf(ItemNotFoundException.class);
  }

  @Test
  void getAllForResourceReturnsAllItem() {
    UUID resourceId = UUID.randomUUID();
    when(itemRepository.findAllByResourceId(resourceId))
        .thenReturn(
            List.of(
                new Item(UUID.randomUUID(), resourceId, "item-alpha", 5, ItemStatus.ACTIVE),
                new Item(UUID.randomUUID(), resourceId, "item-beta", 3, ItemStatus.ACTIVE)));

    List<ItemResponse> responses = itemService.getAllForResource(resourceId);

    assertThat(responses).hasSize(2);
  }

  @Test
  void updateUpdatesNicknameAndLevelAndReturnsResponse() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var item = new Item(itemId, resourceId, "item-alpha", 5, ItemStatus.ACTIVE);
    when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));
    when(itemRepository.save(item)).thenReturn(item);

    ItemResponse response =
        itemService.update(
            resourceId, itemId, new UpdateItemRequest("Sparky", 10, null, null, null));

    assertThat(response.level()).isEqualTo(10);
  }

  @Test
  void updateUpdatesExternalIdAndStatus() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var item = new Item(itemId, resourceId, "item-alpha", 5, ItemStatus.ACTIVE);
    when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));
    when(itemRepository.save(item)).thenReturn(item);

    ItemResponse response =
        itemService.update(
            resourceId,
            itemId,
            new UpdateItemRequest(null, null, 25, true, ItemStatus.TRANSFERRED));

    assertThat(response.externalId()).isEqualTo(25);
    assertThat(response.shiny()).isTrue();
    assertThat(response.status()).isEqualTo(ItemStatus.TRANSFERRED);
  }

  @Test
  void updateThrowsNotFoundWhenMissing() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemRepository.findById(itemId)).thenReturn(Optional.empty());

    assertThatThrownBy(
            () ->
                itemService.update(
                    resourceId, itemId, new UpdateItemRequest(null, null, null, null, null)))
        .isInstanceOf(ItemNotFoundException.class);
  }

  @Test
  void deleteCallsDeleteByIdWhenExists() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    var item = new Item(itemId, resourceId, "item-alpha", 5, ItemStatus.ACTIVE);
    when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

    itemService.delete(resourceId, itemId);

    verify(itemRepository).deleteById(itemId);
  }

  @Test
  void deleteThrowsNotFoundWhenMissing() {
    UUID resourceId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();
    when(itemRepository.findById(itemId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> itemService.delete(resourceId, itemId))
        .isInstanceOf(ItemNotFoundException.class);
  }
}
