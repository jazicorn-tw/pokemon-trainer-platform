# 🧬 Phase 2 — PokeAPI Species Validation (v0.2.0)

> Goal: validate Pokémon species names against the live PokeAPI before allowing
> them to be added to a trainer's inventory.

---

## ✅ Purpose

Phase 1 accepts any `species_name` string without validation — `"notapokemon"`
is stored silently. Phase 2 closes that gap:

* Valid species (e.g. `"pikachu"`) → accepted, inventory updated
* Invalid species → **422 Unprocessable Entity**
* PokeAPI unavailable → graceful error, **not 500**
* PokeAPI is **fully mocked in all tests** — no real HTTP calls in CI

---

## 🎯 Outcomes

By the end of Phase 2 you will have:

* `PokeApiClient` — WebClient-based HTTP client for `https://pokeapi.co/api/v2/pokemon/{name}`
* `PokeApiService` — validation facade used by `OwnedPokemonService`
* Species validation wired into `POST /api/trainers/{id}/pokemon`
* Graceful failure handling when PokeAPI is down or slow
* New dependency: `spring-boot-starter-webflux` (WebClient only — no reactive streams)

---

## 🧬 Architecture

```text
OwnedPokemonController
  └─ OwnedPokemonService
       └─ PokeApiService          ← new
            └─ PokeApiClient      ← new (WebClient, blocking)
```

WebClient is used in **blocking** mode (`.block()`).
Full reactive architecture is intentionally deferred to a later phase.

---

## 🧪 TDD Flow (Phase 2)

### 1️⃣ Write a failing test for invalid species

**File**
`src/test/java/com/pokedex/platform/pokemon/OwnedPokemonControllerTest.java`

Add a test that expects 422 when species is invalid:

```java
@Test
void addPokemon_invalidSpecies_returns422() throws Exception {
    given(pokeApiService.validateSpecies("notapokemon"))
        .willReturn(false);

    mockMvc.perform(post("/api/trainers/{id}/pokemon", trainer.getId())
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"speciesName\":\"notapokemon\",\"nickname\":null,\"level\":1}"))
        .andExpect(status().isUnprocessableEntity());
}
```

❌ **Expected result initially**: fails — `PokeApiService` doesn't exist yet.

---

### 2️⃣ Write a failing test for PokeAPI being down

```java
@Test
void addPokemon_pokeApiDown_returnsServiceUnavailable() throws Exception {
    given(pokeApiService.validateSpecies(any()))
        .willThrow(new PokeApiUnavailableException("PokeAPI unreachable"));

    mockMvc.perform(post("/api/trainers/{id}/pokemon", trainer.getId())
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"speciesName\":\"pikachu\",\"nickname\":null,\"level\":1}"))
        .andExpect(status().isServiceUnavailable());
}
```

---

### 3️⃣ Implement `PokeApiClient`

**File**
`src/main/java/com/pokedex/platform/pokeapi/PokeApiClient.java`

```java
@Component
public class PokeApiClient {

    private final WebClient webClient;

    public PokeApiClient(WebClient.Builder builder,
                         @Value("${pokeapi.base-url}") String baseUrl) {
        this.webClient = builder.baseUrl(baseUrl).build();
    }

    public boolean speciesExists(String name) {
        try {
            webClient.get()
                .uri("/pokemon/{name}", name.toLowerCase())
                .retrieve()
                .toBodilessEntity()
                .block();
            return true;
        } catch (WebClientResponseException.NotFound e) {
            return false;
        } catch (Exception e) {
            throw new PokeApiUnavailableException("PokeAPI unreachable: " + e.getMessage());
        }
    }
}
```

---

### 4️⃣ Implement `PokeApiService`

**File**
`src/main/java/com/pokedex/platform/pokeapi/PokeApiService.java`

```java
@Service
public class PokeApiService {

    private final PokeApiClient client;

    public PokeApiService(PokeApiClient client) {
        this.client = client;
    }

    public boolean validateSpecies(String speciesName) {
        return client.speciesExists(speciesName);
    }
}
```

---

### 5️⃣ Wire validation into `OwnedPokemonService`

In `OwnedPokemonService.addPokemon(...)`:

```java
if (!pokeApiService.validateSpecies(request.speciesName())) {
    throw new InvalidSpeciesException(request.speciesName());
}
```

---

### 6️⃣ Handle new exceptions in `GlobalExceptionHandler`

```java
@ExceptionHandler(InvalidSpeciesException.class)
ProblemDetail handleInvalidSpecies(InvalidSpeciesException ex) {
    ProblemDetail pd = ProblemDetail.forStatus(HttpStatus.UNPROCESSABLE_ENTITY);
    pd.setTitle("Invalid Pokémon species");
    pd.setDetail(ex.getMessage());
    return pd;
}

@ExceptionHandler(PokeApiUnavailableException.class)
ProblemDetail handlePokeApiUnavailable(PokeApiUnavailableException ex) {
    ProblemDetail pd = ProblemDetail.forStatus(HttpStatus.SERVICE_UNAVAILABLE);
    pd.setTitle("PokeAPI unavailable");
    pd.setDetail(ex.getMessage());
    return pd;
}
```

---

## 📦 New Dependency

```gradle
implementation 'org.springframework.boot:spring-boot-starter-webflux'
```

> Only `WebClient` is used. Reactive streams (`Mono`, `Flux`) are not exposed
> anywhere in the service layer — all calls use `.block()`.

---

## ⚙️ Configuration

```properties
# application.properties
pokeapi.base-url=https://pokeapi.co/api/v2
```

```properties
# application-test.properties (or application-test.yml)
pokeapi.base-url=http://localhost:${wiremock.server.port}
```

---

## 🧪 Test Strategy

| Test type | PokeAPI | How |
| --------- | ------- | --- |
| Unit (`PokeApiClientTest`) | Mocked via WireMock or Mockito | Stub HTTP responses |
| Controller slice (`@WebMvcTest`) | `@MockitoBean PokeApiService` | No HTTP at all |
| Integration (`BaseIntegrationTest`) | WireMock stub or `@MockitoBean` | No real network |

**Rule:** No test makes a real HTTP call to `pokeapi.co`.

---

## ✅ Definition of Done (Phase 2)

* [ ] `POST /api/trainers/{id}/pokemon` with invalid species returns 422
* [ ] `POST /api/trainers/{id}/pokemon` with valid species succeeds (201)
* [ ] PokeAPI being down returns 503, not 500
* [ ] PokeAPI is fully mocked in all tests — no real HTTP calls in CI
* [ ] All tests pass: `./gradlew clean check`
* [ ] CI pipeline is green

---

## 🔜 Next — Phase 3 Preview

Phase 3 introduces the trading system: trainers can propose, accept, reject, and
cancel trades. Ownership swaps atomically on acceptance.

See [`PHASES.md`](PHASES.md) for the full roadmap.
