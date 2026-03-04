package com.pokedex.platform.pokemon;

import com.pokedex.platform.pokemon.dto.AddPokemonRequest;
import com.pokedex.platform.pokemon.dto.OwnedPokemonResponse;
import com.pokedex.platform.pokemon.dto.UpdateOwnedPokemonRequest;
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
@RequestMapping("/trainers/{trainerId}/pokemon")
public class OwnedPokemonController {

  private final OwnedPokemonService pokemonService;

  OwnedPokemonController(OwnedPokemonService pokemonService) {
    this.pokemonService = pokemonService;
  }

  @PostMapping
  ResponseEntity<OwnedPokemonResponse> add(
      @PathVariable UUID trainerId, @Valid @RequestBody AddPokemonRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(pokemonService.add(trainerId, request));
  }

  @GetMapping
  ResponseEntity<List<OwnedPokemonResponse>> getAll(@PathVariable UUID trainerId) {
    return ResponseEntity.ok(pokemonService.getAllForTrainer(trainerId));
  }

  @GetMapping("/{id}")
  ResponseEntity<OwnedPokemonResponse> getById(
      @PathVariable UUID trainerId, @PathVariable UUID id) {
    return ResponseEntity.ok(pokemonService.getById(trainerId, id));
  }

  @PutMapping("/{id}")
  ResponseEntity<OwnedPokemonResponse> update(
      @PathVariable UUID trainerId,
      @PathVariable UUID id,
      @Valid @RequestBody UpdateOwnedPokemonRequest request) {
    return ResponseEntity.ok(pokemonService.update(trainerId, id, request));
  }

  @DeleteMapping("/{id}")
  ResponseEntity<Void> delete(@PathVariable UUID trainerId, @PathVariable UUID id) {
    pokemonService.delete(trainerId, id);
    return ResponseEntity.noContent().build();
  }
}
