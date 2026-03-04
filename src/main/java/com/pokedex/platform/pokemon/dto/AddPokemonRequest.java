package com.pokedex.platform.pokemon.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddPokemonRequest(
    @NotBlank @Size(max = 50) String speciesName,
    Integer pokeapiId,
    @Size(max = 50) String nickname,
    Integer level,
    Boolean shiny) {}
