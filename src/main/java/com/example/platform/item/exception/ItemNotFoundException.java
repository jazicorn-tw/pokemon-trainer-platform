package com.example.platform.item.exception;

import java.io.Serial;
import java.util.UUID;

public class ItemNotFoundException extends RuntimeException {

  @Serial private static final long serialVersionUID = 1L;

  public ItemNotFoundException(UUID id) {
    super("Item not found: " + id);
  }
}
