# IMPORTANT: If you're updating from an older version of this template and seeing
# merge conflicts, please read MIGRATION.md for detailed migration instructions.
{
  description = "Machine configurations for all my machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-kernel.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-kernel, determinate, nix-index-database, colmena, agenix, home-manager, ... }@inputs:
    let
      # Helper to extract just the options.json file from a derivation
      extractOptionsJson = system: optionsDrv: docPath:
        nixpkgs.legacyPackages.${system}.runCommand "options.json" { } ''
          cp ${optionsDrv}/${docPath} $out
        '';

      # Common modules for all NixOS systems
      commonModules = [
        determinate.nixosModules.default
        nix-index-database.nixosModules.nix-index
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        ./secrets
        {
          # Setup nix-index
          programs.nix-index-database.comma.enable = true;

          # Propagate nixpkgs
          nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
          environment.etc."nixpkgs".source = nixpkgs;
          nix.registry.nixpkgs.flake = nixpkgs;

          # Load packages necessary to build this config
          environment.systemPackages = [
            colmena.packages.x86_64-linux.colmena
            agenix.packages.x86_64-linux.agenix
          ];

          # Bare-minimum home-manager setup
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.USERNAME = ./home/home.nix;
          # Automatically clobber pre-HM files
          home-manager.backupFileExtension = "backup";
        }
      ];

      # Helper function to create a NixOS configuration
      mkNixosConfiguration = { system ? "x86_64-linux", modules }: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = commonModules ++ modules ++ [{
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            # Reuse existing overlay for zen kernel
            (final: prev: {
              inherit ((import nixpkgs-kernel {
                inherit (prev) system;
                config.allowUnfree = true;
              })) linuxPackages_zen;
            })
          ];
        }];
        specialArgs = { inherit inputs; };
      };

      # Machine configurations
      # During initialization, machines will be added here by following CLAUDE.md
      machineConfigs = {
        # Add your machines here following the initialization instructions in CLAUDE.md
        # Example:
        # hostname = {
        #   modules = [ ./machines/hostname/configuration.nix ];
        #   deployment = {
        #     targetHost = "hostname.local";      # or "localhost" for local machine
        #     allowLocalDeployment = true;        # Only for the primary (control) machine
        #     tags = [ "remote" ];                # Only for remote machines
        #   };
        # };
      };
    in
    {
      packages.x86_64-linux.options = extractOptionsJson "x86_64-linux"
        (import (nixpkgs.outPath + "/nixos/release.nix") { }).options
        "share/doc/nixos/options.json";

      # Build all machine configurations at once (for update.py)
      packages.x86_64-linux.all-systems = nixpkgs.legacyPackages.x86_64-linux.linkFarm "all-systems"
        (builtins.map
          (name: {
            name = name;
            path = self.nixosConfigurations.${name}.config.system.build.toplevel;
          })
          (builtins.attrNames machineConfigs));

      # NixOS configurations for standard nixos-rebuild
      nixosConfigurations = builtins.mapAttrs
        (name: config:
          mkNixosConfiguration { modules = config.modules; }
        )
        machineConfigs;

      # Colmena deployment configuration
      colmenaHive = colmena.lib.makeHive ({
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [
              # Reuse existing overlay for zen kernel
              (final: prev: {
                inherit ((import nixpkgs-kernel {
                  inherit (prev) system;
                  config.allowUnfree = true;
                })) linuxPackages_zen;
              })
              # Add Colmena overlay
              colmena.overlays.default
            ];
          };
          specialArgs = { inherit inputs; };
        };

        defaults = { name, nodes, ... }: {
          imports = commonModules;

          # Deployment defaults
          deployment = {
            targetUser = "root";
            buildOnTarget = false;
            replaceUnknownProfiles = true;
          };
        };
      } // (builtins.mapAttrs
        (name: config: { ... }: {
          imports = config.modules;
          deployment = config.deployment // {
            targetUser = "root";
            buildOnTarget = false;
            replaceUnknownProfiles = true;
          };
        })
        machineConfigs));
    };
}
