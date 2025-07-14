#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    
    # Add to authorized_keys for local access
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "SSH key generated and added to authorized_keys"
fi

npx @anthropic-ai/claude-code migrate-installer
~/.claude/local/claude init
