package com.pokedex.platform.pokemon;

import com.pokedex.platform.pokemon.dto.AddPokemonRequest;
import com.pokedex.platform.pokemon.dto.OwnedPokemonResponse;
import com.pokedex.platform.pokemon.dto.UpdateOwnedPokemonRequest;
import com.pokedex.platform.pokemon.exception.OwnedPokemonNotFoundException;
import com.pokedex.platform.trainer.TrainerRepository;
import com.pokedex.platform.trainer.exception.TrainerNotFoundException;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OwnedPokemonService {

  private final OwnedPokemonRepository pokemonRepository;
  private final TrainerRepository trainerRepository;

  OwnedPokemonService(
      OwnedPokemonRepository pokemonRepository, TrainerRepository trainerRepository) {
    this.pokemonRepository = pokemonRepository;
    this.trainerRepository = trainerRepository;
  }

  @Transactional
  public OwnedPokemonResponse add(UUID trainerId, AddPokemonRequest request) {
    if (!trainerRepository.existsById(trainerId)) {
      throw new TrainerNotFoundException(trainerId);
    }
    OwnedPokemon pokemon =
        new OwnedPokemon(
            trainerId,
            request.speciesName(),
            request.pokeapiId(),
            request.nickname(),
            request.level() != null ? request.level() : 1,
            Boolean.TRUE.equals(request.shiny()));
    return OwnedPokemonResponse.from(pokemonRepository.save(pokemon));
  }

  public OwnedPokemonResponse getById(UUID trainerId, UUID id) {
    OwnedPokemon pokemon =
        pokemonRepository.findById(id).orElseThrow(() -> new OwnedPokemonNotFoundException(id));
    if (!pokemon.getTrainerId().equals(trainerId)) {
      throw new OwnedPokemonNotFoundException(id);
    }
    return OwnedPokemonResponse.from(pokemon);
  }

  public List<OwnedPokemonResponse> getAllForTrainer(UUID trainerId) {
    return pokemonRepository.findAllByTrainerId(trainerId).stream()
        .map(OwnedPokemonResponse::from)
        .toList();
  }

  @Transactional
  public OwnedPokemonResponse update(UUID trainerId, UUID id, UpdateOwnedPokemonRequest request) {
    OwnedPokemon pokemon =
        pokemonRepository.findById(id).orElseThrow(() -> new OwnedPokemonNotFoundException(id));
    if (!pokemon.getTrainerId().equals(trainerId)) {
      throw new OwnedPokemonNotFoundException(id);
    }
    if (request.nickname() != null) {
      pokemon.setNickname(request.nickname());
    }
    if (request.level() != null) {
      pokemon.setLevel(request.level());
    }
    return OwnedPokemonResponse.from(pokemonRepository.save(pokemon));
  }

  @Transactional
  public void delete(UUID trainerId, UUID id) {
    OwnedPokemon pokemon =
        pokemonRepository.findById(id).orElseThrow(() -> new OwnedPokemonNotFoundException(id));
    if (!pokemon.getTrainerId().equals(trainerId)) {
      throw new OwnedPokemonNotFoundException(id);
    }
    pokemonRepository.deleteById(id);
  }
}
