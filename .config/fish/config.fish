# ~/.config/fish/config.fish
# This configuration is designed to be portable across different Linux systems.

# ==============================================================================
# Environment Variables
# ==============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx UV_MANAGED_PYTHON true

fish_add_path --global --move ~/.local/bin
fish_add_path --global --move ~/.cargo/bin

# --- Homebrew (Conditional) ---
# This block only runs if Homebrew is found at its standard Linux path.
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end


# ==============================================================================
# Functions
# ==============================================================================

### Change to the coding directory and list it
function c --description 'Change to ~/c and list contents'
    builtin cd ~/c && eza --long --header --group --git
end

### Create a temporary directory and change into it
function t --description 'Create and cd into a temp directory'
    set -l tmp_dir (mktemp -d -t 'tmp.XXXXXX')
    if test -n "$tmp_dir"
        echo "Created and changing to: $tmp_dir"
        cd "$tmp_dir"
    else
        echo "Error: Could not create a temporary directory." >&2
        return 1
    end
end

### Universal update function
function u --description 'Update system packages (pacman, apt, brew)'
    if command -v pacman >/dev/null
        sudo pacman -Syu --noconfirm
    else if command -v apt >/dev/null
        sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
    end
    if command -v brew >/dev/null
        brew update && brew upgrade && brew cleanup
    end
    if command -v uv >/dev/null
        uv tool upgrade --all
    end
end


# ==============================================================================
# Interactive-only Configuration
# ==============================================================================
if status is-interactive
    set fish_greeting

    # --- Abbreviations ---
    abbr -a z 'zellij attach --create main'
    abbr -a j 'just'

    # eza
    abbr -a ls 'eza'
    abbr -a l 'eza --long --header --group --git'
    abbr -a la 'eza --all --long --header --group --git'
    abbr -a lsize 'eza --all --long --header --group --git --total-size --sort=size'
    abbr -a tree 'eza --tree --long --header --group --git --total-size --sort=size'

    # Python
    abbr -a a '. .venv/bin/activate.fish'
    abbr -a py 'uv run --'
    abbr -a ipy 'uv run --with ipython -- ipython -i'
    abbr -a pc 'pre-commit'

    # Git
    abbr -a lg 'lazygit'
    abbr -a gs 'git status'
    abbr -a gc 'git commit'
    abbr -a gf 'git fetch'
    abbr -a gp 'git pull'
    abbr -a gP 'git push'

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'
    abbr -a --position anywhere -- -h '-h | bat -plhelp'

    # --- Shell Tools & Completions ---
    # Sourced directly, assuming these commands are always present.
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
    zoxide init fish --cmd cd | source
    starship init fish | source
end
