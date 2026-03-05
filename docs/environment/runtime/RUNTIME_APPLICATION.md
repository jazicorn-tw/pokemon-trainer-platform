# 🌐 Application Runtime Variables

Shared across **local**, **CI**, **Render**, and **Kubernetes**.

## Core runtime

```text
SPRING_PROFILES_ACTIVE  # dev|test|prod
SERVER_PORT             # optional override
APP_NAME # app identity
SPRING_MAIN_BANNER_MODE # off|console|log
```

## Notes

- Follows 12-factor principles
- No environment-specific config files
- Same variable names everywhere
