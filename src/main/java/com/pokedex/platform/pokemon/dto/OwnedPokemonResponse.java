package com.pokedex.platform.pokemon.dto;

import com.pokedex.platform.pokemon.OwnedPokemon;
import com.pokedex.platform.pokemon.PokemonStatus;
import java.time.LocalDateTime;
import java.util.UUID;

public record OwnedPokemonResponse(
    UUID id,
    UUID trainerId,
    String speciesName,
    Integer pokeapiId,
    String nickname,
    int level,
    boolean shiny,
    PokemonStatus status,
    LocalDateTime acquiredAt) {

  public static OwnedPokemonResponse from(OwnedPokemon pokemon) {
    return new OwnedPokemonResponse(
        pokemon.getId(),
        pokemon.getTrainerId(),
        pokemon.getSpeciesName(),
        pokemon.getPokeapiId(),
        pokemon.getNickname(),
        pokemon.getLevel(),
        pokemon.isShiny(),
        pokemon.getStatus(),
        pokemon.getAcquiredAt());
  }
}
