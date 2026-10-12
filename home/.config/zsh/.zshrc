# History
HISTFILE="$HOME/.local/state/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY


# Completion
autoload -Uz compinit
compinit

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship
eval "$(starship init zsh)"

# eza
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias lt='eza --tree'

# Syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ZSH

if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"

    export FZF_DEFAULT_OPTS="
        --color=fg:$color7
        --color=bg:$background
        --color=hl:$color4
        --color=fg+:$foreground
        --color=bg+:$color0
        --color=hl+:$color6
        --color=info:$color4
        --color=prompt:$color4
        --color=pointer:$color6
        --color=marker:$color6
        --color=spinner:$color4
        --color=header:$color4
    "
fi

export TASKRC="$HOME/.config/task/taskrc"
export GOPATH="$HOME/.local/share/go"
export PATH="$PATH:$GOPATH/bin"
export npm_config_cache="$HOME/.local/share/npm/cache"

export TEXMFVAR="$HOME/.cache/texlive/texmf-var"
export TEXMFCONFIG="$HOME/.config/texlive/texmf-config"
export TEXMFHOME="$HOME/.local/share/texmf"

export PATH="$HOME/.local/bin:$PATH"
"$HOME/dotfiles/scripts/commitgraph.sh"
