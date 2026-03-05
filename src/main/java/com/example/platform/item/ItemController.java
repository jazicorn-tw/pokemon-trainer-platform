package com.example.platform.item;

import com.example.platform.item.dto.AddItemRequest;
import com.example.platform.item.dto.ItemResponse;
import com.example.platform.item.dto.UpdateItemRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/resources/{resourceId}/item")
public class ItemController {

  private final ItemService itemService;

  ItemController(ItemService itemService) {
    this.itemService = itemService;
  }

  @PostMapping
  ResponseEntity<ItemResponse> add(
      @PathVariable UUID resourceId, @Valid @RequestBody AddItemRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(itemService.add(resourceId, request));
  }

  @GetMapping
  ResponseEntity<List<ItemResponse>> getAll(@PathVariable UUID resourceId) {
    return ResponseEntity.ok(itemService.getAllForResource(resourceId));
  }

  @GetMapping("/{id}")
  ResponseEntity<ItemResponse> getById(@PathVariable UUID resourceId, @PathVariable UUID id) {
    return ResponseEntity.ok(itemService.getById(resourceId, id));
  }

  @PutMapping("/{id}")
  ResponseEntity<ItemResponse> update(
      @PathVariable UUID resourceId,
      @PathVariable UUID id,
      @Valid @RequestBody UpdateItemRequest request) {
    return ResponseEntity.ok(itemService.update(resourceId, id, request));
  }

  @DeleteMapping("/{id}")
  ResponseEntity<Void> delete(@PathVariable UUID resourceId, @PathVariable UUID id) {
    itemService.delete(resourceId, id);
    return ResponseEntity.noContent().build();
  }
}
