package com.example.platform.resource;

import com.example.platform.resource.dto.CreateResourceRequest;
import com.example.platform.resource.dto.ResourceResponse;
import com.example.platform.resource.dto.UpdateResourceRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/resources")
public class ResourceController {

  private final ResourceService resourceService;

  ResourceController(ResourceService resourceService) {
    this.resourceService = resourceService;
  }

  @PostMapping
  ResponseEntity<ResourceResponse> create(@Valid @RequestBody CreateResourceRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(resourceService.create(request));
  }

  @GetMapping("/{id}")
  ResponseEntity<ResourceResponse> getById(@PathVariable UUID id) {
    return ResponseEntity.ok(resourceService.getById(id));
  }

  @GetMapping
  ResponseEntity<List<ResourceResponse>> getAll() {
    return ResponseEntity.ok(resourceService.getAll());
  }

  @PutMapping("/{id}")
  ResponseEntity<ResourceResponse> update(
      @PathVariable UUID id, @Valid @RequestBody UpdateResourceRequest request) {
    return ResponseEntity.ok(resourceService.update(id, request));
  }

  @DeleteMapping("/{id}")
  ResponseEntity<Void> delete(@PathVariable UUID id) {
    resourceService.delete(id);
    return ResponseEntity.noContent().build();
  }
}
