#!/usr/bin/env bash
# Regenerate nvim-plugins-hashes.json from the vim.pack lockfile.
# Only plugins missing from the hashes file are fetched; pass --refresh to
# re-fetch everything (needed after the lockfile moves a plugin to a new rev).
set -euo pipefail

REFRESH=0
if [[ "${1:-}" == "--refresh" ]]; then
  REFRESH=1
fi

# Run from this script's directory (nix/) regardless of caller cwd.
cd "$(dirname "$0")"

LOCKFILE="../home/dot-config/nvim/nvim-pack-lock.json"
OUTFILE="nvim-plugins-hashes.json"

# Resolve nix-prefetch-git once (not necessarily on PATH) and reuse it.
PREFETCH_BIN="$(nix build nixpkgs#nix-prefetch-git --print-out-paths --no-link)/bin/nix-prefetch-git"

python3 - "$LOCKFILE" "$OUTFILE" "$REFRESH" "$PREFETCH_BIN" <<'EOF'
import json
import subprocess
import sys

lockfile, outfile, refresh, prefetch_bin = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4]

with open(lockfile) as f:
    plugins = json.load(f)["plugins"]

try:
    with open(outfile) as f:
        hashes = json.load(f)
except FileNotFoundError:
    hashes = {}

for name in sorted(plugins):
    if name in hashes and not refresh:
        continue
    src, rev = plugins[name]["src"], plugins[name]["rev"]
    print(f"prefetching {name} @ {rev[:12]}...", flush=True)
    out = subprocess.run(
        [prefetch_bin, "--url", src, "--rev", rev],
        capture_output=True,
        text=True,
        check=True,
    )
    # nix-prefetch-git prints a JSON object (possibly among log lines).
    result = json.loads(out.stdout[out.stdout.index("{"):])
    hashes[name] = result["hash"]
    with open(outfile, "w") as f:
        json.dump(hashes, f, indent=2, sort_keys=True)
        f.write("\n")

print(f"wrote {outfile} ({len(hashes)} plugins)")
EOF
