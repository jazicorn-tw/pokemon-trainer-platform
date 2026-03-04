package com.pokedex.platform.trainer.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateTrainerRequest(
    @NotBlank @Size(min = 3, max = 50) String username, @Size(max = 100) String displayName) {}
