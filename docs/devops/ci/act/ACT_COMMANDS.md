<!-- markdownlint-disable-file MD036 -->

# 🧪 act Commands (repo cheat sheet)

This repo wraps `act` behind Make targets to keep local runs consistent.

---

## List jobs in a workflow

```bash
make list-ci              # defaults to ci
make list-ci ci
make list-ci build-image
```

---

## Run an entire workflow

```bash
make run-ci               # defaults to ci
make run-ci ci
make run-ci build-image
```

---

## Run a single job in a workflow

```bash
make run-ci ci test
make run-ci build-image helm-lint
```

---

## Raw act (if you need it)

Equivalent of `make run-ci ci test`:

```bash
ACT=true act push   -W .github/workflows/ci.yml   -j test   -P ubuntu-latest=catthehacker/ubuntu:full-latest   --container-daemon-socket /var/run/docker.sock   --container-architecture linux/amd64   --container-options="--user runner --group-add <docker-gid>"
```

Replace `<docker-gid>` with the GID of `/var/run/docker.sock` inside the Colima VM:

```bash
colima ssh -- stat -c '%g' /var/run/docker.sock
```

---

## Notes

- `--user runner --group-add <gid>` grants socket access without running as root.
- The Make wrapper auto-detects the GID and sets `--group-add` automatically.
- Some workflows (release/publish) are intentionally not run locally.
