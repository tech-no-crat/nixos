# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };
  hardware.enableRedistributableFirmware = true;
  hardware.uinput.enable = true;
  services.openssh.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [
    "video=DP-1:2560x1440@144"
    "video=DP-2:2560x1440@144"
  ];
  boot.kernelModules = [ "iwlwifi" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos"; # Define your hostname.

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure WoWLAN policy for your interface (replace 'wlan0' if needed)
  networking.interfaces.wlp11s0.wakeOnLan.enable = true;
  
  networking.interfaces.eno1.wakeOnLan.enable = true;
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers =  with pkgs; [ 
    cups-filters
    gutenprint
    samsung-unified-linux-driver
    splix
     ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shyam = {
    isNormalUser = true;
    description = "shyam";
    extraGroups = [ "networkmanager" "wheel" "uinput" "input"];
    packages = with pkgs; [
      thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "shyam";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
#    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
#    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  neovim
  git
  pkgs.sunshine
  pkgs.discord
#  pkgs.heroic
  pkgs.vscode
  pkgs.obsidian
  pkgs.ethtool
  pkgs.iw
  ];
  
  # Enables the 1Password CLI
  programs._1password = { enable = true; };

  # Enables the 1Password desktop app
  programs._1password-gui = {
  enable = true;
  # this makes system auth etc. work properly
  polkitPolicyOwners = [ "shyam" ];
  };
  
  systemd.services.sunshine = {
    enable = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    applications = {
      apps = [
        {
          name = "SteamBigPicture";
          prep-cmd = [
          ];
          detached = [
            "setsid steam steam://open/bigpicture"
          ];
          auto-detach = "true";
          image-path = "steam.png";
        }
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
    #     {
    #       name = "MoonDeckStream";
    #       cmd = "MoonDeckStream";
    #       auto-detach = "false";
    #     }
      ];
    };
  };

  #Enable Tailscale

  services.tailscale.enable = true;
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  # };

  # List services that you want to enable:




  # Open ports in the firewall.
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
  allowedUDPPortRanges = [
    { from = 47998; to = 48000; }
    { from = 8000; to = 8010; }
    { from = 9; to = 9; }
    ];
  };
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
