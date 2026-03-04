package com.pokedex.platform.trainer.exception;

import java.io.Serial;
import java.util.UUID;

public class TrainerNotFoundException extends RuntimeException {

  @Serial private static final long serialVersionUID = 1L;

  public TrainerNotFoundException(UUID id) {
    super("Trainer not found: " + id);
  }
}
