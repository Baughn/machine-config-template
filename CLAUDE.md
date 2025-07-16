# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# IMPORTANT: Initialization mode

This is a NixOS configuration repository template in initial configuration.
The current directory contains only a template. In order to finish initialization, you should:
- Give a basic overview and explanation of the purpose of this repository, and the process you're about to start. Simultaneously, ask the user for the purpose of this machine.
- Read the current machine configuration from /etc/nixos.
- Copy it to machines/$(hostname). Make sure to cross-reference with the contents of modules/, and split out settings as applicable. Specifically, do not specify anything in the machine-specific config that is already in the module defaults. The machine-specific config should contain only hardware-specific and genuinely local settings that would never apply elsewhere. You can delete extraneous comments instead of copying them from /etc/nixos. Put a comment at the top of the file(s) to this effect.
- Check the GPU type with `nix-shell -p pciutils --run lspci`. Import modules/nvidia.nix if applicable.
- Add the machine to flake.nix as a colmena machine. You do not need a standard nixos system config.
- Define the initial username and host key in secrets/. Note: init.sh has already generated an SSH key if needed. Read the user's SSH public key from ~/.ssh/id_ed25519.pub and add it to the username array in secrets/secrets.nix. The key has already been added to ~/.ssh/authorized_keys.
- Delete this section of CLAUDE.md. Update the nixos configuration section.
- Confirm that the system builds.
- Commit with jj.
- Finally, give the user a basic introduction to the functionality of pull.sh, push.sh, update.py, add-package.sh and colmena.
Create a todo list now.

Don't make assumptions about modules/; you should read it first.

# Project: NixOS Configuration

This repository contains NixOS configuration files for zero machines:
- **hostname here**: One-line description

## Important Context

The user is not an experienced NixOS user.
If asked to take any action, always stop and ask clarifying questions first.

### Architecture Overview
The configuration uses:
- **Nix Flakes** for reproducible builds
- **Colmena** for deployment management
- **Modular design** with shared modules in `modules/`
- **Machine-specific** configurations in `machines/` (saya, tsugumi, v4)
- **Agenix** for secrets management (encrypted .age files in `secrets/`)
- **Custom tools** in `tools/` (Rust-based services and utilities)

## Essential workflows

### Adding a package, tool, piece of software or service

1. Use mcp-nixos to check for a NixOS option for the piece of software. Servers are typically in the service hierarchy. Programs (steam, mtr, etc.) are typically under programs.
2. Use the service/programs option, if one exists. Offer suggestions as to potential extra configuration that might be useful.
3. If and ONLY if there is no such option, then use the mcp-nixos package search. Assuming a package is found, use ./add-package.sh to add it; then run `colmena apply`.

## Essential Commands

### Build and Deploy
```bash
# Check configuration validity
nix flake check

# Build and view changes (using update.py is preferred for the user, colmena for claude)
./update.py  # Interactive update with diff viewing

# Manual deployment with Colmena
colmena apply --on saya    # Deploy to specific machine
colmena apply              # Deploy to all machines
colmena apply-local --sudo # Deploy to current machine only

# View what would change
nixos-rebuild dry-activate --flake .#hostname
```

### Linting and Formatting

Runs automatically; fix lints if they arise.

### Testing
```bash
# Run comprehensive checks
nix flake check

# Run VM tests
nix build .#tests.basic-desktop.x86_64-linux
```

## Version Control
**IMPORTANT**: This project uses Jujutsu (jj) instead of Git. DO NOT use git commands.

```bash
jj status          # Show working copy changes
jj diff            # Show diff of changes
jj commit -m "feat(module): Add feature"  # Commit with Conventional Commits format
jj squash          # Squash into previous commit
jj log --limit 5   # Show recent commits
jj undo            # Undo last operation if mistake made
```

### Commit Message Format
Use Conventional Commits specification:
- `feat(scope):` New feature
- `fix(scope):` Bug fix
- `chore(scope):` Maintenance
- `refactor(scope):` Code restructuring
- `docs(scope):` Documentation

## Code Style and Conventions

### Module Organization
- Shared modules in `modules/` export options under `me.*`
- Machine configs import modules and set machine-specific values
- Application lists in `modules/cliApps.json` and `modules/desktopApps.json`
- Hardware quirks in `quirks/` for specific hardware issues

## Secrets Management
- Secrets are managed with agenix
- Encrypted `.age` files in `secrets/`
- Only secrets for the current host are decrypted
- Never commit unencrypted secrets

## Machine-Specific Notes

Nothing yet.

## Common Tasks

### Adding a New Module
1. Create module file in `modules/`
2. Add to imports in `modules/default.nix`
3. Use `me.*` namespace for machine-specific options

### Updating Dependencies
```bash
python update.py  # Interactive update process
# OR manually:
nix flake update
colmena build
```

## Important Files
- `flake.nix` - Main entry point and system definitions
- `update.py` - Automated update script with diff viewing
- `modules/default.nix` - Core module importing all others
- `modules/desktop.nix` - Desktop-specific configuration
- `secrets/secrets.nix` - Age encryption key management

## Troubleshooting
- New files break the build until committed with `jj commit`
- Use `nix flake check` to validate configuration
- Check `jj status` before committing to ensure all files are tracked
- For option errors, use `search-options.sh` to verify correct syntax
- Deployment failures: check machine connectivity and SSH access

## Additional Context
- Nothing yet
