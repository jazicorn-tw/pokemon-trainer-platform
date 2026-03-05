package com.example.platform.item;

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
@Table(name = "item")
public class Item {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "resource_id", nullable = false, updatable = false)
  private UUID resourceId;

  @Column(name = "item_name", nullable = false, length = 50)
  private String itemName;

  @Column(name = "external_id")
  private Integer externalId;

  @Column(length = 50)
  private String label;

  @Column(nullable = false)
  private int level = 1;

  @Column(nullable = false)
  private boolean shiny = false;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private ItemStatus status = ItemStatus.ACTIVE;

  @Column(name = "acquired_at", nullable = false, updatable = false)
  private LocalDateTime acquiredAt;

  /** Required by JPA. */
  protected Item() {
    // no-op
  }

  public Item(
      UUID resourceId,
      String itemName,
      Integer externalId,
      String label,
      int level,
      boolean shiny) {
    this.resourceId = resourceId;
    this.itemName = itemName;
    this.externalId = externalId;
    this.label = label;
    this.level = level;
    this.shiny = shiny;
    this.status = ItemStatus.ACTIVE;
  }

  /**
   * Package-private constructor for tests that need a pre-populated entity (e.g. with an ID set
   * before Mockito returns it).
   */
  Item(UUID id, UUID resourceId, String itemName, int level, ItemStatus status) {
    this.id = id;
    this.resourceId = resourceId;
    this.itemName = itemName;
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

  public UUID getResourceId() {
    return resourceId;
  }

  public String getSpeciesName() {
    return itemName;
  }

  public Integer getExternalId() {
    return externalId;
  }

  public void setExternalId(Integer externalId) {
    this.externalId = externalId;
  }

  public String getNickname() {
    return label;
  }

  public void setNickname(String label) {
    this.label = label;
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

  public void setShiny(boolean shiny) {
    this.shiny = shiny;
  }

  public ItemStatus getStatus() {
    return status;
  }

  public void setStatus(ItemStatus status) {
    this.status = status;
  }

  public LocalDateTime getAcquiredAt() {
    return acquiredAt;
  }
}
