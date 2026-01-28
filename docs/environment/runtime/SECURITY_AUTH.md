# 🔐 Security & Authentication

JWT-based authentication configuration.

## Variables

```text
JWT_SECRET
JWT_EXPIRATION_SECONDS
JWT_ISSUER
JWT_AUDIENCE
```

## Notes

- Secrets must come from platform secret storage
- Never log or echo secret values
- Issuer/Audience become required once validation is enforced
