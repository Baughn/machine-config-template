#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

# Get current username
CURRENT_USER=$(whoami)

# Handle username replacement in flake.nix
if [ "$CURRENT_USER" = "nixos" ]; then
    echo -n "Enter your preferred username: "
    read PREFERRED_USER
    if [ -z "$PREFERRED_USER" ]; then
        echo "Username cannot be empty. Exiting."
        exit 1
    fi
    echo "Replacing USERNAME placeholder with '$PREFERRED_USER' in flake.nix..."
    sed -i "s/USERNAME/$PREFERRED_USER/g" flake.nix
else
    echo "Replacing USERNAME placeholder with '$CURRENT_USER' in flake.nix..."
    sed -i "s/USERNAME/$CURRENT_USER/g" flake.nix
fi

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
~/.claude/local/claude \
	--model opus init --add-dir /etc/nixos \
	--append-system-prompt "For this session your job is to execute the initialisation workflow. You control the conversation; it is your job to ask the user questions, not the other way around."
