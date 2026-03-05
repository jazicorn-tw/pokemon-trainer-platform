package com.example.platform.resource;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.example.platform.resource.dto.CreateResourceRequest;
import com.example.platform.resource.dto.ResourceResponse;
import com.example.platform.resource.dto.UpdateResourceRequest;
import com.example.platform.resource.exception.ResourceNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@SuppressWarnings({"PMD.JUnitTestContainsTooManyAsserts", "PMD.AvoidDuplicateLiterals"})
@ExtendWith(MockitoExtension.class)
class ResourceServiceTest {

  @Mock private ResourceRepository resourceRepository;
  @InjectMocks private ResourceService resourceService;

  @Test
  void createSavesAndReturnsResponse() {
    var request = new CreateResourceRequest("alice", "Alice Example");
    var saved = new Resource(UUID.randomUUID(), "alice", "Alice Example");
    when(resourceRepository.save(any(Resource.class))).thenReturn(saved);

    ResourceResponse response = resourceService.create(request);

    assertThat(response.username()).isEqualTo("alice");
    assertThat(response.displayName()).isEqualTo("Alice Example");
    assertThat(response.id()).isNotNull();
  }

  @Test
  void getByIdReturnsResponseWhenFound() {
    UUID id = UUID.randomUUID();
    when(resourceRepository.findById(id))
        .thenReturn(Optional.of(new Resource(id, "alice", "alice")));

    ResourceResponse response = resourceService.getById(id);

    assertThat(response.username()).isEqualTo("alice");
  }

  @Test
  void getByIdThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(resourceRepository.findById(id)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> resourceService.getById(id))
        .isInstanceOf(ResourceNotFoundException.class);
  }

  @Test
  void getAllReturnsAllResources() {
    when(resourceRepository.findAll())
        .thenReturn(
            List.of(
                new Resource(UUID.randomUUID(), "alice", "alice"),
                new Resource(UUID.randomUUID(), "bob_jones", "bob")));

    List<ResourceResponse> responses = resourceService.getAll();

    assertThat(responses).hasSize(2);
  }

  @Test
  void updateUpdatesDisplayNameAndReturnsResponse() {
    UUID id = UUID.randomUUID();
    var resource = new Resource(id, "alice", "Old Name");
    when(resourceRepository.findById(id)).thenReturn(Optional.of(resource));
    when(resourceRepository.save(resource)).thenReturn(resource);

    ResourceResponse response = resourceService.update(id, new UpdateResourceRequest("New Name"));

    assertThat(response.displayName()).isEqualTo("New Name");
  }

  @Test
  void updateThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(resourceRepository.findById(id)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> resourceService.update(id, new UpdateResourceRequest("Name")))
        .isInstanceOf(ResourceNotFoundException.class);
  }

  @Test
  void deleteCallsDeleteByIdWhenExists() {
    UUID id = UUID.randomUUID();
    when(resourceRepository.existsById(id)).thenReturn(true);

    resourceService.delete(id);

    verify(resourceRepository).deleteById(id);
  }

  @Test
  void deleteThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(resourceRepository.existsById(id)).thenReturn(false);

    assertThatThrownBy(() -> resourceService.delete(id))
        .isInstanceOf(ResourceNotFoundException.class);
  }
}
