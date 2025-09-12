# Base configuration applied to every machine in the fleet
# Provides essential system settings, nix configuration, and universally needed CLI tools
{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./networking.nix
    ./performance-default.nix
    ./neovim.nix
  ];

  # Enable enhanced Neovim configuration
  me.neovim.enable = true;

   # Would prefer zram, but it's broken
   boot.tmp.cleanOnBoot = true;

  # Security?
  security.sudo.wheelNeedsPassword = false;

  # The default is 'performance', which is unnecessary.
  powerManagement.cpuFreqGovernor = "schedutil";

  ## Nix settings
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    eval-cores = 4;
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
  };

  # Enable all terminfo entries system-wide
  environment.enableAllTerminfo = true;

  # Shell configuration
  users.defaultUserShell = pkgs.zsh;

  # Software that I use virtually everywhere
  environment.systemPackages = with pkgs;
    let
      cliApps = builtins.fromJSON (builtins.readFile ./cliApps.json);
    in
    map (name: pkgs.${name}) cliApps;
}
