autoload -U compini && compinit
_comp_options+=(globdots)

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

fpath=($HOME/.zsh/prompts $fpath)
autoload -Uz christian.zsh-theme && christian.zsh-theme

. "$HOME/.local/bin/env"
bindkey "[C" forward-word
bindkey "[D" backward-word
bindkey -e f
