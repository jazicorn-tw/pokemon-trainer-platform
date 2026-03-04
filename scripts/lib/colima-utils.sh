#!/usr/bin/env bash
# scripts/lib/colima-utils.sh — Colima introspection helpers. Source; do not execute.

colima_running() {
  local _profile="${1:-default}"
  command -v colima >/dev/null 2>&1 || return 1
  colima status --profile "${_profile}" >/dev/null 2>&1
}

colima_containerd_free_gb() {
  local _profile="${1:-default}"
  colima ssh --profile "${_profile}" -- sh -lc \
    'df -BG /var/lib/containerd 2>/dev/null | awk "NR==2 {gsub(/G/,\"\", \$4); print \$4}"' \
    2>/dev/null || true
}

colima_containerd_free_inodes() {
  local _profile="${1:-default}"
  colima ssh --profile "${_profile}" -- sh -lc \
    'df -Pi /var/lib/containerd 2>/dev/null | awk "NR==2 {print \$4}"' \
    2>/dev/null || true
}
