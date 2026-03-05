<!-- markdownlint-disable-file MD009 -->

# ✅ Local Environment Onboarding Checklist

> **Purpose**: A fast, no-nonsense checklist to confirm your local environment is ready to contribute.
>
> **Setting up from the template for the first time?** Use [`PROJECT_SETUP.md`](./PROJECT_SETUP.md) instead —
> it covers placeholder replacement, env files, bootstrap, and first run.
>
> This checklist is for verifying an already-configured environment (new team member, machine rebuild, etc.).
> For background and explanations, see [`onboarding/README.md`](./README.md).

---

## 🧠 Mindset (Read Once)

- [ ] I understand this project is **quality‑gate first**
- [ ] I will run checks locally **before** pushing
- [ ] I expect Docker + PostgreSQL + Testcontainers everywhere

---

## 🖥️ System Prerequisites

### OS & Shell

- [ ] macOS or Linux (WSL2 is acceptable)
- [ ] Bash available (`bash --version`)

### Git

- [ ] Git installed (`git --version`)
- [ ] Repo cloned successfully
- [ ] I can create and switch branches

---

## ☕ Java & Build Tooling

- [ ] Java **21** installed (`java -version`)
- [ ] `JAVA_HOME` is set correctly
- [ ] Gradle wrapper works (`./gradlew -v`)

---

## 🐳 Container Runtime

- [ ] **One** container runtime installed:
  - [ ] Docker Desktop **or**
  - [ ] Colima
- [ ] Docker daemon running (`docker ps`)
- [ ] Sufficient memory allocated (≥ 4–6 GB recommended)

---

## 📦 Project Configuration

- [ ] `.env` file exists in repo root
- [ ] Environment variables load correctly
- [ ] No secrets committed to Git

---

## 🧪 Local CI & Tooling

- [ ] `act` installed (`act --version`)
- [ ] `~/.actrc` exists (📄 [`docs/tooling/ACTRC.md`](../../tooling/ACTRC.md))
- [ ] `.actrc` permissions are safe (`600` recommended)

---

## 🩺 Doctor Check (Required)

- [ ] I ran:

  ```bash
  make doctor
  ```

- [ ] Doctor **passes** or only reports understood warnings
- [ ] I fixed any failures before continuing
- [ ] Project-level checks pass:

  ```bash
  make check-all
  ```

---

## 🧱 Build & Test Readiness

- [ ] Project builds:

  ```bash
  ./gradlew build
  ```

- [ ] Tests pass locally:

  ```bash
  ./gradlew test
  ```

- [ ] Testcontainers can start PostgreSQL containers

---

## 🔁 CI Parity (Strongly Recommended)

- [ ] I can run local CI simulation:

  ```bash
  make act
  ```

- [ ] CI jobs start without environment errors
- [ ] Failures match what I would expect in GitHub Actions

---

## ✅ Final Confidence Check

Before opening a PR, I can confidently say:

- [ ] My local environment matches CI assumptions
- [ ] I understand the main Make targets
- [ ] I won’t break the pipeline accidentally 🙂

---

## 🟢 Ready

If everything above is checked, you are **fully onboarded** 🎉  
Welcome aboard.
