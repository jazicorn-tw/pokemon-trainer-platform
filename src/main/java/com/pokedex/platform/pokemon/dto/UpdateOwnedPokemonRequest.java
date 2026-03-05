package com.pokedex.platform.pokemon.dto;

import com.pokedex.platform.pokemon.PokemonStatus;
import jakarta.validation.constraints.Size;

public record UpdateOwnedPokemonRequest(
    @Size(max = 50) String nickname,
    Integer level,
    Integer pokeapiId,
    Boolean shiny,
    PokemonStatus status) {}
