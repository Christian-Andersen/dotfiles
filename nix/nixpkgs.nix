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
  ];
}
