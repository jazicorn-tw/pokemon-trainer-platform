<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# 🧰 Make macros + variables — how it works in this repo

This repo uses Make as a **thin orchestration layer**:

- **targets** group commands into discoverable “verbs” (`make run-ci`, `make clean-act`)
- **variables** act like **knobs** you can override per run or persist in `.vars`
- **macros** (`define` + `$(call ...)`) are **reusable blocks of recipe lines**

If you understand one idea, make it this:

> **Make expands text first, then the shell runs it.**

So most “logic” here is either:

1) **Make-time** (conditionals, variable expansion, include order), or
2) **Run-time** (shell `if`, file checks, calling tools like `du`, `rm`, `colima`)

---

## 1) Targets: “verbs” you can run

A Make *target* is a named thing you run:

```makefile
.PHONY: clean-act

clean-act:
 @echo "cleaning act stuff..."
```

Run it:

```bash
make clean-act
```

### `.PHONY` matters

`.PHONY` tells Make this target is **not a file**. Without it, if a file named `clean-act`
exists, Make may think the target is already “up to date” and skip it.

---

## 2) Variables: knobs with defaults + overrides

### Default values with `?=`

In this repo, defaults are usually expressed with `?=`:

```makefile
ACT_GRADLE_CACHE_WARN_GB ?= 8
```

Meaning:

- if the variable is **not set already**, default it to `8`

### Override precedence (high → low)

Make decides the “final value” of a variable using this general precedence:

1. **Command line**: `make clean-act ACT_GRADLE_CACHE_WARN_GB=12`
2. **Environment**: `ACT_GRADLE_CACHE_WARN_GB=12 make clean-act`
3. **Makefile assignments** (`=` / `:=`)
4. **Makefile defaults** (`?=`)

So if you run:

```bash
make clean-act ACT_GRADLE_CACHE_WARN_GB=12
```

the default `8` is ignored for that run.

### Persisting overrides in `.vars`

If your repo loads `.vars` (common in your setup), you can make overrides persistent:

```text
# .vars
ACT_GRADLE_CACHE_WARN_GB=12
ACT_GRADLE_CACHE_REMOVE=auto
```

Then just:

```bash
make clean-act
```

---

## 3) Are these “default act vars”?

No.

Variables like these:

- `ACT_GRADLE_CACHE_WARN_GB`
- `ACT_GRADLE_CACHE_REMOVE`
- `ACT_COLIMA_DISK_MIN_FREE_GB`

are **not built-in to act**.

They are **repo-defined Make variables**. `act` never sees or cares about them unless
you explicitly pass them into an `act` command (e.g., as `-s` secrets or env).

They “work” because your Make recipes read them and decide what to do.

---

## 4) Macros: reusable blocks of recipe lines

Make “macros” in this repo use `define` + `$(call ...)`.

### Defining a macro

```makefile
define say-hello
 @echo "hello"
endef
```

This does **nothing** by itself. It’s just a named multi-line text block.

### Using a macro

```makefile
greet:
 $(call say-hello)
```

When you run `make greet`, Make **pastes the macro text into the recipe**.

---

## 5) The 3 layers you’re dealing with

This is the most important “why is this confusing” section.

### Layer A: Make language (parsed by Make)

- `define ... endef`
- `ifeq (...) ... endif`
- `$(VAR)`
- `$(call ...)`
- `include ...`

### Layer B: Shell language (parsed by `/bin/sh`)

Inside recipes (TAB-indented lines), you’re writing shell:

- `if [ -d ... ]; then ... fi`
- `rm -rf ...`
- `du -sh ...`

### Layer C: Escaping between them

If you want the shell to see `$`, you often must write `$$` so Make outputs a literal `$`.

Example:

```makefile
 @awk '{print $$1}'
```

Make turns `$$1` into `$1` before the shell runs it.

---

## 6) Make-time `ifeq` vs shell `if`

### Make-time conditionals: control whether lines exist at all

