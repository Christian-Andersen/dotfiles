export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
export EDITOR="nvim"
export VISUAL="nvim"
PATH=~/.local/bin:$PATH
export UV_MANAGED_PYTHON=true
function py() {
    uv run -- $@
}
a() {
    local current_dir="$(pwd)"
    local venv_path
    while true; do
        venv_path="$current_dir/.venv/bin/activate"
        if [[ -f "$venv_path" ]]; then
            source "$venv_path"
            return 0
        fi
        local parent_dir="$(dirname "$current_dir")"
        if [[ "$parent_dir" == "$current_dir" ]]; then
            return 1
        fi
        current_dir="$parent_dir"
    done
}
alias t="tmux attach || tmux"
