package com.example.platform.resource.dto;

import jakarta.validation.constraints.Size;

public record UpdateResourceRequest(@Size(max = 100) String displayName) {}