```makefile
ifeq ($(ACT_GRADLE_CACHE_REMOVE),true)
 @rm -rf .gradle-act
endif
```

If false, Make never emits the `rm` line.

Use this when:

- you want a **compile-time gate**
- you want a block to disappear completely unless enabled

### Shell conditionals: runtime checks

```makefile
 @if [ -d ".gradle-act" ]; then rm -rf .gradle-act; fi
```

Use this when:

- you need to inspect the filesystem *at run time*
- the decision depends on actual machine state

---

## 7) Example: the act Gradle cache cleaner

You created a macro roughly like this (simplified):

```makefile
ACT_GRADLE_CACHE_WARN_GB ?= 8
ACT_GRADLE_CACHE_REMOVE ?= false

define clean-act-gradle-cache
 @# compute size, warn if > threshold
 @# delete only if ACT_GRADLE_CACHE_REMOVE=true|auto
endef

clean-act:
 $(call clean-act-gradle-cache)
```

What happens when you run:

```bash
make clean-act
```

1) Make chooses the final values (defaults apply).
2) Make expands `$(call clean-act-gradle-cache)` into actual recipe lines.
3) The shell executes those lines.
4) The warning prints **because the shell code ran `du` and compared sizes**.

So it feels “magic” because the var changes behavior, but it’s just:

- Make substitution + shell execution

---

## 8) When you should use a separate script

You *don’t have to* write scripts for everything. But scripts are better when:

- the recipe is getting long / unreadable
- the escaping (`$$`) is getting painful
- you want to reuse logic outside Make
- you want testability and clearer error handling
- you need portability beyond basic POSIX shell behavior

A good rule of thumb in this repo:

- **Small logic** (a few commands) can live in Make
- **Complex logic** should move to `scripts/` and Make should call it

---

## 9) Best practices used in this repo

### Keep policy in config, behavior in tooling

- **Defaults / knobs**: `20-configuration.mk`
- **Reusable helpers**: `50-util.mk` (or a focused `act` decade file)
- **Public entrypoints**: `30-interface.mk` for help/UX, and appropriate decades for behavior

### Prefer safe defaults

- destructive actions should be **opt-in** (`ACT_GRADLE_CACHE_REMOVE=false` by default)
- “auto” modes should be conservative and no-op when unsure

### Prefer `?=` for defaults

Use:

- `?=` for defaults that users can override
- `:=` when you need immediate evaluation (rare; see next section)

---

## 10) Quick reference: `=`, `:=`, `?=` and friends

### `=` (recursive expansion)

```makefile
FOO = $(BAR)
```

`FOO` is evaluated **when used**, not when assigned.

### `:=` (simple expansion)

```makefile
FOO := $(BAR)
```

`FOO` is evaluated **right now** (at parse time).

### `?=` (default)

```makefile
FOO ?= value
```

Sets only if not already set.

### `+=` (append)

```makefile
FOO += more
```

Appends (space-separated).

---

## 11) Debugging tricks

### Print a variable’s final value

```makefile
print-%:
 @echo "$*=$($*)"
```

Then:

```bash
make print-ACT_GRADLE_CACHE_WARN_GB
```

### Dry run the recipes (see what would run)

```bash
make -n clean-act
```

### Verbose Make (see expansions and decisions)

```bash
make --debug=v clean-act
```

---

## 12) Cheat sheet

### One-off override

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=true
```

### Persistent override via `.vars`

```text
ACT_GRADLE_CACHE_REMOVE=auto
ACT_GRADLE_CACHE_WARN_GB=12
```

### Dry-run deletion

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=true ACT_GRADLE_CACHE_DRY_RUN=true
```

---

## 13) Mental model recap

- **Target** = a named command you run
- **Variables** = knobs controlling behavior (defaults via `?=`)
- **Macro** = a reusable block of recipe lines (`define` + `$(call ...)`)
- **Make expands text first**
- **Shell runs the result**
