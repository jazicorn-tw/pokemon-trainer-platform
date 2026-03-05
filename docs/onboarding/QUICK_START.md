# Quick Start

Get the API running and make your first requests in under 2 minutes.

> **Setting up for the first time?** See [`PROJECT_SETUP.md`](./PROJECT_SETUP.md) for the full
> checklist — placeholder replacement, env files, bootstrap, and CI configuration.
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

## Resource endpoints

```bash
# Create a resource and capture the returned ID
RESOURCE_ID=$(curl -s -X POST http://localhost:8080/resources \
  -H "Content-Type: application/json" \
  -d '{"username":"alice"}' | jq -r .id)

echo $RESOURCE_ID   # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

curl -s http://localhost:8080/resources | jq .                          # list all
curl -s http://localhost:8080/resources/$RESOURCE_ID | jq .              # get one

curl -s -X PUT http://localhost:8080/resources/$RESOURCE_ID \
  -H "Content-Type: application/json" \
  -d '{"username":"bob"}' | jq .                                       # update

curl -s -X DELETE http://localhost:8080/resources/$RESOURCE_ID \
  -o /dev/null -w "%{http_code}"                                       # delete → 204
```

## {{resource}} endpoints

```bash
# (assumes $RESOURCE_ID is set from above)

{{RESOURCE}}_ID=$(curl -s -X POST http://localhost:8080/resources/$RESOURCE_ID/{{resource}} \
  -H "Content-Type: application/json" \
  -d '{"itemName":"example-item","level":1}' | jq -r .id)

curl -s http://localhost:8080/resources/$RESOURCE_ID/{{resource}} | jq .                   # list
curl -s http://localhost:8080/resources/$RESOURCE_ID/{{resource}}/${{RESOURCE}}_ID | jq .  # get

curl -s -X PUT http://localhost:8080/resources/$RESOURCE_ID/{{resource}}/${{RESOURCE}}_ID \
  -H "Content-Type: application/json" \
  -d '{"label":"updated","level":2}' | jq .                                               # update

curl -s -X DELETE http://localhost:8080/resources/$RESOURCE_ID/{{resource}}/${{RESOURCE}}_ID \
  -o /dev/null -w "%{http_code}"                                                           # delete → 204
```
