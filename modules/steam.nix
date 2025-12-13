{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    # Optional: Open ports for Steam Remote Play if you use it
    # remotePlay.openFirewall = true; 
    # dedicatedServer.openFirewall = true;
  };

  # Often required for Steam games
  hardware.graphics.enable = true; 
}
