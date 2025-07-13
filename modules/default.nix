# Base configuration applied to every machine in the fleet
# Provides essential system settings, nix configuration, and universally needed CLI tools
{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./networking.nix
  ];

  # Use RAM for /tmp, but like, efficiently.
  boot.tmp.useZram = true;

  # Security?
  security.sudo.wheelNeedsPassword = false;

  # The default is 'performance', which is unnecessary.
  powerManagement.cpuFreqGovernor = "schedutil";

  ## Nix settings
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  ## Using nix-index instead, for flake support
  programs = {
    command-not-found.enable = false;

    ## Non-nix development
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
      ];
    };

    # Editor configuration
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Shell configuration
  users.defaultUserShell = pkgs.zsh;

  # Software that I use virtually everywhere
  environment.systemPackages = with pkgs;
    let
      cliApps = builtins.fromJSON (builtins.readFile ./cliApps.json);
    in
    map (name: pkgs.${name}) cliApps;
}
