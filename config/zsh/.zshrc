setopt histignorealldups sharehistory

# Plugin Manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
# Prompt styles
#zinit light nullxception/roundy  
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

export EDITOR="nvim"
export VISUAL="nvim"
bindkey -e
# bindkey '^F' forward-word

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
# Only rebuild the dump (~1s) when it's over a day old; otherwise trust it (-C)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# FZF
# Set up fzf key bindings and fuzzy completion
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"

# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"

# fzf preview for tmux
export FZF_TMUX_OPTS=" -p90%,70% " 

# functions

tf() {
  if [ -z "$1" ]; then
    echo "Usage: tf /path/to/project [session-name]"
    return 1
  fi
  local session_name="${2:-programming}"
  PROJECT_DIR="$1" tmuxifier load-session "$session_name"
}

# Aliases
alias ls="eza --no-filesize --long --color=always --icons=always --no-user"
alias ll="ls -la"
mkcdir() {
  mkdir -p "$1" && cd "$1"
}
# git aliases
alias git="git"
alias ga="git add ."
alias gs="git status -s"
# alias gc="git commit -m"
gc() {
  git commit -m "$1"
}
alias glog='git log --oneline --graph --all'
# yazi
alias y="yazi"
# nvim
alias vim="nvim"
alias nv="nvim"
alias vo="fd --type f --hidden --exclude .git | fzf-tmux -p --reverse| xargs nvim"
# tmux
alias t="tmux"
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias td="tmux detach"
alias tk="tmux kill-session -t"

# tmuxifier
alias tls="tmuxifier load-session"
alias tlw="tmuxifier load-window"
alias tns="tmuxifier new-session"
alias tnw="tmuxifier new-window"

# ani-cli
alias anime="ani-cli"

# scripts
alias t="$HOME/.config/scripts/fzf-tmux.sh"
alias sw="$HOME/.config/scripts/set-wall.sh"
alias w="$HOME/.config/scripts/wallpaper-chooser.sh"

maintenance() {
    sudo "$HOME/.config/scripts/maintenance.sh" "$@" # doing this because cant use sudo with an alias
}

# clear
alias cls="clear"
# exit
alias e="exit"

# running code
alias cs="g++ -std=c++17 -Wall -Wextra solution.cpp -o solution && ./solution < in.txt"
alias com="g++ -std=c++17 -Wall -Wextra solution.cpp -o solution" # for compiling only

# advent-of-code

AOC="~/Documents/advent-of-code/"
# get this from the cookies tab in network tools on the AOC website
if [[ -f ~/.aoc-cookie ]]; then
    export AOC_COOKIE=$(cat ~/.aoc-cookie)
fi

alias aos="cd $AOC && g++ -std=c++17 -Wall -Wextra solution.cpp -o solution && ./solution < in.txt"
alias aot="cd $AOC && g++ -std=c++17 -Wall -Wextra solution.cpp -o solution && echo -ne '\\e[0;34m' && ./solution < test.txt; echo -ne '\\e[0m'"
alias aoc="paot; echo; paos"
alias aocp="cd $AOC && g++ -std=c++17 -Wall -Wextra solution.cpp -o solution" # for compiling only

alias paos="cd $AOC; python3 solution.py < in.txt"
alias paot="cd $AOC; echo -ne '\\e[0;34m'; python3 solution.py < test.txt; echo -ne '\\e[0m'"
alias paoc="aot; echo; aos"

function aoc-load () {
    if [ $1 ]
    then
        curl --cookie "session=$AOC_COOKIE" https://adventofcode.com/$1/day/$2/input > in.txt
    else
        curl --cookie "session=$AOC_COOKIE" "$(echo `date +https://adventofcode.com/%Y/day/%d/input` | sed 's/\/0/\//g')" > in.txt
    fi
}


# Shell Integrations
# export ANI_CLI_PLAYER="flatpak run org.kde.haruna"
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
eval "$(tmuxifier init -)"
export PATH=$PATH:/home/purpleafk/.local/bin
export PATH=$PATH:/home/purpleafk/.cargo/bin
export PATH=$PATH:./waywall/build/waywall
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/pywal-theme.omp.json)"
source $HOME/.config/scripts/fzf-git.sh
# zsh-syntax-highlighting is loaded by zinit above
eval "$(zoxide init zsh)"
source <(fzf --zsh)


# CODEFORCES_CP_SETUP
export SCRIPT_DIR="/home/purpleafk/codeforces/scripts"
[ -f "$SCRIPT_DIR/cp_aliases.sh" ] && source "$SCRIPT_DIR/cp_aliases.sh"


# Competitive Programming Environment for contests
# ~/cf and ~/cf-contests live outside nix-home; restore them from a backup
# [ -f "$HOME/cf-contests/scripts/shell.sh" ] && source "$HOME/cf-contests/scripts/shell.sh"
alias cf_gen="$HOME/codeforces/contests/scripts/cf_gen"
alias cf_sample_gen="$HOME/codeforces/contests/scripts/cf_sample_gen"
alias runsamples="$HOME/codeforces/contests/scripts/runsamples"
export CONTEST_SCRIPTS_DIR="/home/purpleafk/competitive-programming/scripts"
source "$CONTEST_SCRIPTS_DIR/"

# fnm (installed by nix)
eval "$(fnm env --shell zsh)"

# convergence
export CONVERGENCE_BIN="/home/purpleafk/bin"
alias vd='~/bin/vdaily'
alias vn='~/bin/vnote'
alias vp='~/bin/vpaper'
alias vcite='~/bin/vcite'
alias vcp='~/bin/vcp'
alias vg='~/bin/vgrep'
alias vc='~/bin/vcommit'
alias vend='~/bin/vendday'
alias converge='cd ~/convergence && nvim'

# opencode and spicetify are installed by nix

