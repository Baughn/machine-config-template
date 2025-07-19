# High-performance optimizations for gaming systems
# Configures kernel parameters, memory management, I/O schedulers, and gaming utilities
{ config, lib, pkgs, ... }:

{
  # Use zen kernel for better gaming performance
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;

    # CPU optimizations for 7950X3D
    kernelParams = [
      "preempt=full" # Minimize latency
      "threadirqs"
      "amd_pstate=active" # Use CPPC-based driver for faster response
      "amd_prefcore=1" # Prefer V-Cache CCD for latency-sensitive threads
      "mitigations=off"
    ];
  };

  # GameMode for per-game performance governor switching
  programs.gamemode.enable = true;

  # System76 scheduler for better desktop responsiveness
  services.system76-scheduler.enable = true;
}
