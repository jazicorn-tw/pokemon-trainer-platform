package com.example.platform.resource;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "resource")
public class Resource {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(nullable = false, unique = true, length = 50)
  private String username;

  @Column(name = "display_name", length = 100)
  private String displayName;

  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  /** Required by JPA. */
  protected Resource() {
    // no-op
  }

  public Resource(String username, String displayName) {
    this.username = username;
    this.displayName = displayName;
  }

  /**
   * Package-private constructor for tests that need a pre-populated entity (e.g. with an ID set
   * before Mockito returns it).
   */
  Resource(UUID id, String username, String displayName) {
    this.id = id;
    this.username = username;
    this.displayName = displayName;
    this.createdAt = LocalDateTime.now();
  }

  @PrePersist
  void prePersist() {
    if (createdAt == null) {
      createdAt = LocalDateTime.now();
    }
  }

  public UUID getId() {
    return id;
  }

  public String getUsername() {
    return username;
  }

  public String getDisplayName() {
    return displayName;
  }

  public void setDisplayName(String displayName) {
    this.displayName = displayName;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }
}
