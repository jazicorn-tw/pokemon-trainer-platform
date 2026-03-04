package com.pokedex.platform.pokemon;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OwnedPokemonRepository extends JpaRepository<OwnedPokemon, UUID> {

  List<OwnedPokemon> findAllByTrainerId(UUID trainerId);
}
