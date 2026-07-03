# ~/.config/fish/config.fish
# This configuration is designed to be portable across different Linux systems.

# ==============================================================================
# Environment Variables & Paths
# ==============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx UV_MANAGED_PYTHON true
set -gx DE generic
set -gx GOPATH $HOME/.local/share/go

# Add paths only if they exist to keep PATH clean
set -l extra_paths \
    ~/.nix-profile/bin \
    ~/.local/bin \
    ~/.cargo/bin \
    $GOPATH/bin

for p in $extra_paths
    test -d $p; and fish_add_path -g $p
end

if test -f "/home/linuxbrew/.linuxbrew/bin/brew"
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
    set -l commands_to_check nvim unzip eza fd fzf bat cargo uv uvx zoxide starship lazygit git deno fnm gh go hf jj lazydocker opencode rsync rustup vulnix zig prek just btop xdg-open xclip zellij tldr docker wget curl aria2c ssh scp fastfetch rg dos2unix npm openssl dust tokei hyperfine yazi 7z jq resvg xsel chafa gcc ninja stow parallel
    for cmd in $commands_to_check
        if not type -q $cmd
            echo "**✗ FAILURE**: Command '$cmd' NOT found in your \$PATH."
        end
    end
end

function bp --description "Append language-specific config boilerplate to current directory"
    if test (count $argv) -eq 0
        echo "Error: Please specify a language (e.g., boilerplate python)"
        return 1
    end
    set -l lang $argv[1]
    set -l source_dir "$HOME/dotfiles/boilerplate/$lang"
    if not test -d $source_dir
        echo "Error: No configuration directory found at $source_dir"
        return 1
    end
    echo "Appending boilerplate for: $lang..."
    for source_file in $source_dir/*
        if test -f $source_file
            set -l filename (basename $source_file)
            cat $source_file >>./$filename
            echo " -> Appended to ./$filename"
        end
    end
    echo "Done!"
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
        set ext txt
    end
    git log --follow --pretty=format:"%h %ad %s" --date=short -- "$argv[1]" | fzf --ansi --reverse --no-sort \
        --header "History of $argv[1] (Enter to print Commit Hash)" \
        --preview "git show {1}:\"$argv[1]\" 2>/dev/null | bat --color=always --style=numbers --language=$ext" \
        --bind "enter:become(echo {1})"
end

function m --description 'Make directory (recursive) and change to it'
    set target $argv[1]
    mkdir -p $target && builtin cd $target
end

function t --description 'Create and cd into a temp directory'
    set -l tmp_dir (mktemp -d -t 'tmp-XXXXXX')
    if test -n "$tmp_dir"
        echo "Created and changing to: $tmp_dir"
        cd "$tmp_dir"
    else
        echo "Error: Could not create a temporary directory." >&2
        return 1
    end
end

function u --description 'Parallel update with grouped output'
    sudo --validate; or return 1
    # 1. Build the list of commands to run (Tag + Command pairs)
    set -l jobs
    # System (choose one)
    if command -v paru >/dev/null
        set -a jobs SYS "paru -Syu --noconfirm"
    else if command -v yay >/dev/null
        set -a jobs SYS "yay -Syu --noconfirm"
    else if command -v pacman >/dev/null
        set -a jobs SYS "sudo pacman -Syu --noconfirm"
    else if command -v apt >/dev/null
        set -a jobs SYS "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y"
    end
    # Dev Tools (only if they exist)
    command -v brew >/dev/null; and set -a jobs BREW "brew update && brew upgrade && brew cleanup"
    command -v uv >/dev/null; and set -a jobs UV "uv tool upgrade --all && uv generate-shell-completion fish > ~/.config/fish/completions/uv.fish"
    command -v cargo-install-update >/dev/null; and set -a jobs RUST "cargo install-update --all"
    # 2. Execute
    set -l job_count (math (count $jobs) / 2)
    if test $job_count -gt 0
        echo (set_color yellow)"Running $job_count updates in parallel..."(set_color normal)
        printf "%s\n" $jobs | parallel -N2 --tagstring (set_color -o cyan)"[{1}]"(set_color normal) --line-buffer fish -c "{2}"
    end
    echo (set_color -o green)"All tools are up to date."(set_color normal)
end

function e --description 'Open in file explorer'
    set target .
    set -q argv[1]; and set target $argv[1]
    if command -q explorer.exe
        if command -q wslpath
            explorer.exe (wslpath -w "$target")
        else
            explorer.exe "$target"
        end
    else
        xdg-open "$target"
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

function z --description "Zellij project session manager"
    clear
    if set -q argv[1]
        set -l target_dir (path resolve -- "$argv[1]" 2>/dev/null)
        if test -z "$target_dir"; or not test -d "$target_dir"
            echo "Error: '$argv[1]' is not a valid directory." >&2
            return 1
        end
        set -l session_name (basename "$target_dir")
        zellij attach --create "$session_name" options --default-cwd "$target_dir"
        return
    end
    set -l dirs $HOME
    for d in (zoxide query -l 2>/dev/null)
        if not contains -- "$d" $dirs
            set -a dirs "$d"
        end
    end
    if test -d $HOME/c
        for d in $HOME/c/*
            if not contains -- "$d" $dirs
                set -a dirs "$d"
            end
        end
    end
    set -l active_sessions (zellij list-sessions --short --no-formatting 2>/dev/null)
    set -l live_dirs
    set -l inactive_dirs
    for dir in $dirs
        set -l dir_name (basename "$dir")
        if contains -- "$dir_name" $active_sessions
            set -a live_dirs (set_color green)"● "(set_color normal)"$dir"
        else
            set -a inactive_dirs "  $dir"
        end
    end
    set -l annotated_dirs $live_dirs $inactive_dirs
    set -l choice (printf "%s\n" $annotated_dirs | fzf --ansi --prompt="Project Session: " --reverse)
    if test -z "$choice"
        return
    end
    set -l target_dir (string replace -ra '\e\[[0-9;]*[a-zA-Z]' '' -- "$choice" | string trim)
    set -l target_dir (string replace -r '^[● ]{2}' '' -- "$target_dir" | string trim)
    set -l session_name (basename "$target_dir")
    zellij attach --create "$session_name" options --default-cwd "$target_dir"
end

# ==============================================================================
# Interactive-only Configuration
# ==============================================================================
if status is-interactive
    set fish_greeting

    # --- Single Letter Abbreviations ---
    abbr -a a '. .venv/bin/activate.fish'
    abbr -a c 'clear; just check'
    abbr -a d 'CUDA_VISIBLE_DEVICES='
    abbr -a d0 'CUDA_VISIBLE_DEVICES=0'
    abbr -a d1 'CUDA_VISIBLE_DEVICES=1'
    abbr -a d2 'CUDA_VISIBLE_DEVICES=2'
    abbr -a f "fzf --preview 'fzf-preview.sh {}'"
    abbr -a g lazygit
    abbr -a i 'uv run --with ipython -- ipython -i'
    abbr -a j 'clear; just'
    abbr -a k 'kill -9 (jobs -p)'
    abbr -a l 'eza --long --header --group --git'
    abbr -a ls eza
    abbr -a la 'eza --all --long --header --group --git'
    abbr -a cl 'cd ~/c && eza --long --header --group --git --git-repos --sort=date'
    abbr -a lsize 'eza --all --long --header --group --git --total-size --sort=size'
    abbr -a ltree 'eza --tree --long --header --group --git --total-size --sort=size'
    abbr -a zl 'zellij list-sessions'
    abbr -a n 'ss -tulpn'
    abbr -a p 'uv run --'
    abbr -a q exit
    abbr -a r 'clear; just run'
    abbr -a s 'git fetch --all --prune && git status'
    abbr -a x chmod +x
    abbr -a y wl-copy

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'

    # --- Shell Tools & Completions ---
    # Sourced directly, assuming these commands are always present.
    zoxide init fish --cmd cd | source
    starship init fish | source
    direnv hook fish | source
end
