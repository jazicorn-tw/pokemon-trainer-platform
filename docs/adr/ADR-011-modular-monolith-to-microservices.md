# ADR-010 (Draft): Modular Monolith → Microservices

- **Status:** Proposed
- **Scope:** System architecture evolution

---

## Context

The {{project-name}} is currently implemented as a **modular monolith**
containing Inventory, Trading, and Marketplace bounded contexts.

This structure prioritizes correctness, shared infrastructure, and developer experience.

As the platform evolves, independent deployment and scaling may be required.

---

## Decision (Proposed)

- Extract bounded contexts into independently deployable services
- Maintain a monorepo with shared tooling and standards
- Use Kubernetes and Helm for per-service deployment
- Preserve semantic-release–driven versioning per service

---

## Migration Strategy

1. Stabilize module boundaries
2. Extract Trading service first
3. Introduce inter-service APIs
4. Split databases if required
5. Deploy services independently

---

## Consequences

### Benefits

- Independent deploys
- Targeted scaling
- Clear ownership boundaries

### Costs

- Increased operational complexity
- Distributed system concerns

---

## Notes

This ADR will be finalized only when the monolith shows clear pressure points.
