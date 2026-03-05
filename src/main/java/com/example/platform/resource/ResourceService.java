package com.example.platform.resource;

import com.example.platform.resource.dto.CreateResourceRequest;
import com.example.platform.resource.dto.ResourceResponse;
import com.example.platform.resource.dto.UpdateResourceRequest;
import com.example.platform.resource.exception.ResourceNotFoundException;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ResourceService {

  private final ResourceRepository resourceRepository;

  ResourceService(ResourceRepository resourceRepository) {
    this.resourceRepository = resourceRepository;
  }

  @Transactional
  public ResourceResponse create(CreateResourceRequest request) {
    Resource resource = new Resource(request.username(), request.displayName());
    return ResourceResponse.from(resourceRepository.save(resource));
  }

  public ResourceResponse getById(UUID id) {
    return resourceRepository
        .findById(id)
        .map(ResourceResponse::from)
        .orElseThrow(() -> new ResourceNotFoundException(id));
  }

  public List<ResourceResponse> getAll() {
    return resourceRepository.findAll().stream().map(ResourceResponse::from).toList();
  }

  @Transactional
  public ResourceResponse update(UUID id, UpdateResourceRequest request) {
    Resource resource =
        resourceRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException(id));
    resource.setDisplayName(request.displayName());
    return ResourceResponse.from(resourceRepository.save(resource));
  }

  @Transactional
  public void delete(UUID id) {
    if (!resourceRepository.existsById(id)) {
      throw new ResourceNotFoundException(id);
    }
    resourceRepository.deleteById(id);
  }
}
