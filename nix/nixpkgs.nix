# Shared nixpkgs settings (allowUnfree + local overlay), used by the NixOS
# system (os/nixos/default.nix), the standalone home-manager env (flake.nix),
# and the dev-container image, so all three build packages from an
# identically-configured nixpkgs.
{
  config.allowUnfree = true;
  overlays = [
    (_: prev: {
      pythonPackagesExtensions =
        (prev.pythonPackagesExtensions or [])
        ++ [
          (_: pyprev: {
            sqlfmt = pyprev.sqlfmt.overridePythonAttrs (_: {
              pname = "shandy-sqlfmt";
            });
          })
        ];
    })

    # btop probes the GPU by dlopen("libnvidia-ml.so.1") at runtime, but
    # NixOS has no /etc/ld.so.cache (nothing on Nix resolves libraries
    # through it), so the bare SONAME lookup only works via LD_LIBRARY_PATH.
    # Give btop's own binary a runpath to the driver OpenGL dir: systems
    # with the NVIDIA driver in hardware.nvidia get GPU stats, systems
    # without it just find no lib there and skip the GPU panel.
    (_: prev: {
      btop = prev.btop.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.patchelf];
        postFixup =
          (old.postFixup or "")
          + ''
            patchelf --add-rpath /run/opengl-driver/lib $out/bin/btop
          '';
      });
    })
  ];
}
