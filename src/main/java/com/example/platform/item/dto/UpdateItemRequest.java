package com.example.platform.item.dto;

import com.example.platform.item.ItemStatus;
import jakarta.validation.constraints.Size;

public record UpdateItemRequest(
    @Size(max = 50) String label,
    Integer level,
    Integer externalId,
    Boolean shiny,
    ItemStatus status) {}
