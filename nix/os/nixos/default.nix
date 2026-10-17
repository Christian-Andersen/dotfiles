{
  config,
  lib,
  pkgs,
  ...
}: let
  # Shared nixpkgs settings (allowUnfree + sqlfmt overlay): must match the
  # standalone home-manager env and the dev image so `tools` builds
  # identically everywhere. See ../../nixpkgs.nix.
  nixpkgs-settings = import ../../nixpkgs.nix;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable the Nix CLI pieces the dotfiles workflow needs (flakes, `nh`).
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config = nixpkgs-settings.config;
  nixpkgs.overlays = nixpkgs-settings.overlays;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Tailscale mesh VPN. `client` routing features set loose reverse-path
  # filtering so exit nodes / subnet routes work; authenticate with
  # `sudo tailscale up`.
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # MagicDNS only knows Tailscale node names, so alias the services hosted on
  # the `server` node. Forgejo's ROOT_URL is http://forgejo:3000.
  networking.hosts."100.71.44.108" = ["forgejo"];

  # Set your time zone.
  time.timeZone = "Australia/Canberra";

  # Launch Umbriel on boot without a display manager: autologin on tty1 and
  # exec the compositor from the login shell.
  programs.umbriel.enable = true;
  services.getty.autologinUser = "christian";
  environment.loginShellInit = ''
    if [ -z "''${WAYLAND_DISPLAY-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec start-umbriel
    fi
  '';

  # programs.umbriel.enable already puts the umbriel package on systemPackages.
  programs.fish.enable = true;
  users.users.christian = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # User-level CLI tools and apps are NOT declared here: they come from the
  # shared home-manager module (../tools.nix via home-manager/home.nix),
  # identical to the non-NixOS machines and the dev image.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value defines the first version of NixOS you installed on this
  # machine; never change it (see `man configuration.nix`).
  system.stateVersion = "26.05";
}
