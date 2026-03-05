package com.example.platform.resource.exception;

import java.io.Serial;
import java.util.UUID;

public class ResourceNotFoundException extends RuntimeException {

  @Serial private static final long serialVersionUID = 1L;

  public ResourceNotFoundException(UUID id) {
    super("Resource not found: " + id);
  }
}
