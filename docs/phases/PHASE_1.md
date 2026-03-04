# 🐣 Phase 1 — Trainers & Inventory (v0.1.0)

> Goal: introduce the core domain (trainers and owned Pokémon) using strict TDD,
> on top of the production-realistic skeleton from Phase 0.

---

## ✅ Purpose

Phase 1 establishes the primary domain objects and their full CRUD API:

* Trainer registration and retrieval
* Pokémon inventory management (add, list, update, remove)
* Validation and structured error responses (RFC 7807 ProblemDetail)
* Global exception handling

No external API calls are made in this phase (PokeAPI integration is Phase 2).

---

## 🎯 Outcomes

By the end of Phase 1 you will have:

* `Trainer` entity, service, repository, controller
* `OwnedPokemon` entity, service, repository, controller
* Full CRUD for both resources
* `GlobalExceptionHandler` returning `ProblemDetail` (RFC 7807) for 400, 404, 409
* Unit tests, controller slice tests, and integration tests for both domains

---

## 🗄️ V1 Schema — What your DB contains after Phase 1

Because all foreign keys are defined up front, `V1__init.sql` contains every table the
platform will ever need — not just the Phase 1 tables. Tables for later phases are
**present in the schema but unused** until their owning phase is implemented.

### Phase 1 tables (implemented & tested)

#### `trainer`

```sql
CREATE TABLE trainer (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### `owned_pokemon`

```sql
CREATE TABLE owned_pokemon (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL,
    species_name VARCHAR(50) NOT NULL,
    pokeapi_id INTEGER,
    nickname VARCHAR(50),
    level INTEGER NOT NULL DEFAULT 1,
    shiny BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL,
    acquired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_owned_pokemon_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);
```

`status` values: `ACTIVE`, `LISTED`, `TRADED`, `SOLD`

---

### Future-phase tables (schema only — no domain logic yet)

#### `trade` (Phase 3)

```sql
CREATE TABLE trade (
    id UUID PRIMARY KEY,
    initiator_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_trade_initiator
        FOREIGN KEY (initiator_id) REFERENCES trainer(id),

    CONSTRAINT fk_trade_recipient
        FOREIGN KEY (recipient_id) REFERENCES trainer(id)
);
```

#### `trade_pokemon` (Phase 3)

```sql
CREATE TABLE trade_pokemon (
    trade_id UUID NOT NULL,
    owned_pokemon_id UUID NOT NULL,
    role VARCHAR(20) NOT NULL,

    PRIMARY KEY (trade_id, owned_pokemon_id),

    CONSTRAINT fk_trade_pokemon_trade
        FOREIGN KEY (trade_id) REFERENCES trade(id) ON DELETE CASCADE,

    CONSTRAINT fk_trade_pokemon_owned
        FOREIGN KEY (owned_pokemon_id) REFERENCES owned_pokemon(id)
);
```

`role` values: `INITIATOR`, `RECIPIENT`

#### `trade_offer` (Phase 3)

```sql
CREATE TABLE trade_offer (
    id UUID PRIMARY KEY,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    offered_pokemon_id UUID NOT NULL,
    requested_species VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    ai_analysis TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,

    CONSTRAINT fk_trade_offer_sender
        FOREIGN KEY (sender_id) REFERENCES trainer(id),

    CONSTRAINT fk_trade_offer_recipient
        FOREIGN KEY (recipient_id) REFERENCES trainer(id),

    CONSTRAINT fk_trade_offer_pokemon
        FOREIGN KEY (offered_pokemon_id) REFERENCES owned_pokemon(id)
);
```

#### `sale_listing` (Phase 4)

```sql
CREATE TABLE sale_listing (
    id UUID PRIMARY KEY,
    pokemon_id UUID NOT NULL UNIQUE,
    seller_id UUID NOT NULL,
    buyer_id UUID,
    price NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,

    CONSTRAINT fk_listing_pokemon
        FOREIGN KEY (pokemon_id) REFERENCES owned_pokemon(id),

    CONSTRAINT fk_listing_seller
        FOREIGN KEY (seller_id) REFERENCES trainer(id),

    CONSTRAINT fk_listing_buyer
        FOREIGN KEY (buyer_id) REFERENCES trainer(id)
);
```

`status` values: `ACTIVE`, `SOLD`, `CANCELLED`

#### `user_account` (Phase 7)

```sql
CREATE TABLE user_account (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);
```

---

## 📦 Flyway

Schema is delivered as a single Flyway migration:

```tree
src/main/resources/db/migration/
└── V1__init.sql
```

Future migrations will add to this baseline (e.g. `V2__add_pokeapi_id_index.sql`).

---

## 🧪 TDD Flow (Phase 1)

### Trainer domain

1. Write failing service tests for `TrainerService`
2. Implement `Trainer` entity + `TrainerRepository`
3. Implement `TrainerService`
4. Write failing controller tests for `POST /api/trainers`, `GET /api/trainers/{id}`
5. Implement `TrainerController`

### OwnedPokemon domain

1. Write failing service tests for `OwnedPokemonService`
2. Implement `OwnedPokemon` entity + `OwnedPokemonRepository`
3. Implement `OwnedPokemonService`
4. Write failing controller tests for `/api/trainers/{id}/pokemon` endpoints
5. Implement `OwnedPokemonController`

---

## ⚙️ Notes

* PostgreSQL is the only database — no H2, no in-memory fallbacks (ADR-001)
* Integration tests use Testcontainers, exactly as in Phase 0 (ADR-003)
* `@MockitoBean` replaces `@MockBean` in Spring Boot 4 test slices
* `GlobalExceptionHandler` returns `ProblemDetail` (RFC 7807):
  * 404 — `TrainerNotFoundException`, `OwnedPokemonNotFoundException`
  * 400 — `MethodArgumentNotValidException`
  * 409 — `DataIntegrityViolationException` (duplicate username)

---

## ✅ Definition of Done (Phase 1)

* [ ] `POST /api/trainers` creates a trainer
* [ ] `GET /api/trainers/{id}` retrieves a trainer (404 if not found)
* [ ] `POST /api/trainers/{id}/pokemon` adds a Pokémon to a trainer's inventory
* [ ] `GET /api/trainers/{id}/pokemon` lists a trainer's Pokémon
* [ ] `DELETE /api/trainers/{id}/pokemon/{pokemonId}` removes a Pokémon
* [ ] Invalid requests return structured `ProblemDetail` errors
* [ ] All tests pass: `./gradlew clean check`
* [ ] CI pipeline is green

---

## 🔜 Next — Phase 2 Preview

Phase 2 adds PokeAPI species validation: `species_name` values will be validated
against the live PokeAPI before a Pokémon can be added to inventory.

See [`PHASE_2.md`](PHASE_2.md).
