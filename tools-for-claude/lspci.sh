#!/usr/bin/env nix-shell
#!nix-shell -p pciutils -i bash

lspci "$@"
