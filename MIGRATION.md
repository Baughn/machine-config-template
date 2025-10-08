# Migration Guide: flake.nix Restructure

**If you're seeing this, you've updated your template and hit merge conflicts. This is expected!**

This guide will help you migrate your existing configuration to the new structure.

## What Changed and Why

The template's `flake.nix` has been restructured to support a better `update.py` script and more flexible configuration management. The new structure:

1. **Centralizes machine definitions** in a `machineConfigs` attribute set
2. **Generates both `nixosConfigurations` and `colmenaHive`** from the same definitions
3. **Adds `all-systems` output** for building all machines at once (faster updates)
4. **Improves maintainability** with helper functions

### Key Benefits
- Faster updates with `nix build .#all-systems` (parallel builds)
- Support for standard `nixos-rebuild` in addition to Colmena
- Cleaner separation between machine-specific and common configuration
- Better deployment prompting (separate local/remote goals)

## Expected Conflicts

You'll see conflicts in:
- **`outputs` function signature** - new helper functions added
- **`colmenaHive` section** - restructured to use `machineConfigs`
- **`packages` outputs** - new outputs added

## Migration Steps

### Step 1: Identify Your Current Machine Definitions

In your current `flake.nix`, you likely have machines defined directly in `colmenaHive` like this:

```nix
colmenaHive = colmena.lib.makeHive {
  meta = { ... };
  defaults = { ... };

  # Your machines are here:
  hostname1 = { name, nodes, ... }: {
    imports = [ ./machines/hostname1/configuration.nix ];
    deployment = {
      targetHost = "hostname1.local";
      allowLocalDeployment = true;
    };
  };

  hostname2 = { name, nodes, ... }: {
    imports = [ ./machines/hostname2/configuration.nix ];
    deployment = {
      targetHost = "hostname2.example.com";
      tags = [ "remote" ];
    };
  };
}
```

### Step 2: Extract Machine Configurations

Create a `machineConfigs` attribute set in the `let` block. Extract your machines into this format:

```nix
outputs = { self, nixpkgs, ... }@inputs:
  let
    # ... other helpers ...

    # Define your machines here
    machineConfigs = {
      hostname1 = {
        modules = [ ./machines/hostname1/configuration.nix ];
        deployment = {
          targetHost = "hostname1.local";
          allowLocalDeployment = true;
        };
      };

      hostname2 = {
        modules = [ ./machines/hostname2/configuration.nix ];
        deployment = {
          targetHost = "hostname2.example.com";
          tags = [ "remote" ];
        };
      };
    };
  in
  {
    # outputs will be generated from machineConfigs
  }
```

**Key changes:**
- Remove the `{ name, nodes, ... }:` function wrapper
- Keep `modules` and `deployment` as-is
- Remote machines should have `tags = [ "remote" ];` in deployment

### Step 3: Update Your flake.nix

The easiest approach is to:

1. **Accept the incoming changes** from the template for the entire `flake.nix`
2. **Find the `machineConfigs` attribute set** (it will be empty with just a comment)
3. **Paste your machine definitions** into `machineConfigs` using the format from Step 2

Here's what the empty `machineConfigs` looks like in the new template:

```nix
# Machine configurations
machineConfigs = {
  # Add your machines here following the initialization instructions in CLAUDE.md
  # Example:
  # hostname = {
  #   modules = [ ./machines/hostname/configuration.nix ];
  #   deployment = {
  #     targetHost = "hostname.local";
  #     allowLocalDeployment = true;  # Only for the primary machine
  #     tags = [ "remote" ];  # Only for remote machines
  #   };
  # };
};
```

### Step 4: Update USERNAME References

If your old `flake.nix` still had `USERNAME` as a placeholder (line 72 in defaults):

```nix
home-manager.users.USERNAME = ./home/home.nix;
```

Make sure it's replaced with your actual username. In the new structure, this is in the `commonModules` list:

```nix
home-manager.users.YOUR_ACTUAL_USERNAME = ./home/home.nix;
```

### Step 5: Check for Custom Modifications

If you made other customizations to your `flake.nix`:

