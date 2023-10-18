#------------------------------------------------
# Define variables and settings
#------------------------------------------------
ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
EDITOR="nvim"
ANDROID_HOME="$HOME/Android/Sdk"
PATH="$HOME/.npm-global/bin:$PATH"
# share history between sessions
setopt share_history

#------------------------------------------------
# Define plugins
#------------------------------------------------
plugins=(
    sudo
    git
    web-search
    history
    zsh-autosuggestions
    tmux
    ripgrep
    copyfile
)

#------------------------------------------------
# Load Oh My Zsh
#------------------------------------------------
source $ZSH/oh-my-zsh.sh

#------------------------------------------------
# Powerlevel10k theme
#------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#------------------------------------------------
# Aliases for Navigation
#------------------------------------------------
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

#------------------------------------------------
# Git-related Aliases
#------------------------------------------------
# open modified files with nvim
alias vd='nvim $(git diff --name-only | sed "s|^|$(git rev-parse --show-toplevel)/|")'
# choose what modified files to open with nvim
alias vds='nvim $(git diff --name-only | fzf -m)'
# open modified files between current branch and master
alias vdp='nvim $(git diff --name-only master...HEAD | sed "s|^|$(git rev-parse --show-toplevel)/|")'

#------------------------------------------------
# Python virtual Environment and Development
#------------------------------------------------
alias csrc="python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip pylint"
alias dsrc="rm -rf venv && deactivate"
# if in git repo then activate from root directory, or from current dir.
src() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        source "$(git rev-parse --show-toplevel)/venv/bin/activate"
    else
        source venv/bin/activate
    fi
}

#------------------------------------------------
# Find Aliases
#------------------------------------------------
alias findn='find -name'
alias findf='find . -type f -name'
alias findd='find . -type d -name'
alias findsize='find -size +1M'
# find files based on modification time, respect .gitignore
findmtime() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git ls-files --exclude-standard --directory | xargs -I {} find {} -type f -mtime "$@"
    else
        find . -type f -mtime "$@" | grep -v -f ~/.gitignore
    fi
}

#------------------------------------------------
# Utility Aliases
#------------------------------------------------
alias fp="fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}'"
alias cat="batcat --theme=gruvbox-dark"
alias c="clear"
alias e="exit"
# launch nvim using Session file if it exists
v() {
    src
    if [ -f "Session.vim" ] && [ $# -eq 0 ]; then
        nvim -S Session.vim
    else
        nvim "$@"
    fi
}
copydir() {
    echo -n "$PWD" | xclip -selection clipboard
}

#------------------------------------------------
# Python related autocompletion
#------------------------------------------------
[ -f ~/.completion_pytest.zsh ] && source ~/.completion_pytest.zsh

#------------------------------------------------
# Zoxide
#------------------------------------------------
eval "$(zoxide init zsh)"

#------------------------------------------------
# FZF
#------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 70% --layout=reverse --border
    --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
    --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
"
# use ripgrep as the default command
export FZF_DEFAULT_COMMAND="rg --files --hidden"
# to apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#------------------------------------------------
# FZF-TAB | replaces zsh default tab completion with FZF
#------------------------------------------------
zstyle ":fzf-tab:*" fzf-flags --height=70% --layout=reverse --border \
    --color "fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f" \
    --color "info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54"
source ~/.fzf-tab/fzf-tab.plugin.zsh

#------------------------------------------------
# Interactive grep with FZF
#------------------------------------------------
search() {
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    INITIAL_QUERY="${*:-}"
    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --preview "batcat --color=always {1} --highlight-line {2}" \
    --preview-window "up,60%,border-bottom,+{2}+3/3,~3" \
    --bind "enter:become(nvim {1} +{2})"
}
# Define widget and bind CTRL-G to it
zle -N search search
bindkey "^g" search

#------------------------------------------------
# Node version manager (NVM)
#------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ------------------------------------------------
# Load machine-specific configuration
# ------------------------------------------------
non_encrypted_machine_config="$HOME/.machine_config"
if [ -f "$non_encrypted_machine_config" ]; then
    source "$non_encrypted_machine_config"
fi

encrypted_machine_config="$HOME/.machine_config_encrypted"
if [ -f "$encrypted_machine_config" ]; then
    # Decrypt the encrypted configuration file
    decrypted_data=$(gpg --quiet --decrypt "$encrypted_machine_config")
    eval "$decrypted_data"
fi

# ------------------------------------------------
# Edit terminal command in NeoVim
# ------------------------------------------------
bindkey "^v" edit-command-line
