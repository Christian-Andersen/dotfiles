# ~/.config/fish/config.fish
# This configuration is designed to be portable across different Linux systems.

# ==============================================================================
# Environment Variables
# ==============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx UV_MANAGED_PYTHON true

# Add paths only if they exist to keep PATH clean
if test -d ~/.local/bin
    fish_add_path --global --move ~/.local/bin
end
if test -d ~/.cargo/bin
    fish_add_path --global --move ~/.cargo/bin
end

# --- Homebrew (Conditional) ---
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# ==============================================================================
# Functions
# ==============================================================================

function check_commands --description 'Check that all the commands I need are installed'
    set commands_to_check nvim eza fd fzf bat cargo uv uvx zoxide starship lazygit git pre-commit ruff just btop xdg-open xclip zellij tldr docker wget curl aria2c ssh scp fastfetch rg dos2unix npm openssl
    for cmd in $commands_to_check
        if not type -q $cmd
            echo "**✗ FAILURE**: Command '$cmd' NOT found in your \$PATH."
        end
    end
end

function f --description "Fuzzy find files and directories (including hidden, respecting .gitignore) to cd or open"
    set -l search_locations
    if test (count $argv) -gt 0
        set search_locations $argv
    else
        set search_locations .
    end
    set -l base_flags 'fd -a --full-path --one-file-system --exclude .git/ --exclude /proc --exclude /sys --exclude /dev -H .'
    set -l escaped_paths
    for loc in $search_locations
        set escaped_paths $escaped_paths (string escape $loc)
    end
    set -l selected_path (eval $base_flags $escaped_paths | fzf)
    if test -n "$selected_path"
        if test -d "$selected_path"
            echo "Changing directory to $selected_path"
            cd "$selected_path"
        else if test -f "$selected_path"
            if test -w "$selected_path"
                echo "Opening file $selected_path with nvim"
                nvim "$selected_path"
            else
                echo "Opening file $selected_path with sudo nvim (Read-Only/Insufficient Permissions)"
                sudo nvim "$selected_path"
            end
        else
            echo "Opening selection $selected_path with xdg-open"
            nohup xdg-open "$selected_path" >/dev/null 2>&1 &
        end
    end
end

function h --description "Fuzzy search through history and execute"
    set -l cmd (history -z | fzf --read0 --print0 | read -z)
    commandline ''
    if test -n "$cmd"
        commandline --replace "$cmd"
        commandline -f execute
    end
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

function u --description 'Update system packages (pacman, apt, brew, uv)'
    sudo --validate
    if command -v pacman >/dev/null
        echo "--- Updating Pacman ---"
        sudo pacman -Syu --noconfirm
    else if command -v apt >/dev/null
        echo "--- Updating Apt ---"
        sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
    end
    if command -v brew >/dev/null
        echo "--- Updating Homebrew ---"
        brew update && brew upgrade && brew cleanup
    end
    if command -v uv >/dev/null
        echo "--- Updating UV Tools ---"
        uv tool upgrade --all
    end
    if command -v cargo >/dev/null
        echo "--- Updating Global Rust Packages ---"
        cargo install-update --all
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
    abbr -a b 'cd -'
    abbr -a c 'cd ~/c && eza --long --header --group'
    abbr -a d 'CUDA_VISIBLE_DEVICES='
    abbr -a d0 'CUDA_VISIBLE_DEVICES=0'
    abbr -a d1 'CUDA_VISIBLE_DEVICES=1'
    abbr -a d2 'CUDA_VISIBLE_DEVICES=2'
    abbr -a e explorer.exe .
    abbr -a g lazygit
    abbr -a i 'uv run --with ipython -- ipython -i'
    abbr -a j just
    abbr -a k sudo btop
    abbr -a l 'eza --long --header --group --git'
    abbr -a ls eza
    abbr -a la 'eza --all --long --header --group --git'
    abbr -a lsize 'eza --all --long --header --group --git --total-size --sort=size'
    abbr -a ltree 'eza --tree --long --header --group --git --total-size --sort=size'
    abbr -a n nvim
    abbr -a o xdg-open
    abbr -a p 'uv run --'
    abbr -a pc pre-commit
    abbr -a q exit
    abbr -a r 'ruff check --fix . ; ruff format .'
    abbr -a s 'git fetch --all && git status'
    abbr -a x chmod +x
    abbr -a y 'xclip -selection clipboard'
    abbr -a z 'zellij attach --create main'

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
