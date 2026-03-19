# ╔══════════════════════════════════════════════════════════════╗
# ║  ZSH CONFIG — Power User Shell (Phantom)                     ║
# ║  Arch Linux · DevOps · AI/ML · Full Stack                     ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Oh My Zsh ───────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # Using Starship instead
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(
    git
    docker
    docker-compose
    kubectl
    ssh-agent
    sudo
    extract
    colored-man-pages
    command-not-found
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf
)

source $ZSH/oh-my-zsh.sh

# ── Environment ─────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"
export PAGER="bat --style=plain"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# ── PATH ────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Python — pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

# Python — mamba/conda
[[ -f "$HOME/mambaforge/etc/profile.d/conda.sh" ]] && source "$HOME/mambaforge/etc/profile.d/conda.sh"
[[ -f "$HOME/mambaforge/etc/profile.d/mamba.sh" ]] && source "$HOME/mambaforge/etc/profile.d/mamba.sh"

# Python — uv
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

# ── Tool Inits ──────────────────────────────────────────────────
# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh --cmd cd)"

# fzf
source <(fzf --zsh) 2>/dev/null

# ── FZF Config ──────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
    --height 50%
    --layout reverse
    --border sharp
    --margin 0
    --padding 1
    --color=bg+:#1a1a1a,fg+:#7EC8A0,hl:#B48EAD,hl+:#B48EAD
    --color=info:#81A1C1,prompt:#7EC8A0,pointer:#7EC8A0
    --color=marker:#7EC8A0,spinner:#B48EAD,header:#81A1C1
    --color=border:#1e1e1e,gutter:#0a0a0a
    --prompt '▸ ' --pointer '>' --marker '+'
"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ── Aliases — Navigation ───────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# ── Aliases — Modern Replacements ──────────────────────────────
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias lt="eza -laT --icons --level=2 --git"
alias la="eza -a --icons --group-directories-first"
alias cat="bat --style=auto"
alias grep="rg"
alias find="fd"
alias top="btop"
alias du="dust"
alias df="duf"
alias ps="procs"
alias dig="dog"
alias curl="curlie"
alias diff="delta"
alias help="tldr"
alias http="httpie"

# ── Aliases — Git ──────────────────────────────────────────────
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias glog="git log --oneline --graph --decorate -20"
alias lg="lazygit"

# ── Aliases — Docker & K8s ─────────────────────────────────────
alias d="docker"
alias dc="docker compose"
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dex="docker exec -it"
alias dlog="docker logs -f"
alias lzd="lazydocker"
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deployments"
alias klog="kubectl logs -f"
alias kex="kubectl exec -it"
alias ctx="kubectl config use-context"
alias ns="kubectl config set-context --current --namespace"
alias k9="k9s"

# ── Aliases — SSH & Servers ────────────────────────────────────
alias sshc="nvim ~/.ssh/config"
alias sshls="grep '^Host' ~/.ssh/config | awk '{print \$2}'"
alias ports="ss -tulnp"
alias myip="curl -s ifconfig.me"
alias ping="ping -c 5"

# ── Aliases — Python ──────────────────────────────────────────
alias py="python3"
alias pip="python3 -m pip"
alias venv="python3 -m venv .venv"
alias activate="source .venv/bin/activate"
alias jup="jupyter lab"
alias ipy="ipython"

# ── Aliases — Database CLIs ────────────────────────────────────
alias pg="pgcli"
alias my="mycli"

# ── Aliases — System ──────────────────────────────────────────
alias ff="fastfetch"
alias nv="nvim"
alias v="nvim"
alias sv="sudo nvim"
alias rr="ranger"
alias cls="clear"
alias h="history | tail -50"
alias path='echo $PATH | tr ":" "\n" | nl'
alias weather="curl -s wttr.in | head -35"
alias cleanup="sudo pacman -Rns \$(pacman -Qdtq) 2>/dev/null; paru -Sc --noconfirm 2>/dev/null"
alias mirrors="sudo reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
alias pacsize="expac -HM '%m\t%n' | sort -n | tail -30"

# ── Aliases — AI Tools ────────────────────────────────────────
alias ai="aichat"
alias ask="tgpt"
alias olm="ollama"

# ── Functions ──────────────────────────────────────────────────

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1"   ;;
            *.tar.gz)  tar xzf "$1"   ;;
            *.tar.xz)  tar xJf "$1"   ;;
            *.bz2)     bunzip2 "$1"   ;;
            *.gz)      gunzip "$1"    ;;
            *.tar)     tar xf "$1"    ;;
            *.zip)     unzip "$1"     ;;
            *.7z)      7z x "$1"      ;;
            *.rar)     unrar x "$1"   ;;
            *)         echo "Cannot extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# SSH to ML server and monitor training
ml-watch() {
    ssh ml-server "watch -n 2 nvidia-smi"
}

ml-logs() {
    ssh ml-server "tail -f ~/training/logs/latest.log"
}

# Quick docker stats
dstats() {
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Find process by name
psg() { procs "$1"; }

# Preview files with bat in fzf
fzfp() { fzf --preview 'bat --color=always --style=numbers {}' --preview-window=right:60%; }

# ── History Config ─────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# ── Completion ─────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'

# ── Startup ────────────────────────────────────────────────────
# Show fastfetch on new terminal (not in tmux/nested)
if [[ -z "$TMUX" ]] && [[ -z "$ZELLIJ" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
    fastfetch
fi
