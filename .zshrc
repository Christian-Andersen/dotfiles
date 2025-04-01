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
