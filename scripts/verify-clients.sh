#!/usr/bin/env bash
# Verify the externally supplied protocol clients selected for this install.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"
MYSQL_BIN="${MYSQL_BIN:-$PREFIX/bin/mysql}"
SQLCMD_BIN="${SQLCMD_BIN:-$PREFIX/bin/sqlcmd}"

for spec in "mysql:$MYSQL_BIN:--version" "sqlcmd:$SQLCMD_BIN:-?"; do
    name="${spec%%:*}"
    rest="${spec#*:}"
    path="${rest%%:*}"
    args="${rest#*:}"
    if [ ! -x "$path" ]; then
        echo "$name client is not executable: $path" >&2
        exit 1
    fi
    echo "=== $name: $path ==="
    "$path" "$args" 2>&1 | sed -n '1,3p'
done
