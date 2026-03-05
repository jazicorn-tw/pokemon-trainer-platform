package com.example.platform.item;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemRepository extends JpaRepository<Item, UUID> {

  List<Item> findAllByResourceId(UUID resourceId);
}
