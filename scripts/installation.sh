#!/bin/bash

# Exit on error
set -e

what_os(){
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
    echo "$machine"
}

install_homebrew(){
    which -s brew
    if [[ $? != 0 ]] ; then
        echo "==================================="
        echo "Installing Homebrew"
        echo "==================================="
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

install_packages(){
    echo "==================================="
    echo "Installing Packages"
    echo "neovim"
    echo "nodejs"
    echo "tmux"
    echo "git"
    echo "ripgrep"
    echo "NPM: treesitter"
    echo "silverSearcher"
    echo "==================================="
    $1 install curl
    $1 install tmux
    $1 install git
    $1 install ripgrep
    if [ "$machine" == "Mac" ]
    then
        $1 install the_silver_searcher
        $1 install reattach-to-user-namespace
        $1 install nodejs
        $1 install neovim
    elif [[ "$machine" == "Linux" ]]; then
        $1 install silversearcher-ag
        $1 install xclip
        # node 19.x https://github.com/nodesource/distributions
        curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        # latest neovim nightly
        curl -L -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb
        sudo apt install -y ./nvim-linux64.deb
        rm nvim-linux64.deb
    fi
}

setup_tmux() {
    echo "==================================="
    echo "Linking tmux config"
    echo "==================================="

    cd ~/
    touch ~/.tmux.conf
    ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

    # plugin to display cpu and gpu usage in status bar
    rm -rf ~/tmux-cpu
    git clone https://github.com/tmux-plugins/tmux-cpu ~/tmux-cpu
}

link_kitty() {
    echo "==================================="
    echo "Linking kitty config"
    echo "==================================="

    mkdir -p ~/.config/kitty
    ln -sf ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
}

setup_vim(){
    echo "==================================="
    echo "Downlading plug manager"
    echo "==================================="
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    echo "==================================="
    echo "Create python3 venv with necessary pacakges"
    echo "==================================="
    #if venv module not installed; on linux run "apt install python3-venv"
    rm -rf ~/vim_venv
    python3 -m venv ~/vim_venv
    source ~/vim_venv/bin/activate
    pip install black neovim

    echo "==================================="
    echo "Creating Symlinks for Vim"
    echo "==================================="
    ln -sfn ~/dotfiles/nvim ~/.config/nvim

    echo "==================================="
    echo "Vim and neovim setup complete"
    echo "Once this process is complete open vim and run :PlugInstall"
    echo "==================================="
}

install_zsh() {
    echo "==================================="
    echo "Installing oh-my-zsh"
    echo "WARNING: if oh-my-zsh is not installed, this script will end here. Simply run this script again"
    sleep 5
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
    echo "WAITING FOR oh-my-zsh to finish installing"
    sleep 15

    echo "==================================="
    echo "Executing rest of zsh related setup "
    echo "==================================="
    # Link .zshrc file
    ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
    # auto suggestion plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # fzf download and setup
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    yes | ~/.fzf/install

    #fzf-tab (replaces zsh default tab completion with fuzzy finder)
    rm -rf ~/.fzf-tab
    git clone https://github.com/Aloxaf/fzf-tab.git ~/.fzf-tab
    #sourced in ~/.zshrc

    # set font for terminal
}

download_and_setup_powerleveltheme(){
    echo "==================================="
    echo "installing and seting up P10k theme"
    echo "==================================="
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    ln -sf ~/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
}

install_font(){
    # insatll jetBrainsMono Nerd Font
    cd ~ && rm -rf nerd-fonts
    git clone --filter=blob:none --sparse https://www.github.com/ryanoasis/nerd-fonts
    cd nerd-fonts
    git sparse-checkout add patched-fonts/JetBrainsMono install.sh
    ./install.sh JetBrainsMono
}

machine=$(what_os)
if [ "$machine" == "Mac" ]
then
    echo "Machine Identifies as Mac"
    install_homebrew
    install_prefix="brew "
elif [[ "$machine" == "Linux" ]]; then
    echo "Machine Identified as Linux"
    install_prefix="sudo apt "
else
    echo "Machine not identified, exiting"
    exit 1
fi


install_packages "$install_prefix"
setup_vim
setup_tmux
link_kitty
download_and_setup_powerleveltheme
install_font $machine
install_zsh

# link gitignore
ln -sf ~/dotfiles/git/.gitignore ~/.gitignore

GREEN='\033[0;32m'
echo -e "${GREEN} SUCCESSFULLY installed all packages and set symbolic links"
