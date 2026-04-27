#!/usr/bin/env bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: transfer-nix-store.sh <hostname> [user] [remote-parent-dir]

Copy the local /nix/store to a remote device using sftp.

Arguments:
	hostname            Target hostname or IP (required)
	user                SSH user on target (optional, default: current user)
	remote-parent-dir   Parent directory on target (optional, default: /nix)

Examples:
	transfer-nix-store.sh my-host
	transfer-nix-store.sh my-host root
	transfer-nix-store.sh my-host root /nix

This uploads /nix/store recursively using sftp as:
	put -r /nix/store <remote-parent-dir>
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

HOSTNAME="${1:-}"
USER_NAME="${2:-$USER}"
REMOTE_PARENT_DIR="${3:-/nix}"

if [[ -z "$HOSTNAME" ]]; then
	echo "Error: hostname is required."
	echo
	usage
	exit 1
fi

if [[ ! -d "/nix/store" ]]; then
	echo "Error: local /nix/store does not exist."
	exit 1
fi

if ! command -v sftp >/dev/null 2>&1; then
	echo "Error: sftp is not installed or not in PATH."
	exit 1
fi

TARGET="${USER_NAME}@${HOSTNAME}"

echo "Starting transfer of /nix/store to ${TARGET}:${REMOTE_PARENT_DIR}"
echo "This can take a long time depending on store size and bandwidth."

sftp -b - "$TARGET" <<EOF
put -r /nix/store ${REMOTE_PARENT_DIR}
EOF

echo "Transfer finished."
