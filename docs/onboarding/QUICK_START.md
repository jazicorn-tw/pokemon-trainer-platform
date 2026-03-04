# Quick Start

Get the API running and make your first requests in under 2 minutes.

> **Prerequisites:** Complete [`DAY_1_ONBOARDING.md`](./DAY_1_ONBOARDING.md)
> first. This guide assumes your environment is set up and Docker is running.

## Prerequisites

- `.env` exists (run `make env-init` if not)
- Docker is running (`make docker-up`)

## Start the app

```bash
make run   # starts Postgres + Spring Boot, sources .env
```

The API is available at **`http://localhost:8080`**.

## Health check

Open in browser: `http://localhost:8080/actuator/health`

```bash
curl -s http://localhost:8080/actuator/health | jq .status
# "UP"
```

## Trainer endpoints

```bash
# Create a trainer and capture the returned ID
TRAINER_ID=$(curl -s -X POST http://localhost:8080/trainers \
  -H "Content-Type: application/json" \
  -d '{"username":"ash"}' | jq -r .id)

echo $TRAINER_ID   # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

curl -s http://localhost:8080/trainers | jq .                          # list all
curl -s http://localhost:8080/trainers/$TRAINER_ID | jq .              # get one

curl -s -X PUT http://localhost:8080/trainers/$TRAINER_ID \
  -H "Content-Type: application/json" \
  -d '{"username":"misty"}' | jq .                                     # update

curl -s -X DELETE http://localhost:8080/trainers/$TRAINER_ID \
  -o /dev/null -w "%{http_code}"                                       # delete → 204
```

## Pokémon endpoints

```bash
# (assumes $TRAINER_ID is set from above)

POKEMON_ID=$(curl -s -X POST http://localhost:8080/trainers/$TRAINER_ID/pokemon \
  -H "Content-Type: application/json" \
  -d '{"speciesName":"pikachu","nickname":"Pika","level":5}' | jq -r .id)

curl -s http://localhost:8080/trainers/$TRAINER_ID/pokemon | jq .                        # list
curl -s http://localhost:8080/trainers/$TRAINER_ID/pokemon/$POKEMON_ID | jq .            # get

curl -s -X PUT http://localhost:8080/trainers/$TRAINER_ID/pokemon/$POKEMON_ID \
  -H "Content-Type: application/json" \
  -d '{"nickname":"Sparky","level":10}' | jq .                                           # update

curl -s -X DELETE http://localhost:8080/trainers/$TRAINER_ID/pokemon/$POKEMON_ID \
  -o /dev/null -w "%{http_code}"                                                         # delete → 204
```
