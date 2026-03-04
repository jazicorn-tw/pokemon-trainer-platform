#!/usr/bin/env bash
# scripts/lib/validators.sh — input validators. Source; do not execute.

is_bool() { case "${1}" in true|false) return 0 ;; *) return 1 ;; esac; }
is_int()  { [[ "${1}" =~ ^[0-9]+$ ]]; }
