# Terse command aliases shared by the home-manager env and the dev-container
# image (which doesn't use home-manager): vi -> nvim, 7z -> 7zz.
{pkgs}:
pkgs.runCommand "symlinks" {} ''
  mkdir -p $out/bin
  ln -s ${pkgs.neovim}/bin/nvim $out/bin/vi
  ln -s ${pkgs._7zz}/bin/7zz $out/bin/7z
''
