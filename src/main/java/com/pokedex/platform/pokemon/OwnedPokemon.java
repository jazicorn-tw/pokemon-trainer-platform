package com.pokedex.platform.pokemon;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "owned_pokemon")
public class OwnedPokemon {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "trainer_id", nullable = false, updatable = false)
  private UUID trainerId;

  @Column(name = "species_name", nullable = false, length = 50)
  private String speciesName;

  @Column(name = "pokeapi_id")
  private Integer pokeapiId;

  @Column(length = 50)
  private String nickname;

  @Column(nullable = false)
  private int level = 1;

  @Column(nullable = false)
  private boolean shiny = false;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private PokemonStatus status = PokemonStatus.ACTIVE;

  @Column(name = "acquired_at", nullable = false, updatable = false)
  private LocalDateTime acquiredAt;

  /** Required by JPA. */
  protected OwnedPokemon() {
    // no-op
  }

  public OwnedPokemon(
      UUID trainerId,
      String speciesName,
      Integer pokeapiId,
      String nickname,
      int level,
      boolean shiny) {
    this.trainerId = trainerId;
    this.speciesName = speciesName;
    this.pokeapiId = pokeapiId;
    this.nickname = nickname;
    this.level = level;
    this.shiny = shiny;
    this.status = PokemonStatus.ACTIVE;
  }

  /**
   * Package-private constructor for tests that need a pre-populated entity (e.g. with an ID set
   * before Mockito returns it).
   */
  OwnedPokemon(UUID id, UUID trainerId, String speciesName, int level, PokemonStatus status) {
    this.id = id;
    this.trainerId = trainerId;
    this.speciesName = speciesName;
    this.level = level;
    this.status = status;
    this.acquiredAt = LocalDateTime.now();
  }

  @PrePersist
  void prePersist() {
    if (acquiredAt == null) {
      acquiredAt = LocalDateTime.now();
    }
  }

  public UUID getId() {
    return id;
  }

  public UUID getTrainerId() {
    return trainerId;
  }

  public String getSpeciesName() {
    return speciesName;
  }

  public Integer getPokeapiId() {
    return pokeapiId;
  }

  public String getNickname() {
    return nickname;
  }

  public void setNickname(String nickname) {
    this.nickname = nickname;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public boolean isShiny() {
    return shiny;
  }

  public PokemonStatus getStatus() {
    return status;
  }

  public LocalDateTime getAcquiredAt() {
    return acquiredAt;
  }
}
