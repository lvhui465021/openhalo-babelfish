#!/usr/bin/env bash
# Link externally installed protocol clients into an OpenHalo installation.
#
# These remain their vendors' clients. In particular, sqlcmd still relies on
# its Microsoft ODBC installation, so copying only its executable is unsafe.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"
MYSQL_BIN="${MYSQL_BIN:-}"
SQLCMD_BIN="${SQLCMD_BIN:-}"

usage() {
    cat <<'EOF'
Usage: PREFIX=/opt/openhalo scripts/install-clients.sh

Links an already-installed MySQL CLI and Microsoft sqlcmd into PREFIX/bin as
mysql and sqlcmd. Override discovery with MYSQL_BIN=/path/to/mysql and
SQLCMD_BIN=/path/to/sqlcmd. This script never downloads, renames, or copies
third-party clients.
EOF
}

if [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ -z "$MYSQL_BIN" ]; then
    MYSQL_BIN="$(command -v mysql || true)"
fi
if [ -z "$SQLCMD_BIN" ]; then
    SQLCMD_BIN="$(command -v sqlcmd || true)"
fi

for spec in "mysql:$MYSQL_BIN" "sqlcmd:$SQLCMD_BIN"; do
    name="${spec%%:*}"
    path="${spec#*:}"
    if [ -z "$path" ] || [ ! -x "$path" ]; then
        echo "$name client is not executable: ${path:-not found}" >&2
        echo "Install the client first, or set ${name^^}_BIN to its executable path." >&2
        exit 1
    fi
done

MYSQL_BIN="$(realpath "$MYSQL_BIN")"
SQLCMD_BIN="$(realpath "$SQLCMD_BIN")"
install_dir="$PREFIX/bin"
mkdir -p "$install_dir"

for spec in "mysql:$MYSQL_BIN" "sqlcmd:$SQLCMD_BIN"; do
    name="${spec%%:*}"
    path="${spec#*:}"
    target="$install_dir/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "refusing to replace non-symlink client target: $target" >&2
        exit 1
    fi
    ln -sfn "$path" "$target"
    echo "linked $name: $target -> $path"
done

echo "Run scripts/verify-clients.sh before using these clients for acceptance."
