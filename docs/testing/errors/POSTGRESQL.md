<!-- markdownlint-disable MD036 -->
# PostgreSQL Errors

## 1. Authentication failures

**Symptoms**

- `FATAL: password authentication failed for user`

**Cause**

- Username/password mismatch between the container and application configuration

**Fix**

- Ensure container credentials and Spring properties match
- Prefer Testcontainers dynamic properties:

```java
registry.add("spring.datasource.username", POSTGRES::getUsername);
registry.add("spring.datasource.password", POSTGRES::getPassword);
```

## 2. Database does not exist

**Symptoms**

- `FATAL: database "<name>" does not exist`

**Cause**

- Incorrect database name
- Container initialized with a different database

**Fix**

- Ensure the database name matches the container configuration:

```java
.withDatabaseName("{{app-name}}_test")
```

## 3. Connection refused

**Symptoms**

- `Connection refused`
- `could not connect to server`

**Cause**

- PostgreSQL container not fully started
- Hardcoded host/port overriding Testcontainers values

**Fix**

- Do not hardcode `spring.datasource.url`
- Always rely on:

```java
registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
```

## 4. Role does not exist

**Symptoms**

- `FATAL: role "<user>" does not exist`

**Cause**

- Username mismatch

**Fix**

- Align container username and Spring configuration

## 5. Schema permission errors

**Symptoms**

- `permission denied for schema public`

**Cause**

- Database user does not own the schema

**Fix**

```properties
spring.flyway.schemas=public
spring.jpa.properties.hibernate.default_schema=public
```

---

## 6. Host / port mistakes

**Cause**

- Connecting to `localhost:5432`
- Ignoring Testcontainers dynamic ports

**Fix**

- Never hardcode host or port
- Always use the JDBC URL from Testcontainers

---

## 7. Persistent Docker volume issues

**Cause**

- Reused Docker volumes keeping old database state

**Fix**

```bash
docker volume ls
docker volume rm <volume_name>
```

---

## 8. Golden rules for PostgreSQL in tests

- ❌ Never hardcode JDBC URLs
- ❌ Never rely on persistent DB state
- ✅ Always use Testcontainers dynamic properties
- ✅ Prefer fresh containers per test run
