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

function c --description 'Change to ~/c and list contents'
    builtin cd ~/c && eza --long --header --group --git
end

function f --description "Fuzzy find files and directories system-wide to cd or open"
    set -l source_cmd 'fd -a --full-path --one-file-system . /'
    set -l selected_path (eval $source_cmd | fzf)
    if test -n "$selected_path"
        if test -d "$selected_path"
            echo "Changing directory to $selected_path"
            cd "$selected_path"
        else if test -f "$selected_path"
            echo "Opening file $selected_path with xdg-open"
            xdg-open "$selected_path" &
        else
            echo "Selection is neither a directory nor a file: $selected_path"
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

function m --description 'Make directory and change to it'
    set target $argv[1]
	mkdir $target && builtin cd $target
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
    abbr -a p pre-commit
    abbr -a p 'uv run --'
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