- **Custom inputs**: Add them back to the `inputs` section
- **Custom overlays**: Add them to the overlays list in `mkNixosConfiguration` (around line 80)
- **Custom modules**: Add them to `commonModules` list (around line 43)
- **Extra system packages**: Add them to the `environment.systemPackages` in `commonModules`

## Complete Example

Here's a complete before/after example:

### Before (old structure)

```nix
outputs = { self, nixpkgs, colmena, ... }: {
  colmenaHive = colmena.lib.makeHive {
    meta = { ... };
    defaults = { ... };

    laptop = { name, nodes, ... }: {
      imports = [ ./machines/laptop/configuration.nix ];
      deployment = {
        targetHost = "localhost";
        allowLocalDeployment = true;
      };
    };

    server = { name, nodes, ... }: {
      imports = [ ./machines/server/configuration.nix ];
      deployment = {
        targetHost = "server.example.com";
        tags = [ "remote" ];
      };
    };
  };
}
```

### After (new structure)

```nix
outputs = { self, nixpkgs, colmena, ... }@inputs:
  let
    # ... helper functions from template ...

    machineConfigs = {
      laptop = {
        modules = [ ./machines/laptop/configuration.nix ];
        deployment = {
          targetHost = "localhost";
          allowLocalDeployment = true;
        };
      };

      server = {
        modules = [ ./machines/server/configuration.nix ];
        deployment = {
          targetHost = "server.example.com";
          tags = [ "remote" ];
        };
      };
    };
  in
  {
    # nixosConfigurations and colmenaHive are automatically generated
    # from machineConfigs by the template
  }
```

## Testing the Migration

After migrating, verify everything works:

1. **Check the flake is valid:**
   ```bash
   nix flake check
   ```

2. **Build all systems:**
   ```bash
   nix build .#all-systems
   ```
   or
   ```bash
   nom build .#all-systems  # prettier output
   ```

3. **Build a specific machine:**
   ```bash
   nix build .#nixosConfigurations.HOSTNAME.config.system.build.toplevel
   ```

4. **Test Colmena still works:**
   ```bash
   colmena build
   ```

5. **Try the new update script:**
   ```bash
   ./update.py
   ```

## Troubleshooting

### "attribute 'all-systems' missing"
Your `machineConfigs` might be empty. Make sure you've added your machines to it.

### "infinite recursion encountered"
Check that you removed the `{ name, nodes, ... }:` function wrapper from your machine definitions in `machineConfigs`.

### "value is a function while a set was expected"
Same as above - `machineConfigs` entries should be attribute sets, not functions.

### Colmena can't find my machines
Ensure each machine in `machineConfigs` has a `deployment` attribute with `targetHost`.

### update.py fails with "nom: command not found"
Install `nix-output-monitor`:
```bash
nix profile install nixpkgs#nix-output-monitor
```

Or edit `update.py` line 119 to use `nix` instead of `nom`:
```python
cmd = ['nix', 'build', '.#all-systems', *extra_args]
```

## Rollback Instructions

If things go wrong and you need to rollback:

1. **Using Jujutsu:**
   ```bash
   jj undo  # Undo the last operation
   jj restore flake.nix  # Restore just flake.nix
   ```

2. **Manual rollback:**
   ```bash
   jj log --limit 5  # Find the commit before migration
   jj new COMMIT_ID  # Create new change on that commit
   ```

3. **Emergency recovery:**
   If your system is broken and you need to revert:
   ```bash
   sudo nixos-rebuild switch --flake /path/to/old/flake#HOSTNAME
   ```

## Getting Help

If you're stuck:
1. Check that your `machineConfigs` follows the exact format shown in Step 2
2. Verify all paths in `modules = [ ... ]` are correct
3. Run `nix flake check` for detailed error messages
4. Compare your `machineConfigs` to the examples in this guide

## What's Next?

Once migrated, you can use the improved `update.py`:
- Builds all systems in parallel
- Better deployment prompting
- Cleaner error handling
- Automatic fallback for kernel updates

Run `./update.py` and enjoy the improvements!
