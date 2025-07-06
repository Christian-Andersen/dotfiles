# --- Environment Variables ---
set -x EDITOR nvim
set -x VISUAL nvim
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -x UV_MANAGED_PYTHON true

# --- Functions (useful in both interactive and non-interactive contexts if called by scripts) ---
function a
    set -l current_dir (pwd)
    while true
        set -l venv_path "$current_dir/.venv/bin/activate.fish"
        if test -f "$venv_path"
            source "$venv_path"
            return 0
        end
        set -l parent_dir (dirname "$current_dir")
        if test "$parent_dir" = "$current_dir"
            return 1
        end
        set current_dir "$parent_dir"
    end
end

function py
    uv run -- $argv
end

function ipy
    uv run -- ipython -i $argv
end

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

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'
    abbr -a --position anywhere -- -h '-h | bat -plhelp'

    # --- Shell Completions ---
    # These are typically sourced once for the interactive shell's benefit
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
    zoxide init fish | source
    starship init fish | source
end
