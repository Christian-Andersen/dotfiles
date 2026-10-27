{
  config,
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
  networking.hosts."fd7a:115c:a1e0::5d35:2c6c" = ["forgejo"];

  # Set your time zone.
  time.timeZone = "Australia/Canberra";

  # uv's downloaded CPython builds are dynamically linked against generic
  # glibc and can't run on NixOS; python interpreters come from tools.nix
  # instead. NixOS-only: the standalone home-manager env (work) and the dev
  # image keep uv's auto-download.
  environment.variables.UV_PYTHON_DOWNLOADS = "never";

  # Run dynamically linked executables from pip/uv-installed wheels (e.g.
  # `.venv/bin/ty`): nix-ld shims the standard /lib64 ld-linux path onto
  # nixpkgs glibc; cc.cc.lib adds the gcc runtime (libstdc++.so.6,
  # libgcc_s.so.1) for wheels that assume it from the host.
  programs.nix-ld = {
    enable = true;
    libraries = [pkgs.stdenv.cc.cc.lib];
  };

  # Launch Umbriel on boot without a display manager: autologin on tty1 and
  # exec the compositor from the login shell.
  programs.umbriel.enable = true;
  services.getty.autologinUser = "christian";
  environment.loginShellInit = ''
    if [ -z "''${WAYLAND_DISPLAY-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
      # The autologin path never sets SHELL, so the /bin/sh (bash) start-umbriel
      # wrapper stamps it with its own path and the whole graphical session
      # inherits bash (nvim's :terminal, etc.). Pin it to the login shell first.
      export SHELL=${config.users.users.christian.shell}/bin/fish
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

  # Steam needs system-level udev rules and 32-bit graphics; the module
  # wires those up for us.
  programs.steam.enable = true;

  # Rootless containers. The module provides the `podman` binary and sets up
  # the unprivileged user namespaces; `podman-compose` comes from tools.nix.
  virtualisation.podman.enable = true;

  # NVIDIA RTX 3090: proprietary driver on the open kernel modules
  # (supported for Turing and newer; GA102 is Ampere). This is what
  # provides nvidia-smi and puts the driver libs (libnvidia-ml for NVML,
  # Vulkan, EGL, ...) into /run/opengl-driver, where they are on the
  # system's ld.so cache — so user-level tools like btop dlopen them fine
  # even though btop itself builds from the shared tools.nix without a
  # driver dependency.
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    # Workaround for nixpkgs#576412 / patchelf#674: the nvidia-x11 builder
    # patches its blob binaries with a *combined* patchelf invocation
    # (`--interpreter … --set-rpath …`), and since patchelf 0.19.2 that
    # produces overlapping PT_LOAD segments — .dynamic ends up mapped
    # read-only and ld.so dies writing DT_DEBUG when starting nvidia-smi
    # (SEGV_ACCERR in dl_main). The unpatched originals ship next to the
    # patched binaries (`origBin/`), so re-patch them here with the two
    # operations as separate patchelf calls, which comes out healthy.
    # Drop once builder.sh in the locked nixpkgs splits the invocation.
    package = let
      base = config.boot.kernelPackages.nvidiaPackages.stable;
    in
      base.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.patchelf];
        postFixup =
          (old.postFixup or "")
          + ''
            for i in nvidia-cuda-mps-control nvidia-cuda-mps-server nvidia-smi nvidia-debugdump nvidia-powerd; do
              if [ -e "$bin/origBin/$i" ]; then
                cp "$bin/origBin/$i" "$bin/bin/$i"
                chmod +w "$bin/bin/$i"
                patchelf --set-rpath "$out/lib:$libPath" "$bin/bin/$i"
                patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$bin/bin/$i"
              fi
            done
          '';
      });
  };

  # btop lives at system level (user asked to test this): gets its runtime
  # NVML runpath via the btop overlay in nixpkgs.nix either way.
  environment.systemPackages = [pkgs.btop pkgs.llama-cpp-cuda];

  # User-level CLI tools and apps are NOT declared here: they come from the
  # shared home-manager module (../../tools.nix via ../../home-manager/home.nix),
  # identical to the non-NixOS machines and the dev image.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value defines the first version of NixOS you installed on this
  # machine; never change it (see `man configuration.nix`).
  system.stateVersion = "26.05";
}
