# 🔀 CI Feature Flags (GitHub Actions)

These variables control **when CI publishes artifacts or performs deployments**.

They allow emergency shutdowns and prevent accidental publishing from forks.

## Variables

```text
PUBLISH_DOCKER_IMAGE    # true|false — enable Docker image publishing
CANONICAL_REPOSITORY   # <owner>/<repo> — only allowed publishing repo

PUBLISH_HELM_CHART     # (future) enable Helm publishing
DEPLOY_ENABLED         # (future) global deploy kill switch
ENABLE_SEMANTIC_RELEASE # optional gate for semantic-release
```

## Publishing rules

Publishing occurs **only if all conditions are met**:

1. `PUBLISH_DOCKER_IMAGE == true`
2. Repository matches `CANONICAL_REPOSITORY`
3. Workflow runs on a semantic-release tag (`vX.Y.Z`)

## Rationale

- Prevents accidental releases
- Allows instant shutdown without code changes
- Keeps release versioning decoupled from delivery
