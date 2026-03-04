package com.pokedex.platform.trainer.dto;

import jakarta.validation.constraints.Size;

public record UpdateTrainerRequest(@Size(max = 100) String displayName) {}
