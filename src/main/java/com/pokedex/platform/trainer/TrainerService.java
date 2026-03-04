package com.pokedex.platform.trainer;

import com.pokedex.platform.trainer.dto.CreateTrainerRequest;
import com.pokedex.platform.trainer.dto.TrainerResponse;
import com.pokedex.platform.trainer.dto.UpdateTrainerRequest;
import com.pokedex.platform.trainer.exception.TrainerNotFoundException;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TrainerService {

  private final TrainerRepository trainerRepository;

  TrainerService(TrainerRepository trainerRepository) {
    this.trainerRepository = trainerRepository;
  }

  @Transactional
  public TrainerResponse create(CreateTrainerRequest request) {
    Trainer trainer = new Trainer(request.username(), request.displayName());
    return TrainerResponse.from(trainerRepository.save(trainer));
  }

  public TrainerResponse getById(UUID id) {
    return trainerRepository
        .findById(id)
        .map(TrainerResponse::from)
        .orElseThrow(() -> new TrainerNotFoundException(id));
  }

  public List<TrainerResponse> getAll() {
    return trainerRepository.findAll().stream().map(TrainerResponse::from).toList();
  }

  @Transactional
  public TrainerResponse update(UUID id, UpdateTrainerRequest request) {
    Trainer trainer =
        trainerRepository.findById(id).orElseThrow(() -> new TrainerNotFoundException(id));
    trainer.setDisplayName(request.displayName());
    return TrainerResponse.from(trainerRepository.save(trainer));
  }

  @Transactional
  public void delete(UUID id) {
    if (!trainerRepository.existsById(id)) {
      throw new TrainerNotFoundException(id);
    }
    trainerRepository.deleteById(id);
  }
}
