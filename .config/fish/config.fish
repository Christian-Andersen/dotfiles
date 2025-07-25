# --- Environment Variables ---
set -x EDITOR nvim
set -x VISUAL nvim
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -x UV_MANAGED_PYTHON true

function c
    cd ~/c && eza --long --header --group --git
end

# --- Interactive-only configurations ---
if status is-interactive
    set fish_greeting

    # Abbreviations
    abbr -a ls eza
    abbr -a l eza --long --header --group --git
    abbr -a la eza --all --long --header --group --git
    abbr -a lsize eza --all --long --header --group --git --total-size --sort=size
    abbr -a tree eza --tree --long --header --group --git --total-size --sort=size
    abbr -a a source .venv/bin/activate.fish
    abbr -a py uv run --
    abbr -a ipy ipy run -- ipython -i

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'
    abbr -a --position anywhere -- -h '-h | bat -plhelp'

    # --- Shell Completions ---
    # These are typically sourced once for the interactive shell's benefit
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
    zoxide init fish --cmd cd | source
    starship init fish | source
end
