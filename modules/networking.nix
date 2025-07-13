# Network configuration for local and remote connectivity
# Configures TCP optimization, firewall, mDNS discovery, and SSH access
{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    # Use the BBR congestion control algorithm for potentially better online gaming performance.
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # LAN network settings
  networking = {
    hostId = "deafbeef"; # Lets ZFS work.
    firewall.allowPing = true;
    firewall.allowedUDPPorts = [
      5353 # mDNS
      5355 # LLMNR
    ];
  };

  # mDNS configuration for local network discovery
  services.resolved = {
    extraConfig = ''
      MulticastDNS = yes
      LLMNR = yes
    '';
    enable = true;
    dnssec = "allow-downgrade";
  };

  # Services
  services.openssh.enable = true;
}
