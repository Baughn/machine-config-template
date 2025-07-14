# NixOS Configuration Template

A modular NixOS configuration template using Flakes and Colmena for multi-machine deployments.

## Features

- **Flake-based** - Reproducible system configurations
- **Colmena deployment** - Easy multi-machine management
- **Modular design** - Reusable modules with `me.*` namespace
- **Agenix secrets** - Encrypted secrets management
- **Jujutsu (jj)** - Modern version control workflow
- **Automated tooling** - Update scripts, linting, and option search

## Quick Start

1. Clone this template
2. Run `./init.sh` to start the guided setup process
   - Claude Code will help you:
     - Import existing `/etc/nixos` configuration
     - Set up the machine as `machines/$(hostname)`
     - Update `flake.nix` with your system
     - Give you a quick tour of the tooling

## Structure

```
├── machines/         # Per-machine configurations
├── modules/          # Shared modules (me.* options)
├── quirks/           # Hardware-specific fixes
├── secrets/          # Encrypted secrets (agenix)
├── tools/            # Custom Rust tools
├── flake.nix         # Flake definition
├── update.py         # Interactive update tool
└── CLAUDE.md         # AI assistant instructions
```

## Key Commands

- `./update.py` - Update and preview changes
- `colmena apply --on <host>` - Deploy to specific machine
- `./tools-for-claude/search-options.sh` - Search NixOS options
- `jj status` / `jj commit` - Version control (not git!)

## License

MIT
