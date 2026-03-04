package com.pokedex.platform.trainer;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TrainerRepository extends JpaRepository<Trainer, UUID> {}
