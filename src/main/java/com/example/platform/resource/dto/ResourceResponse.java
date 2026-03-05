package com.example.platform.resource.dto;

import com.example.platform.resource.Resource;
import java.time.LocalDateTime;
import java.util.UUID;

public record ResourceResponse(
    UUID id, String username, String displayName, LocalDateTime createdAt) {

  public static ResourceResponse from(Resource resource) {
    return new ResourceResponse(
        resource.getId(),
        resource.getUsername(),
        resource.getDisplayName(),
        resource.getCreatedAt());
  }
}
