#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

npx @anthropic-ai/claude-code migrate-installer
~/.claude/local/claude init
