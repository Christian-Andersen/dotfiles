# ~/.config/fish/config.fish
# This configuration is designed to be portable across different Linux systems.

# ==============================================================================
# Environment Variables & Paths
# ==============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx DE generic
set -gx GOPATH $HOME/.local/share/go

# Projects directory. home-manager sets XDG_PROJECTS_DIR; fall back to ~/c
# for shells that don't get it (envs without home-manager, e.g. the dev image).
# Layout: flat <repo> dirs, one checkout per repo; extra branches, only when
# needed, as sibling <repo>@<branch> worktrees.
set -q XDG_PROJECTS_DIR; or set -gx XDG_PROJECTS_DIR $HOME/c

# Add paths only if they exist to keep PATH clean
set -l extra_paths \
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
    set -l commands_to_check nvim eza fd fzf bat uv uvx zoxide starship lazygit git lazydocker prek just btop xdg-open zellij tldr python3 curl rg openssl hyperfine yazi gcc ninja stow parallel
    for cmd in $commands_to_check
        if not type -q $cmd
            echo "**✗ FAILURE**: Command '$cmd' NOT found in your \$PATH."
        end
    end
end

function bp --description "Copy or append language-specific config boilerplate to current directory"
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
    echo "Applying boilerplate for: $lang..."
    for source_file in $source_dir/{.,}*
        if test -f $source_file
            set -l filename (basename $source_file)
            if not test -e ./$filename
                cp $source_file ./$filename
                echo " -> Created ./$filename"
            else
                cat $source_file >>./$filename
                echo " -> Appended to ./$filename"
            end
        end
    end
    echo "Done!"
end

function projects-root --description 'Resolve the projects directory'
    if set -q XDG_PROJECTS_DIR; and test -n "$XDG_PROJECTS_DIR"
        echo $XDG_PROJECTS_DIR
    else
        echo $HOME/c
    end
end

