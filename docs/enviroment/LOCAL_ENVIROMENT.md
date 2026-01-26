# 🧑‍💻 Local Environment

This project is designed to provide **fast, explicit feedback locally** while keeping **CI as the authoritative enforcer** of quality gates.

Local tooling focuses on:

- catching problems early
- auto-fixing safe issues
- reducing “works on my machine” drift

CI always runs with stricter, explicit settings.

---

## 🧰 Local settings (repo-local)

Local behavior is controlled via **repo-committed, local-only configuration files**.

These settings **must never be relied on in CI**.

### Configuration files

| File                                | Purpose                    |
| ------------------------------------| -------------------------- |
| `.config/local-settings.json`       | Base local defaults        |
| `.config/local-settings.macos.json` | macOS overrides (optional) |
| `.config/local-settings.linux.json` | Linux overrides (optional) |

These files are safe to commit because they:

- only affect **local developer ergonomics**
- do **not** change CI behavior
- do **not** affect production builds

---

## 🔄 Precedence order

Local settings are resolved in the following order (highest wins):

1. **CLI flags** (debugging / one-off runs)
2. **Environment variables** (CI or explicit overrides)
3. **OS-specific local settings** (e.g. `local-settings.macos.json`)
4. **Base local settings** (`local-settings.json`)

This ensures CI and release pipelines always remain explicit and predictable.

---

## ✅ Executable bit checks

Tracked scripts and git hooks **must be executable** to function correctly.

This is enforced via:

```bash
scripts/check-executable-bits.sh
```

### Why this exists

- Git ignores non-executable hooks (`.githooks/*`)
- Shell scripts under `scripts/` may fail with `permission denied`
- File mode drift commonly occurs after:
  - fresh clones
  - zip downloads
  - filesystem differences (macOS / Linux)

---

### Configuration options

From `local-settings.json`:

```json
{
  "checks": {
    "executableBits": {
      "strict": 2,
      "autoStage": true
    }
  }
}
```

#### `strict` values

| Value | Behavior                                          |
| ----- |-------------------------------------------------- |
| `0`   | Warn only                                         |
| `1`   | Fail immediately                                  |
| `2`   | Auto-fix (`chmod +x`), then fail if still broken  |

#### `autoStage`

- `true` → automatically `git add` file mode changes
- `false` → developer must stage manually

---

## 🧪 Inspect active local settings

To see the **effective configuration** after merging base + OS override:

```bash
make local-settings
```

or directly:

```bash
./scripts/check-executable-bits.sh --print-config
```

---

## 🧩 Hooks + bootstrap

This repo uses **repo-managed git hooks** under `.githooks/`.

The `make hooks` target configures your machine to use them:

```bash
make hooks
```

Under the hood, it runs an OS-specific bootstrap script:

- macOS: `./scripts/bootstrap-macos.sh`
- Linux: `./scripts/bootstrap-linux.sh`

Both call a shared helper:

- `./scripts/bootstrap-common.sh`

What bootstrap does (best effort):

- Fixes executable bits for files in `scripts/` and `.githooks/`
- Sets `git config core.hooksPath .githooks`

---

## 🏗 Makefile integration

Local settings are wired through the Makefile using the `LOCAL_SETTINGS` variable:

```make
LOCAL_SETTINGS ?= .config/local-settings.json
```

Targets that rely on local settings pass this explicitly:

```make
CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)"
```

This keeps behavior:

- explicit
- debuggable
- overrideable by CI

---

## 🧪 CI behavior (important)

CI **must not** rely on local settings.

Instead, CI sets explicit environment variables, for example:

```bash
STRICT=1 AUTO_STAGE=0 make test-ci
```

This guarantees:

- no silent auto-fixes in CI
- deterministic enforcement
- consistent failure modes

---

## 🧭 Design principles

- **Auto-fix locally, enforce in CI**
- **Local ergonomics ≠ policy**
- **Fast feedback beats late failure**
- **Explicit over magical**

Local settings are guardrails — not loopholes.
