package com.pokedex.platform.trainer;

import com.pokedex.platform.trainer.dto.CreateTrainerRequest;
import com.pokedex.platform.trainer.dto.TrainerResponse;
import com.pokedex.platform.trainer.dto.UpdateTrainerRequest;
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
@RequestMapping("/trainers")
public class TrainerController {

  private final TrainerService trainerService;

  TrainerController(TrainerService trainerService) {
    this.trainerService = trainerService;
  }

  @PostMapping
  ResponseEntity<TrainerResponse> create(@Valid @RequestBody CreateTrainerRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(trainerService.create(request));
  }

  @GetMapping("/{id}")
  ResponseEntity<TrainerResponse> getById(@PathVariable UUID id) {
    return ResponseEntity.ok(trainerService.getById(id));
  }

  @GetMapping
  ResponseEntity<List<TrainerResponse>> getAll() {
    return ResponseEntity.ok(trainerService.getAll());
  }

  @PutMapping("/{id}")
  ResponseEntity<TrainerResponse> update(
      @PathVariable UUID id, @Valid @RequestBody UpdateTrainerRequest request) {
    return ResponseEntity.ok(trainerService.update(id, request));
  }

  @DeleteMapping("/{id}")
  ResponseEntity<Void> delete(@PathVariable UUID id) {
    trainerService.delete(id);
    return ResponseEntity.noContent().build();
  }
}
