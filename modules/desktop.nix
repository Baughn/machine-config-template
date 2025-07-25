# Desktop environment configuration for machines with graphical interfaces
# Enables audio, gaming support, and installs GUI applications
{ config, lib, pkgs, ... }:

{
  imports = [
    ./performance-desktop.nix
  ];

  # Allow things that need real-time (like sound) to get real-time.
  security.rtkit.enable = true;

  boot.kernel.sysctl = {
    # Increase max_map_count for compatibility with modern games via Proton/Wine.
    "vm.max_map_count" = 2147483642;
  };

  services = {
    ananicy.enable = true;

    # Audio
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Package management
    flatpak.enable = true;
  };

  # Gaming
  programs.steam = {
    enable = true;
  };

  # Enable KDE.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Desktop applications
  environment.systemPackages = with pkgs;
    let
      desktopApps = builtins.fromJSON (builtins.readFile ./desktopApps.json);
    in
    map (name: pkgs.${name}) desktopApps;
}
