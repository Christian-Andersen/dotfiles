# --- Environment Variables ---
set -x EDITOR nvim
set -x VISUAL nvim
set -x UV_MANAGED_PYTHON true
fish_add_path --global --move --path ~/.local/bin
# Homebrew
set --global --export HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"

set --global --export HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar"

set --global --export HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew"

fish_add_path --global --move --path "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin"

if test -n "$MANPATH[1]"
    set --global --export MANPATH '' $MANPATH
end

if not contains "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH
    set --global --export INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH
end

# Functions

function c
    builtin cd ~/c && eza --long --header --group --git
end

# --- Interactive-only configurations ---
if status is-interactive
    set fish_greeting

    # Abbreviations
    abbr -a z zellij attach --create main
    abbr -a j just
    abbr -a ls eza
    abbr -a l eza --long --header --group --git
    abbr -a la eza --all --long --header --group --git
    abbr -a lsize eza --all --long --header --group --git --total-size --sort=size
    abbr -a tree eza --tree --long --header --group --git --total-size --sort=size
    abbr -a a . .venv/bin/activate.fish
    abbr -a py uv run --
    abbr -a ipy uv run --with ipython -- ipython -i
    abbr -a pc pre-commit
    abbr -a au 'sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y'
    abbr -a bu 'brew update && brew upgrade && brew cleanup'
    abbr -a lg lazygit
    abbr -a gs git status
    abbr -a gc git commit
    abbr -a gf git fetch
    abbr -a gp git pull
    abbr -a gP git push

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
