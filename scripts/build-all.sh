#!/usr/bin/env bash
# Build the fixed PG 18.3 fusion stack in dependency order.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
BABELFISH_DIR="${BABELFISH_DIR:-$ROOT_DIR/components/babelfish}"
MYSQL_EXT_DIR="${MYSQL_EXT_DIR:-$ROOT_DIR/components/mysql}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"

for dir in "$KERNEL_DIR" "$BABELFISH_DIR" "$MYSQL_EXT_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "missing component directory: $dir" >&2
        echo "run: git submodule update --init --recursive" >&2
        exit 1
    fi
done

KERNEL_DIR="$KERNEL_DIR" PREFIX="$PREFIX" "$BABELFISH_DIR/build-all.sh"
KERNEL_DIR="$KERNEL_DIR" PREFIX="$PREFIX" "$MYSQL_EXT_DIR/build-all.sh"

echo "fusion stack installed under: $PREFIX"
