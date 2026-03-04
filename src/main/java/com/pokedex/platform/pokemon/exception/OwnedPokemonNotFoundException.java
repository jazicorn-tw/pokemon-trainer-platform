package com.pokedex.platform.pokemon.exception;

import java.io.Serial;
import java.util.UUID;

public class OwnedPokemonNotFoundException extends RuntimeException {

  @Serial private static final long serialVersionUID = 1L;

  public OwnedPokemonNotFoundException(UUID id) {
    super("Pokemon not found: " + id);
  }
}
