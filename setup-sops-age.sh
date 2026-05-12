#!/usr/bin/env bash
# Setup SOPS age keys from SSH host key
# This script generates age keys from the host SSH key for use with SOPS encryption/decryption.
# Age keys are derived locally and should NEVER be committed to the repository.

set -e

SOPS_AGE_DIR="${HOME}/.config/sops/age"
SOPS_AGE_KEY_FILE="${SOPS_AGE_DIR}/keys.txt"
SSH_HOST_KEY="/persist/etc/ssh/ssh_host_ed25519_key"

echo "Setting up SOPS age keys..."

# Check if SSH host key exists
if [ ! -f "$SSH_HOST_KEY" ]; then
    echo "⚠️  SSH host key not found at $SSH_HOST_KEY"
    read -p "Would you like to generate a new SSH host key? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating SSH host key..."
        sudo mkdir -p "$(dirname "$SSH_HOST_KEY")"
        sudo ssh-keygen -t ed25519 -f "$SSH_HOST_KEY" -N "" -C "host-key-$(hostname)"
        echo "✓ SSH host key generated at $SSH_HOST_KEY"
    else
        echo "Error: SSH host key is required. Please ensure the system has generated host keys."
        exit 1
    fi
fi

# Check if ssh-to-age is available
if ! command -v ssh-to-age &> /dev/null; then
    echo "Error: ssh-to-age not found. Please install age tools."
    exit 1
fi

# Create SOPS age directory if it doesn't exist
mkdir -p "$SOPS_AGE_DIR"

# Generate age key from SSH host key
echo "Generating age key from SSH host key..."
sudo ssh-to-age -private-key -i "$SSH_HOST_KEY" > "$SOPS_AGE_KEY_FILE"

# Set permissions on the age key file
chmod 600 "$SOPS_AGE_KEY_FILE"

echo "✓ Age key successfully generated at $SOPS_AGE_KEY_FILE"
echo "✓ You can now edit SOPS secrets with: sops secrets/hosts/<hostname>.yaml"
