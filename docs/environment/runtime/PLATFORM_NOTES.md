# ☁️ Platform Notes

## Render (Phase 1)

- Env vars configured via Render dashboard
- Secrets encrypted by Render
- Health checks:
  - `/actuator/health`
  - `/actuator/health/readiness`

No CI-driven deployments in Phase 1.

## Kubernetes / Helm (Phase 2)

Environment variables injected via:

- Helm `values.yaml`
- Kubernetes `ConfigMap`
- Kubernetes `Secret`

Helm charts support:

- image repository + tag
- env var templating
- readiness/liveness probes
