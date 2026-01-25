<!-- markdownlint-disable-file MD060 -->

# 🧪 Doctor JSON Output (Tooling & Automation)

Doctor can emit **structured JSON output** for tooling, diagnostics, and CI analysis.

This document describes the JSON contract and intended usage.

---

## Enabling JSON output

```bash
DOCTOR_JSON=1 ./scripts/doctor.sh
```

or:

```bash
./scripts/doctor.sh --json
```

This disables human-oriented output and prints a single JSON object.

---

## Exit semantics

Doctor reports both **status** and **exit code**.

### Status values

| Status | Meaning                            |
| ------ | ---------------------------------- |
| `pass` | All required checks passed         |
| `fail` | One or more required checks failed |
| `skip` | Doctor was skipped (e.g. CI=true)  |

### Exit codes

| Exit code | Meaning      |
| --------- | ------------ |
| `0`       | pass or skip |
| `1`       | fail         |

---

## Strict JSON mode

```bash
./scripts/doctor.sh --json --strict
```

In strict mode:

* **Warnings cause failure**
* Exit code is non-zero
* Status is `fail`

This is intended for:

* automation
* tooling
* future CI validation

It is **not** the default for local development.

---

## Makefile integration

Doctor JSON output is exposed via **Make targets** for consistency across local development, tooling, and CI.

> These targets are thin wrappers around `./scripts/doctor.sh` and do **not** add additional behavior.

### Standard JSON output

```bash
make doctor-json
```

* Emits a **single JSON object** to stdout
* Preserves normal Doctor semantics (`pass` / `fail` / `skip`)
* Exit code mirrors Doctor

### Strict JSON output

```bash
make doctor-json-strict
```

* Treats **warnings as failures**
* Intended for automation and validation tooling
* Exit code is non-zero if warnings are present

### Capturing output

```bash
make doctor-json > doctor.json
# or
make doctor-json-strict > doctor.json
```

This is useful for:

* CI artifacts
* debugging flaky runners
* attaching environment snapshots to issues

---

## jq examples

The following examples use [`jq`](https://jqlang.github.io/jq/) to consume Doctor JSON output.

> `jq` is a lightweight command-line JSON processor, commonly available on macOS and Linux.

### Inspect overall status

```bash
jq '.status' doctor.json
```

Example output:

```text
"pass"
```

---

### List warnings

```bash
jq '.warnings' doctor.json
```

---

### Count warnings

```bash
jq '.warnings | length' doctor.json
```

---

### Fail if warnings exist (automation-friendly)

```bash
jq -e '.warnings | length == 0' doctor.json
```

* Exit code `0` → no warnings
* Exit code `1` → one or more warnings present

Useful for CI or validation tooling that wants stricter behavior than local defaults.

---

### Extract environment facts

```bash
jq '.docker_provider' doctor.json
jq '.docker_memory_gb' doctor.json
jq '.java_major' doctor.json
```

---

### Pretty-print JSON

```bash
jq . doctor.json
```

---

## JSON schema

The JSON output follows this schema:

```text
docs/doctor.schema.json
```

The schema is intentionally tolerant to allow forward-compatible fields.

---

## CI usage

In CI, Doctor JSON can be used as an **environment snapshot**:

* uploaded as an artifact
* attached to logs
* used to debug flaky runners

Doctor itself does **not** enforce CI quality gates.

---

## Example output

```json
{
  "status": "pass",
  "os": "Darwin",
  "git_branch": "main",
  "java_major": "21",
  "docker_provider": "colima",
  "docker_cpus": "4",
  "docker_memory_gb": "5.773",
  "warnings": [],
  "errors": []
}
```

---

## Design intent

Doctor JSON is designed to be:

* machine-readable
* deterministic
* stable across environments
* safe for tooling consumption

Human-readable output remains the default.
