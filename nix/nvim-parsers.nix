# Prebuild the tree-sitter parsers nvim's config installs, pinned by
# nvim-treesitter's own install_info (see prefetch-nvim-parsers.sh), so the
# first nvim launch inside the dev-container image needs no network.
# install() skips any language whose <lang>.so is already present, so seeding
# parser/*.so (+ parser-info/*.revision, used by update()) is sufficient.
# Queries need no seeding: they resolve from the plugin's own runtime dir.
{pkgs}: let
  data = builtins.fromJSON (builtins.readFile ./nvim-parsers.json);
  abi = toString data.abi;
  buildOne = lang: spec: let
    tarball = "${pkgs.lib.removeSuffix ".git" spec.url}/archive/${spec.rev}.tar.gz";
  in
    pkgs.stdenv.mkDerivation {
      name = "nvim-ts-parser-${lang}";
      src = pkgs.fetchzip {
        url = tarball;
        sha256 = spec.sha256;
      };
      nativeBuildInputs = [pkgs.tree-sitter];
      buildPhase = ''
        runHook preBuild
        # tree-sitter wants a cache lock under $HOME; the sandbox home
        # (/homeless-shelter) is read-only, so point it at our temp dir.
        export HOME="$TMPDIR"
        ${
          if (spec.location or null) != null
          then "cd ${spec.location}"
          else ":"
        }
        ${
          if (spec.generate or false)
          then "TREE_SITTER_JS_RUNTIME=native tree-sitter generate --abi ${abi} src/grammar.json"
          else ":"
        }
        tree-sitter build -o parser.so
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp parser.so $out/${lang}.so
        runHook postInstall
      '';
    };
  built = pkgs.lib.mapAttrs buildOne data.parsers;
  copyLib = lang: drv: "cp ${drv}/${lang}.so $out/parser/${lang}.so";
  writeRev = lang: spec: "printf %s ${pkgs.lib.escapeShellArg spec.rev} > $out/parser-info/${lang}.revision";
in
  pkgs.runCommand "nvim-ts-parsers" {} ''
    mkdir -p $out/parser $out/parser-info
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyLib built)}
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList writeRev data.parsers)}
    chmod -R u+w $out
  ''
