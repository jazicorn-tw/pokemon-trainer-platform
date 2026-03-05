package com.example.platform.item.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddItemRequest(
    @NotBlank @Size(max = 50) String itemName,
    Integer externalId,
    @Size(max = 50) String label,
    Integer level,
    Boolean shiny) {}
