{
  description = "Machine configurations for all my machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-kernel.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-kernel, nix-index-database, colmena, agenix, home-manager, ... }: {
    packages.x86_64-linux.options = (import (nixpkgs.outPath + "/nixos/release.nix") { }).options;

    # Colmena deployment configuration
    colmenaHive = colmena.lib.makeHive {
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
      };

      defaults = { pkgs, ... }: {
        imports = [
          nix-index-database.nixosModules.nix-index
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./secrets
        ];

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

        # Deployment defaults
        deployment = {
          targetUser = "root";
          buildOnTarget = false;
          replaceUnknownProfiles = true;
        };
      };

      # Add machines like this:
      # $(hostname) = { name, nodes, ... }: {
      #  imports = [
      #    ./machines/saya/configuration.nix
      #  ];
      #  # Deployment configuration
      #  deployment = {
      #    targetHost = "$(hostname)";   # E.g. maki.local
      #    allowLocalDeployment = true;  # Only for the primary (control) machine
      #  };
      #};
    };
  };
}

