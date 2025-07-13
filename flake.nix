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
  };

  outputs = { self, nixpkgs, nixpkgs-kernel, nix-index-database, colmena, agenix, ... }: {
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

      # Add machines like this:
      # $(hostname) = { name, nodes, ... }: {
      #  imports = [
      #    ./machines/saya/configuration.nix
      #    nix-index-database.nixosModules.nix-index
      #    agenix.nixosModules.default
      #    ./secrets
      #  ];
      #  # Setup nix-index
      #  programs.nix-index-database.comma.enable = true;
      #  # Propagate nixpkgs
      #  nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
      #  environment.etc."nixpkgs".source = nixpkgs;
      #  nix.registry.nixpkgs.flake = nixpkgs;
      #  environment.systemPackages = [
      #    colmena.packages.x86_64-linux.colmena
      #    agenix.packages.x86_64-linux.agenix
      #  ];
      #  # Deployment configuration
      #  deployment = {
      #    targetHost = "$(hostname)";  # E.g. maki.local
      #    targetUser = "root";
      #    buildOnTarget = false; # Build locally
      #    allowLocalDeployment = true;
      #    replaceUnknownProfiles = true;
      #  };
      #};
    };
  };
}