function projects --description 'List git repos in the projects directory, from any cwd'
    set -l root (projects-root)
    for dir in $root/*/
        test -e "$dir.git"; and echo (path resolve "$dir")
    end
end

function project-session-name -a dir --description 'Unique zellij session name for a project path'
    set -l root (projects-root)
    set -l rel (string replace -- "$root/" '' -- "$dir")
    string replace -ra '[^A-Za-z0-9_.-]' - -- "$rel" | string trim -c -
end

function git-repo-status -a clean --description 'Get git repo status'
    set -l dir "$clean/"
    git -C "$dir" fetch --quiet --all 2>/dev/null
    set -l remotes (git -C "$dir" remote 2>/dev/null)
    if test -z "$remotes"
        printf "%-30s \033[33m%s\033[0m\n" "$clean" "⚠️  NO REMOTE"
        return
    end
    set -l upstream (git -C "$dir" rev-parse --abbrev-ref @{u} 2>/dev/null)
    if test -z "$upstream"
        printf "%-30s \033[33m%s\033[0m\n" "$clean" "⚠️  NO UPSTREAM TRACKING"
        return
    end
    set -l counts (git -C "$dir" rev-list --left-right --count HEAD...@{u} 2>/dev/null)
    if test -n "$counts"
        set -l parts (string split \t -- $counts)
        set -l ahead $parts[1]
        set -l behind $parts[2]

        if test "$ahead" -gt 0 -a "$behind" -gt 0
            printf "%-30s \033[31m%s\033[0m\n" "$clean" "⇕ DIVERGED (+$ahead / -$behind)"
        else if test "$ahead" -gt 0
            printf "%-30s \033[36m%s\033[0m\n" "$clean" "↑ AHEAD (+$ahead unpushed)"
        else if test "$behind" -gt 0
            printf "%-30s \033[35m%s\033[0m\n" "$clean" "↓ BEHIND (-$behind unpulled)"
        end
    end
end

function git-check-sync --description 'Fetch and list project repos that are un-synced or lack a remote (the -j 8 caps concurrent fetches)'
    echo "Fetching remotes and checking status..."
    set -l dirs (projects)
    test -z "$dirs"; and return 0
    printf "%s\n" $dirs | parallel -j 8 'git-repo-status {}'
end

function remove-project --description 'Audited rm -rf replacement for a repo checkout: refuses anything unsaved, interactive git clean, then removes'
    if test (count $argv) -ne 1
        echo "Usage: remove-project <path>" >&2
        return 1
    end
    set -l target (path resolve -- $argv[1] 2>/dev/null)
    if test -z "$target"; or not test -d "$target"
        echo "Error: '$argv[1]' is not a directory." >&2
        return 1
    end
    if not test -e "$target/.git"
        echo "Error: '$target' has no .git here - refusing to remove a non-repo." >&2
        return 1
    end
    set -l root (path normalize (projects-root))
    if test (path dirname "$target") != "$root"
        echo "Error: '$target' is not directly under $root." >&2
        return 1
    end

    # Everything below refuses on any sign of unsaved data. A remote and an
    # upstream branch must exist so "backed up" is provable at all.
    set -l remotes (git -C "$target" remote)
    if test (count $remotes) -eq 0
        echo "Error: no remote - nothing proves this checkout is backed up." >&2
        return 1
    end
    if test -z (git -C "$target" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
        echo "Error: no upstream tracking branch." >&2
        return 1
    end

    # Linked worktrees counting this repo
    set -l wt_count (git -C "$target" worktree list --porcelain | string match --regex '^worktree ' | count)
    if test -d "$target/.git"; and test "$wt_count" -gt 1
        echo "Error: sibling worktrees reference this repo - remove them first." >&2
        return 1
    end

    # Uncommitted changes to tracked files (untracked/ignored are handled by
    # the interactive git clean below, not refused here)
    set -l dirty (git -C "$target" status --porcelain --untracked-files=no | count)
    if test "$dirty" -ne 0
        echo "Error: $dirty tracked file(s) with uncommitted changes." >&2
        return 1
    end

    # Stashes
    if test (count (git -C "$target" stash list)) -ne 0
        echo "Error: stash list is not empty." >&2
        return 1
    end

    # Commits unreachable from any remote ref, across all local branches.
    # Squash-merged branches show up here as false positives - eyeball the
    # sample and handle by hand if that's the case.
    set -l local (git -C "$target" rev-list --branches --not --remotes 2>/dev/null)
    set -l local_count (count $local)
    if test "$local_count" -gt 0
        echo "Error: $local_count local-only commit(s) - not on any remote:" >&2
        git -C "$target" log --branches --not --remotes --oneline | head -5 >&2
        return 1
    end

    # Tags whose targets only exist locally
    set -l tags (git -C "$target" tag)
    if test (count $tags) -gt 0
        set -l rtags
        for r in $remotes
            set -a rtags (git -C "$target" ls-remote --tags "$r" | string replace -r '.*refs/tags/' '' | string match -v -- '*^{*}')
        end
        for t in $tags
            if not contains -- "$t" $rtags
                echo "Error: tag '$t' is not on any remote." >&2
                return 1
            end
        end
    end

    # Submodules (their content may be nowhere else)
    if test (count (git -C "$target" submodule status 2>/dev/null)) -ne 0
        echo "Error: submodules present - their content is not proven safe." >&2
        return 1
    end

    # Nested git repos (vendored checkouts): creation histories not pushed to
    # any remote, and git's clean dry-run silently skips them
    set -l inner_gits (find "$target" -mindepth 2 -name .git | head -5)
    if test (count $inner_gits) -ne 0
        echo "Error: nested git repository(ies) inside:" >&2
        printf '%s\n' $inner_gits >&2
        return 1
    end

    # Audit passed. git clean interactively is the confirmation layer; only if
    # it empties the worktree (ignored files included) does the rm happen.
    cd "$target"; or return 1
    git clean -dxi
    # The gate is two-source conservative: git's clean dry-run lists plain
    # untracked/ignored leftovers, git status catches nested-repo skips too.
    set -l leftover (git clean -xdn)
    set -l status_left (git status --porcelain --ignored)
    if test (count $leftover) -gt 0; or test (count $status_left) -gt 0
        echo "Error: refused to remove - worktree is not empty:" >&2
        printf '%s\n' $leftover $status_left >&2
        return 1
    end

    # Don't be sitting inside the tree when it goes away: a deleted cwd
    # breaks every subsequent command in the running shell.
    builtin cd (path dirname "$target"); or begin
        echo "Error: could not leave the target directory." >&2
        return 1
    end
    echo "Removing $target ..."
    rm -rf -- "$target"
    echo "Removed."
end

function ? --description 'Search Google with a query'
    xdg-open "https://www.google.com/search?q="(string escape --style=url "$argv")
end

function ?? --description 'Search Google AI with a query'
    xdg-open "https://www.google.com/search?udm=50&q="(string escape --style=url "$argv")
end

function notme --description "Find all files (including hidden/ignored) not owned by current user or group"
    fd -H -I --owner "!"(id -un)":!"(id -gn) $argv
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

function tmp --description 'Create and cd into a temp directory'
    set -l tmp_dir (mktemp -d -t 'tmp-XXXXXX')
    if test -n "$tmp_dir"
        echo "Created and changing to: $tmp_dir"
        builtin cd "$tmp_dir"
    else
        echo "Error: Could not create a temporary directory." >&2
        return 1
    end
end

function u --description 'Update by automatically checking for different package managers'
    if command -v paru >/dev/null
        paru -Syu --noconfirm
    else if command -v yay >/dev/null
        yay -Syu --noconfirm
    else if command -v pacman >/dev/null
        sudo pacman -Syu --noconfirm
    else if command -v apt >/dev/null
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y
    end
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
        set -l session_name (project-session-name "$target_dir")
        zellij attach --create "$session_name" options --default-cwd "$target_dir"
        return
    end
    set -l dirs $HOME
    for d in (zoxide query -l 2>/dev/null)
        if not contains -- "$d" $dirs
            set -a dirs "$d"
        end
    end
    for d in (projects)
        if not contains -- "$d" $dirs
            set -a dirs "$d"
        end
    end
    set -l active_sessions (zellij list-sessions --short --no-formatting 2>/dev/null)
    set -l live_dirs
    set -l inactive_dirs
    for dir in $dirs
        set -l session_name (project-session-name "$dir")
        if contains -- "$session_name" $active_sessions
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
    set -l session_name (project-session-name "$target_dir")
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
    abbr -a cr 'clear; just check run'
    abbr -a ci 'clear; just ci'
    abbr -a cir 'clear; just ci run'
    abbr -a d 'CUDA_VISIBLE_DEVICES='
    abbr -a d0 'CUDA_VISIBLE_DEVICES=0'
    abbr -a d1 'CUDA_VISIBLE_DEVICES=1'
    abbr -a d2 'CUDA_VISIBLE_DEVICES=2'
    abbr -a f "fzf --preview 'bat --color=always --style=numbers --paging=never {}'"
    abbr -a g lazygit
    abbr -a i 'uv run --with ipython -- ipython -i'
    abbr -a j 'clear; just'
    abbr -a k 'kill -9 (jobs -p)'
    abbr -a lazypodman "DOCKER_HOST=unix://\$XDG_RUNTIME_DIR/podman/podman.sock lazydocker"
    abbr -a lp "DOCKER_HOST=unix://\$XDG_RUNTIME_DIR/podman/podman.sock lazydocker"
    abbr -a l 'eza --long --header --group --git'
    abbr -a ls eza
    abbr -a la 'eza --all --long --header --group --git'
    abbr -a cl 'clear; cd $XDG_PROJECTS_DIR && eza --long --group --header --git-repos --sort=date $XDG_PROJECTS_DIR'
    abbr -a clg 'clear; cd $XDG_PROJECTS_DIR && eza --long --group --header --git-repos --sort=date $XDG_PROJECTS_DIR && git-check-sync'
    abbr -a lsize 'eza --all --long --header --group --git --total-size --sort=size'
    abbr -a lt 'eza --tree --long --header --group --git --total-size --sort=size'
    abbr -a n 'ss -tulpn'
    abbr -a p 'uv run --'
    abbr -a q exit
    abbr -a r 'clear; just run'
    abbr -a rge 'rg "[\p{Emoji}--\p{Ascii}]"'
    abbr -a s 'git status --verbose'
    abbr -a t 'clear; just test'
    abbr -a x chmod +x
    abbr -a y wl-copy
    abbr -a zl 'zellij list-sessions'

    # Global aliases for help
    abbr -a --position anywhere -- --help '--help | bat -plhelp'

    # --- Shell Tools & Completions ---
    # Sourced directly, assuming these commands are always present.
    zoxide init fish --cmd cd | source
    starship init fish | source
end
