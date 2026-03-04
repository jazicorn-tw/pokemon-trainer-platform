package com.pokedex.platform.trainer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pokedex.platform.trainer.dto.CreateTrainerRequest;
import com.pokedex.platform.trainer.dto.TrainerResponse;
import com.pokedex.platform.trainer.dto.UpdateTrainerRequest;
import com.pokedex.platform.trainer.exception.TrainerNotFoundException;
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
class TrainerServiceTest {

  @Mock private TrainerRepository trainerRepository;
  @InjectMocks private TrainerService trainerService;

  @Test
  void createSavesAndReturnsResponse() {
    var request = new CreateTrainerRequest("ash", "Ash Ketchum");
    var saved = new Trainer(UUID.randomUUID(), "ash", "Ash Ketchum");
    when(trainerRepository.save(any(Trainer.class))).thenReturn(saved);

    TrainerResponse response = trainerService.create(request);

    assertThat(response.username()).isEqualTo("ash");
    assertThat(response.displayName()).isEqualTo("Ash Ketchum");
    assertThat(response.id()).isNotNull();
  }

  @Test
  void getByIdReturnsResponseWhenFound() {
    UUID id = UUID.randomUUID();
    when(trainerRepository.findById(id)).thenReturn(Optional.of(new Trainer(id, "ash", "Ash")));

    TrainerResponse response = trainerService.getById(id);

    assertThat(response.username()).isEqualTo("ash");
  }

  @Test
  void getByIdThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(trainerRepository.findById(id)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> trainerService.getById(id))
        .isInstanceOf(TrainerNotFoundException.class);
  }

  @Test
  void getAllReturnsAllTrainers() {
    when(trainerRepository.findAll())
        .thenReturn(
            List.of(
                new Trainer(UUID.randomUUID(), "ash", "Ash"),
                new Trainer(UUID.randomUUID(), "misty", "Misty")));

    List<TrainerResponse> responses = trainerService.getAll();

    assertThat(responses).hasSize(2);
  }

  @Test
  void updateUpdatesDisplayNameAndReturnsResponse() {
    UUID id = UUID.randomUUID();
    var trainer = new Trainer(id, "ash", "Old Name");
    when(trainerRepository.findById(id)).thenReturn(Optional.of(trainer));
    when(trainerRepository.save(trainer)).thenReturn(trainer);

    TrainerResponse response = trainerService.update(id, new UpdateTrainerRequest("New Name"));

    assertThat(response.displayName()).isEqualTo("New Name");
  }

  @Test
  void updateThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(trainerRepository.findById(id)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> trainerService.update(id, new UpdateTrainerRequest("Name")))
        .isInstanceOf(TrainerNotFoundException.class);
  }

  @Test
  void deleteCallsDeleteByIdWhenExists() {
    UUID id = UUID.randomUUID();
    when(trainerRepository.existsById(id)).thenReturn(true);

    trainerService.delete(id);

    verify(trainerRepository).deleteById(id);
  }

  @Test
  void deleteThrowsNotFoundExceptionWhenMissing() {
    UUID id = UUID.randomUUID();
    when(trainerRepository.existsById(id)).thenReturn(false);

    assertThatThrownBy(() -> trainerService.delete(id))
        .isInstanceOf(TrainerNotFoundException.class);
  }
}
