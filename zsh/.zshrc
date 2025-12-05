# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                            ZSH CONFIGURATION                                  ║
# ║                    Oh-My-Zsh + Powerlevel10k Theme                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           OH-MY-ZSH CONFIGURATION                            │
# └──────────────────────────────────────────────────────────────────────────────┘
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    web-search
    copypath
    copyfile
    copybuffer
    dirhistory
    history
    jsontools
    colored-man-pages
    command-not-found
    docker
    docker-compose
    npm
    python
    pip
    archlinux
)

source $ZSH/oh-my-zsh.sh

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           ENVIRONMENT VARIABLES                              │
# └──────────────────────────────────────────────────────────────────────────────┘
export LANG=it_IT.UTF-8
export LC_ALL=it_IT.UTF-8
export EDITOR='nvim'
export VISUAL='code'
export PAGER='less'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Path
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           HISTORY CONFIGURATION                              │
# └──────────────────────────────────────────────────────────────────────────────┘
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           MODERN CLI REPLACEMENTS                            │
# └──────────────────────────────────────────────────────────────────────────────┘
# eza (ls replacement)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=2 --icons -a'
fi

# bat (cat replacement)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'
fi

# fd (find replacement)
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# ripgrep (grep replacement)
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           USEFUL ALIASES                                     │
# └──────────────────────────────────────────────────────────────────────────────┘
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Safety
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# System
alias update='yay -Syu'
alias cleanup='yay -Sc && yay -Yc'
alias orphans='yay -Qtdq | yay -Rns -'
alias mirrors='sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'
alias lg='lazygit'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'

# Development
alias py='python'
alias pip='pip3'
alias venv='python -m venv venv'
alias activate='source venv/bin/activate'
alias serve='python -m http.server'

# Hyprland
alias hypr='nvim ~/.config/hypr/hyprland.conf'
alias waybar-reload='killall waybar; waybar &'
alias swaync-reload='killall swaync; swaync &'

# Quick edit configs
alias zshrc='nvim ~/.zshrc'
alias reload='source ~/.zshrc'

# System info
alias neofetch='fastfetch'
alias sysinfo='fastfetch'
alias gpu='nvidia-smi'
alias gpuwatch='watch -n 1 nvidia-smi'

# Misc
alias c='clear'
alias h='history'
alias ports='ss -tulanp'
alias myip='curl -s https://ipinfo.io/ip'
alias weather='curl wttr.in'

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           FUNCTIONS                                          │
# └──────────────────────────────────────────────────────────────────────────────┘
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Find process
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Quick notes
note() {
    if [ -z "$1" ]; then
        cat ~/.notes 2>/dev/null || echo "No notes yet"
    else
        echo "$(date '+%Y-%m-%d %H:%M'): $*" >> ~/.notes
    fi
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           FZF CONFIGURATION                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
if command -v fzf &> /dev/null; then
    # Atom One Dark colors for fzf
    export FZF_DEFAULT_OPTS="
        --height 50%
        --layout=reverse
        --border rounded
        --preview-window=right:60%
        --color=bg+:#21252b,bg:#282c34,spinner:#61afef,hl:#e06c75
        --color=fg:#abb2bf,header:#e06c75,info:#e5c07b,pointer:#61afef
        --color=marker:#98c379,fg+:#abb2bf,prompt:#61afef,hl+:#e06c75
        --color=border:#61afef
    "
    
    # Use fd for fzf
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    
    # Load fzf keybindings
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null
    source /usr/share/fzf/completion.zsh 2>/dev/null
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           ZOXIDE (Smart cd)                                  │
# └──────────────────────────────────────────────────────────────────────────────┘
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           KEYBINDINGS                                        │
# └──────────────────────────────────────────────────────────────────────────────┘
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           COMPLETION                                         │
# └──────────────────────────────────────────────────────────────────────────────┘
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           POWERLEVEL10K CONFIG                               │
# └──────────────────────────────────────────────────────────────────────────────┘
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                           FASTFETCH ON STARTUP                               │
# └──────────────────────────────────────────────────────────────────────────────┘
# Show system info on terminal start
if command -v fastfetch &> /dev/null; then
    fastfetch
fi
