package com.example.platform.item.dto;

import com.example.platform.item.Item;
import com.example.platform.item.ItemStatus;
import java.time.LocalDateTime;
import java.util.UUID;

public record ItemResponse(
    UUID id,
    UUID resourceId,
    String itemName,
    Integer externalId,
    String label,
    int level,
    boolean shiny,
    ItemStatus status,
    LocalDateTime acquiredAt) {

  public static ItemResponse from(Item item) {
    return new ItemResponse(
        item.getId(),
        item.getResourceId(),
        item.getSpeciesName(),
        item.getExternalId(),
        item.getNickname(),
        item.getLevel(),
        item.isShiny(),
        item.getStatus(),
        item.getAcquiredAt());
  }
}
