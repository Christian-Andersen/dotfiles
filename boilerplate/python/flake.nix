{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      debugpy = pkgs.python3Packages.debugpy;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          debugpy
          just
          prek
          ruff
          ty
          uv
        ];
      };
    };
}
