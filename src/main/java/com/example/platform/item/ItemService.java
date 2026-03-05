package com.example.platform.item;

import com.example.platform.item.dto.AddItemRequest;
import com.example.platform.item.dto.ItemResponse;
import com.example.platform.item.dto.UpdateItemRequest;
import com.example.platform.item.exception.ItemNotFoundException;
import com.example.platform.resource.ResourceRepository;
import com.example.platform.resource.exception.ResourceNotFoundException;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ItemService {

  private final ItemRepository itemRepository;
  private final ResourceRepository resourceRepository;

  ItemService(ItemRepository itemRepository, ResourceRepository resourceRepository) {
    this.itemRepository = itemRepository;
    this.resourceRepository = resourceRepository;
  }

  @Transactional
  public ItemResponse add(UUID resourceId, AddItemRequest request) {
    if (!resourceRepository.existsById(resourceId)) {
      throw new ResourceNotFoundException(resourceId);
    }
    Item item =
        new Item(
            resourceId,
            request.itemName(),
            request.externalId(),
            request.label(),
            request.level() != null ? request.level() : 1,
            Boolean.TRUE.equals(request.shiny()));
    return ItemResponse.from(itemRepository.save(item));
  }

  public ItemResponse getById(UUID resourceId, UUID id) {
    Item item = itemRepository.findById(id).orElseThrow(() -> new ItemNotFoundException(id));
    if (!item.getResourceId().equals(resourceId)) {
      throw new ItemNotFoundException(id);
    }
    return ItemResponse.from(item);
  }

  public List<ItemResponse> getAllForResource(UUID resourceId) {
    return itemRepository.findAllByResourceId(resourceId).stream().map(ItemResponse::from).toList();
  }

  @Transactional
  public ItemResponse update(UUID resourceId, UUID id, UpdateItemRequest request) {
    Item item = itemRepository.findById(id).orElseThrow(() -> new ItemNotFoundException(id));
    if (!item.getResourceId().equals(resourceId)) {
      throw new ItemNotFoundException(id);
    }
    if (request.label() != null) {
      item.setNickname(request.label());
    }
    if (request.level() != null) {
      item.setLevel(request.level());
    }
    if (request.externalId() != null) {
      item.setExternalId(request.externalId());
    }
    if (request.shiny() != null) {
      item.setShiny(request.shiny());
    }
    if (request.status() != null) {
      item.setStatus(request.status());
    }
    return ItemResponse.from(itemRepository.save(item));
  }

  @Transactional
  public void delete(UUID resourceId, UUID id) {
    Item item = itemRepository.findById(id).orElseThrow(() -> new ItemNotFoundException(id));
    if (!item.getResourceId().equals(resourceId)) {
      throw new ItemNotFoundException(id);
    }
    itemRepository.deleteById(id);
  }
}
