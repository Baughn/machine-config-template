#!/usr/bin/env bash

tools-for-claude/format-nix.sh || exit 2
if command -v colmena > /dev/null 2>&1; then
  colmena build || exit 2
fi
