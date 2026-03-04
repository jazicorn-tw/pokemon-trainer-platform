package com.pokedex.platform.pokemon.dto;

import jakarta.validation.constraints.Size;

public record UpdateOwnedPokemonRequest(@Size(max = 50) String nickname, Integer level) {}
