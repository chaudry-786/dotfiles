# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(sudo git web-search history zsh-autosuggestions tmux)

source $ZSH/oh-my-zsh.sh

# Preferred editor
export EDITOR='nvim'

# aliasas
# easy cd
alias up="cd .."
alias des="cd ~/Desktop"
alias dev="cd ~/Desktop/development"
alias dow="cd ~/Downloads"
alias dot="cd ~/dotfiles"
alias notes="cd ~/Desktop/notes"
alias testP="cd ~/Desktop/test/python"
alias testJ="cd ~/Desktop/test/java"
alias testC="cd ~/Desktop/test/c"
alias testJS="cd ~/Desktop/test/JS"

# py
alias src="source venv/bin/activate"
alias csrc="python3 -m venv venv && source venv/bin/activate"
alias dsrc="deactivate && rm -rf venv"

# programs
# Load sessin if file exists || if no arguments passed
alias v='f() {
    if [ -f "Session.vim" ] && [ $# -eq 0 ]; then
        nvim -S Session.vim
    else
        nvim $@
    fi
};f'

# open all git changed files
alias vd='nvim $(git diff --name-only)'
# select diff files to open
alias vds='nvim $(git diff --name-only | fzf -m)'

# others
alias fp="fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}'"
alias cat="batcat --theme=gruvbox-dark"
alias c="clear"
alias e="exit"

# environment variables
ANDROID_HOME=$HOME/Android/Sdk

# npm global packages install fix
export PATH=~/.npm-global/bin:$PATH

# Better colour for directory in ls
LS_COLORS=$LS_COLORS:'di=1;36:' ; export LS_COLORS
# style for fzf-tab ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 70% --layout=reverse --border
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
'
# Setting ripgrep as the default source for fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# fzf-tab style
zstyle ":fzf-tab:*" fzf-flags --height=70% --layout=reverse --border \
--color "fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f" \
--color "info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54"

# p10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Replaces zsh tab completion with fzf
source ~/.fzf-tab/fzf-tab.plugin.zsh
