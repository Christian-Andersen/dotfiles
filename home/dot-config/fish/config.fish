# ~/.config/fish/config.fish
# This configuration is designed to be portable across different Linux systems.

# ==============================================================================
# Environment Variables & Paths
# ==============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx UV_MANAGED_PYTHON true
set -gx DE generic

# Add paths only if they exist to keep PATH clean
set -l extra_paths \
    ~/.local/bin \
    ~/.cargo/bin \
    ~/.npm-global/bin \
    ~/.bun/bin \
    ~/.deno/bin \
    "$HOME/.local/share/pnpm"

for p in $extra_paths
    if test -d $p
        fish_add_path --global --move $p
        # Set PNPM_HOME specifically if that directory is found
        if string match -q "*pnpm" $p
            set -gx PNPM_HOME $p
        end
    end
end

if test -f /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# ==============================================================================
# Key Bindings
# ==============================================================================
function fish_user_key_bindings
    bind \e\r 'clear; commandline -f execute' # Alt+Enter
end

# ==============================================================================
# Functions
# ==============================================================================

function check_commands --description 'Check that all the commands I need are installed'
    set -l commands_to_check nvim eza fd fzf bat cargo uv uvx zoxide starship lazygit git ruff ty prek just btop xdg-open xclip zellij tldr docker wget curl aria2c ssh scp fastfetch rg dos2unix npm openssl dust tokei hyperfine yazi 7z jq resvg xsel chafa ddgr stylua gcc ninja stow
    for cmd in $commands_to_check
        if not type -q $cmd
            echo "**✗ FAILURE**: Command '$cmd' NOT found in your \$PATH."
        end
    end
end

function ? --description 'Search Google with a query'
    xdg-open "https://www.google.com/search?q="(string escape --style=url "$argv")
end

function ?? --description 'Search Google AI with a query'
    xdg-open "https://www.google.com/search?udm=50&q="(string escape --style=url "$argv")
end

function b
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function h
    if test -z "$argv[1]"
        echo "Usage: h <filename>"
        return 1
    end
    set -l ext (path extension "$argv[1]" | string trim -c '.')
    if test -z "$ext"
        set ext "txt"
    end
    git log --follow --pretty=format:"%h %ad %s" --date=short -- "$argv[1]" | \
    fzf --ansi --reverse --no-sort \
        --header "History of $argv[1] (Enter to print Commit Hash)" \
        --preview "git show {1}:\"$argv[1]\" 2>/dev/null | bat --color=always --style=numbers --language=$ext" \
        --bind "enter:become(echo {1})"
end

function m --description 'Make directory (recursive) and change to it'
    set target $argv[1]
    mkdir -p $target && builtin cd $target
end

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

function u --description 'Update system packages and global dev tools'
    sudo --validate
    if command -v paru >/dev/null
        echo (set_color -o cyan)"--- Updating Paru (Arch) ---"(set_color normal)
        paru -Syu --noconfirm
    else if command -v yay >/dev/null
        echo (set_color -o cyan)"--- Updating Yay (Arch) ---"(set_color normal)
        yay -Syu --noconfirm
    else if command -v pacman >/dev/null
        echo (set_color -o cyan)"--- Updating Pacman ---"(set_color normal)
        sudo pacman -Syu --noconfirm
    else if command -v nala >/dev/null
        echo (set_color -o cyan)"--- Updating Nala ---"(set_color normal)
        sudo nala full-upgrade -y
    else if command -v apt >/dev/null
        echo (set_color -o cyan)"--- Updating Apt ---"(set_color normal)
        sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
    end
    set -l tools \
        "brew:brew update && brew upgrade && brew cleanup" \
        "uv:uv tool upgrade --all && uv generate-shell-completion fish > ~/.config/fish/completions/uv.fish && uvx --generate-shell-completion fish > ~/.config/fish/completions/uvx.fish" \
        "cargo:command -v cargo-install-update >/dev/null && cargo install-update --all" \
        "pnpm:pnpm update -g" \
        "npm:npm update -g --no-fund"
    for tool in $tools
        set -l spec (string split -m 1 ":" $tool)
        if command -v $spec[1] >/dev/null
            echo (set_color -o cyan)"--- Updating $spec[1] Packages ---"(set_color normal)
            eval $spec[2]
        end
    end
end

function o --description 'List a directory or open a file'
    set targets $argv
    if test (count $targets) -eq 0
        set targets "."
    end
    for target in $targets
        if test -d "$target"
            eza --long --header --group --git "$target"
        else if test -f "$target"
            xdg-open "$target"
        else
            echo "\nError: '$target' is neither a file nor a directory, or it does not exist." >&2
        end
    end
end

function v --description 'List a directory or cat a file'
    set targets $argv
    if test (count $targets) -eq 0
        set targets "."
    end
    for target in $targets
        if test -d "$target"
            eza --long --header --group --git "$target"
        else if test -f "$target"
            bat "$target"
        else
            echo "\nError: '$target' is neither a file nor a directory, or it does not exist." >&2
        end
    end
end

# ==============================================================================
# Interactive-only Configuration
# ==============================================================================
if status is-interactive
    set fish_greeting

    # --- Single Letter Abbreviations ---
    abbr -a a '. .venv/bin/activate.fish'
    abbr -a c 'clear && cd ~/c && eza --long --header --group --git --git-repos --sort=date'
    abbr -a d 'CUDA_VISIBLE_DEVICES='
    abbr -a d0 'CUDA_VISIBLE_DEVICES=0'
    abbr -a d1 'CUDA_VISIBLE_DEVICES=1'
    abbr -a d2 'CUDA_VISIBLE_DEVICES=2'
    abbr -a e explorer.exe .
    abbr -a f "fzf --preview 'fzf-preview.sh {}'"
    abbr -a g lazygit
    abbr -a i 'uv run --with ipython -- ipython -i'
    abbr -a j 'clear; just'
    abbr -a k 'kill -9 (jobs -p)'
    abbr -a l 'eza --long --header --group --git'
    abbr -a ls eza
    abbr -a la 'eza --all --long --header --group --git'
    abbr -a lsize 'eza --all --long --header --group --git --total-size --sort=size'
    abbr -a ltree 'eza --tree --long --header --group --git --total-size --sort=size'
    abbr -a n nvim
    abbr -a p 'uv run --'
    abbr -a q exit
    abbr -a r 'ruff check --fix . ; ruff format .'
    abbr -a s 'git fetch --all && git status'
    abbr -a x chmod +x
    abbr -a y 'xclip -selection clipboard'
    abbr -a z 'clear && zellij attach --create main'

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'

    # --- Shell Tools & Completions ---
    # Sourced directly, assuming these commands are always present.
    zoxide init fish --cmd cd | source
    starship init fish | source
end
