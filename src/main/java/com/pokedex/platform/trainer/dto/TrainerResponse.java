package com.pokedex.platform.trainer.dto;

import com.pokedex.platform.trainer.Trainer;
import java.time.LocalDateTime;
import java.util.UUID;

public record TrainerResponse(
    UUID id, String username, String displayName, LocalDateTime createdAt) {

  public static TrainerResponse from(Trainer trainer) {
    return new TrainerResponse(
        trainer.getId(), trainer.getUsername(), trainer.getDisplayName(), trainer.getCreatedAt());
  }
}
