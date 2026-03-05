# 🐳 Docker Local Setup Guide (macOS)

This guide walks through setting up **Docker for local development on macOS**, using **Colima** as the Docker runtime.  
It also includes common issues, checks, and best practices for a smooth dev environment.

---

## 📦 Prerequisites

- macOS (Intel or Apple Silicon)
- Terminal access
- Homebrew installed

Check Homebrew:

```bash
brew --version
````

If not installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 🧠 What Is Colima?

**Colima** provides a lightweight Linux VM to run Docker containers on macOS.

Why use Colima instead of Docker Desktop?

- ✅ No licensing issues
- ✅ Lower memory usage
- ✅ Faster startup
- ✅ Works great with Homebrew

---

## 🚀 Install Docker + Colima

```bash
brew install docker docker-compose colima
```

Verify:

```bash
docker --version
docker compose version
colima version
```

---

## ▶️ Start Docker Engine (Colima)

Start Colima with sufficient resources and explicit DNS (recommended):

```bash
colima start --cpu 6 --memory 8 --dns 8.8.8.8 --dns 1.1.1.1
```

> The project requires at least **8 GiB RAM and 6 CPUs** (configured in
> `.config/local-settings.json` under `colima.required`). Running with fewer
> resources causes flaky Gradle builds and Testcontainers failures.

Check status:

```bash
colima status
```

Docker should now work:

```bash
docker info
```

---

## 🧪 Quick Sanity Checks

### Check Docker context

```bash
docker context show
```

Expected:

```text
colima
```

### Check Docker daemon connectivity

```bash
docker ps
```

---

## 🐘 Example: PostgreSQL with Docker Compose

### 1️⃣ Create a `.env` file (recommended)

```env
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password
POSTGRES_DB=your_database
```

> ⚠️ Never commit `.env` files to version control.

---

### 2️⃣ `docker-compose.yml`

```yaml
services:
  postgres:
    image: postgres:16
    container_name: postgres-local
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 10

volumes:
  postgres_data:
```

---

## ▶️ Run Containers

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f postgres
```

---

## 🔌 Connect to Postgres

### Using local `psql`

```bash
psql "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB}"
```

### Without `psql` installed

```bash
docker run -it --rm postgres:16 \
  psql "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@host.docker.internal:5432/${POSTGRES_DB}"
```

---

## ⏹ Stop / Clean Up

Stop containers:

```bash
docker compose down
```

Stop and remove volumes (⚠ deletes DB data):

```bash
docker compose down -v
```

---

## 🧰 macOS Environment Checks

### 1️⃣ PATH sanity

```bash
which docker
which colima
```

### 2️⃣ Port conflicts

```bash
lsof -nP -iTCP:5432 -sTCP:LISTEN
```

### 3️⃣ Network access to Docker Hub

```bash
curl -I https://registry-1.docker.io/v2/
```

Expected: `401 Unauthorized` (this is GOOD)

---

## 🔥 Common Issues & Fixes

### ❌ Docker pull times out

```text
context deadline exceeded
```

✅ Fix:

```bash
colima stop
colima delete
colima start --dns 8.8.8.8 --dns 1.1.1.1
```

Then retry:

```bash
docker pull postgres:16
```

---

### ❌ Cannot connect to Docker daemon

```text
Cannot connect to the Docker daemon
```

✅ Fix:

```bash
colima start
docker context use colima
```

---

### ❌ Image exists but container fails

```bash
docker logs <container-name>
```

---

## 🧠 Best Practices for Local Dev

- Use **Docker Compose** for services (DBs, caches, queues)
- Keep secrets in `.env` files (never commit them)
- Use named volumes for persistence
- Reset Colima if networking behaves oddly
- Avoid mixing host-installed DBs with Docker DBs

---

## 📌 Useful Commands Cheat Sheet

```bash
colima start
colima stop
colima delete

docker pull <image>
docker ps
docker logs <container>
docker exec -it <container> bash

docker compose up -d
docker compose down
docker compose down -v
```
