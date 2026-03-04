package com.pokedex.platform.pokemon;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pokedex.platform.pokemon.dto.AddPokemonRequest;
import com.pokedex.platform.pokemon.dto.OwnedPokemonResponse;
import com.pokedex.platform.pokemon.dto.UpdateOwnedPokemonRequest;
import com.pokedex.platform.pokemon.exception.OwnedPokemonNotFoundException;
import com.pokedex.platform.trainer.TrainerRepository;
import com.pokedex.platform.trainer.exception.TrainerNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@SuppressWarnings({"PMD.JUnitTestContainsTooManyAsserts", "PMD.AvoidDuplicateLiterals"})
@ExtendWith(MockitoExtension.class)
class OwnedPokemonServiceTest {

  @Mock private OwnedPokemonRepository pokemonRepository;
  @Mock private TrainerRepository trainerRepository;
  @InjectMocks private OwnedPokemonService pokemonService;

  @Test
  void addSavesAndReturnsResponse() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var request = new AddPokemonRequest("pikachu", null, "Pika", 5, false);
    var saved = new OwnedPokemon(pokemonId, trainerId, "pikachu", 5, PokemonStatus.ACTIVE);

    when(trainerRepository.existsById(trainerId)).thenReturn(true);
    when(pokemonRepository.save(any(OwnedPokemon.class))).thenReturn(saved);

    OwnedPokemonResponse response = pokemonService.add(trainerId, request);

    assertThat(response.speciesName()).isEqualTo("pikachu");
    assertThat(response.status()).isEqualTo(PokemonStatus.ACTIVE);
    assertThat(response.id()).isNotNull();
  }

  @Test
  void addThrowsTrainerNotFoundWhenTrainerMissing() {
    UUID trainerId = UUID.randomUUID();
    when(trainerRepository.existsById(trainerId)).thenReturn(false);

    assertThatThrownBy(
            () -> pokemonService.add(trainerId, new AddPokemonRequest("pikachu", null, null, null, null)))
        .isInstanceOf(TrainerNotFoundException.class);
  }

  @Test
  void addDefaultsLevelToOneWhenNull() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var request = new AddPokemonRequest("charmander", null, null, null, null);
    var saved = new OwnedPokemon(pokemonId, trainerId, "charmander", 1, PokemonStatus.ACTIVE);

    when(trainerRepository.existsById(trainerId)).thenReturn(true);
    when(pokemonRepository.save(any(OwnedPokemon.class))).thenReturn(saved);

    OwnedPokemonResponse response = pokemonService.add(trainerId, request);

    assertThat(response.level()).isEqualTo(1);
  }

  @Test
  void getByIdReturnsResponseWhenFound() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var pokemon = new OwnedPokemon(pokemonId, trainerId, "pikachu", 5, PokemonStatus.ACTIVE);
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.of(pokemon));

    OwnedPokemonResponse response = pokemonService.getById(trainerId, pokemonId);

    assertThat(response.speciesName()).isEqualTo("pikachu");
  }

  @Test
  void getByIdThrowsNotFoundWhenMissing() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> pokemonService.getById(trainerId, pokemonId))
        .isInstanceOf(OwnedPokemonNotFoundException.class);
  }

  @Test
  void getByIdThrowsNotFoundWhenTrainerMismatch() {
    UUID trainerId = UUID.randomUUID();
    UUID otherTrainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var pokemon = new OwnedPokemon(pokemonId, otherTrainerId, "pikachu", 5, PokemonStatus.ACTIVE);
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.of(pokemon));

    assertThatThrownBy(() -> pokemonService.getById(trainerId, pokemonId))
        .isInstanceOf(OwnedPokemonNotFoundException.class);
  }

  @Test
  void getAllForTrainerReturnsAllPokemon() {
    UUID trainerId = UUID.randomUUID();
    when(pokemonRepository.findAllByTrainerId(trainerId))
        .thenReturn(
            List.of(
                new OwnedPokemon(UUID.randomUUID(), trainerId, "pikachu", 5, PokemonStatus.ACTIVE),
                new OwnedPokemon(
                    UUID.randomUUID(), trainerId, "charmander", 3, PokemonStatus.ACTIVE)));

    List<OwnedPokemonResponse> responses = pokemonService.getAllForTrainer(trainerId);

    assertThat(responses).hasSize(2);
  }

  @Test
  void updateUpdatesNicknameAndLevelAndReturnsResponse() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var pokemon = new OwnedPokemon(pokemonId, trainerId, "pikachu", 5, PokemonStatus.ACTIVE);
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.of(pokemon));
    when(pokemonRepository.save(pokemon)).thenReturn(pokemon);

    OwnedPokemonResponse response =
        pokemonService.update(trainerId, pokemonId, new UpdateOwnedPokemonRequest("Sparky", 10));

    assertThat(response.level()).isEqualTo(10);
  }

  @Test
  void updateThrowsNotFoundWhenMissing() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.empty());

    assertThatThrownBy(
            () -> pokemonService.update(trainerId, pokemonId, new UpdateOwnedPokemonRequest(null, null)))
        .isInstanceOf(OwnedPokemonNotFoundException.class);
  }

  @Test
  void deleteCallsDeleteByIdWhenExists() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    var pokemon = new OwnedPokemon(pokemonId, trainerId, "pikachu", 5, PokemonStatus.ACTIVE);
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.of(pokemon));

    pokemonService.delete(trainerId, pokemonId);

    verify(pokemonRepository).deleteById(pokemonId);
  }

  @Test
  void deleteThrowsNotFoundWhenMissing() {
    UUID trainerId = UUID.randomUUID();
    UUID pokemonId = UUID.randomUUID();
    when(pokemonRepository.findById(pokemonId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> pokemonService.delete(trainerId, pokemonId))
        .isInstanceOf(OwnedPokemonNotFoundException.class);
  }
}
