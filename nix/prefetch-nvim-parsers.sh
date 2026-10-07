#!/usr/bin/env bash
# Prefetch tree-sitter parser sources pinned by nvim-treesitter's own
# install_info, so the dev-container image can prebuild every parser and the
# first nvim launch needs no network.
# Only parsers missing from the output are fetched; pass --refresh to fetch
# everything (needed after nvim-treesitter moves a pin).
set -euo pipefail

REFRESH=0
if [[ "${1:-}" == "--refresh" ]]; then
  REFRESH=1
fi

# Run from this script's directory (nix/) regardless of caller cwd.
cd "$(dirname "$0")"

INIT="../home/dot-config/nvim/init.lua"
OUTFILE="nvim-parsers.json"

# Build the vendored nvim-treesitter to read install_info at exactly the
# locked revision (cached after the first run).
VENDOR="$(nix build --impure --expr 'let f = builtins.getFlake "path:/home/christian/dotfiles/nix"; pkgs = import f.inputs.nixpkgs { system = "x86_64-linux"; }; in import /home/christian/dotfiles/nix/nvim-plugins.nix { inherit pkgs; dotfilesSrc = /home/christian/dotfiles; }' --print-out-paths --no-link | tail -1)/opt/nvim-treesitter"

python3 - "$INIT" "$OUTFILE" "$REFRESH" "$VENDOR" <<'EOF'
import json
import os
import re
import subprocess
import sys
import tempfile

init_path, outfile, refresh, vendor = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4]

with open(init_path) as f:
    init_src = f.read()

# Language list straight from init.lua's nvim-treesitter install block.
m = re.search(r'require\("nvim-treesitter"\)\.install\(\{(.*?)\}\)', init_src, re.S)
if not m:
    sys.exit("could not find nvim-treesitter install block in init.lua")
langs = re.findall(r'"([a-z0-9_-]+)"', m.group(1))

# Dump install_info (with requires closure) using real Lua inside nvim,
# so we see exactly what nvim-treesitter itself would use.
with tempfile.TemporaryDirectory() as tmp:
    dump_lua = os.path.join(tmp, "dump.lua")
    dump_json = os.path.join(tmp, "info.json")
    with open(dump_lua, "w") as f:
        f.write(
            "local P = require('nvim-treesitter.parsers')\n"
            "local langs = {"
            + ",".join(f"'{l}'" for l in langs)
            + "}\n"
            "local out, seen = {}, {}\n"
            "local function add(l)\n"
            "  if seen[l] then return end\n"
            "  seen[l] = true\n"
            "  local e = P[l]\n"
            "  if not (e and e.install_info) then return end\n"
            "  out[l] = e.install_info\n"
            "  for _, r in ipairs(e.requires or {}) do add(r) end\n"
            "end\n"
            "for _, l in ipairs(langs) do add(l) end\n"
            f"local f = assert(io.open('{dump_json}', 'w'))\n"
            "f:write(vim.json.encode({ abi = vim.treesitter.language_version, langs = out }))\n"
            "f:close()\n"
        )
    subprocess.run(
        ["nvim", "--clean", "--headless", "--noplugin",
         "--cmd", f"set rtp+={vendor}", "-l", dump_lua],
        check=True,
    )
    with open(dump_json) as f:
        info = json.load(f)

try:
    with open(outfile) as f:
        previous = json.load(f)["parsers"]
except FileNotFoundError:
    previous = {}

parsers = {}
for lang in sorted(info["langs"]):
    entry = info["langs"][lang]
    url = entry["url"].removesuffix(".git")
    spec = {
        "url": entry["url"],
        "rev": entry["revision"],
        "tarball": f"{url}/archive/{entry['revision']}.tar.gz",
    }
    if entry.get("location"):
        spec["location"] = entry["location"]
    if entry.get("generate"):
        spec["generate"] = True
    if lang in previous and not refresh and previous[lang].get("sha256"):
        spec["sha256"] = previous[lang]["sha256"]
    else:
        print(f"prefetching {lang} @ {entry['revision'][:12]}...", flush=True)
        out = subprocess.run(
            ["nix-prefetch-url", "--unpack", spec["tarball"]],
            capture_output=True,
            text=True,
            check=True,
        )
        spec["sha256"] = out.stdout.split()[0]
    parsers[lang] = spec

with open(outfile, "w") as f:
    json.dump({"abi": info["abi"], "parsers": parsers}, f, indent=2, sort_keys=True)
    f.write("\n")

print(f"wrote {outfile} ({len(parsers)} parsers, nvim ABI {info['abi']})")
EOF
