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

link_files () {
    # Link all the config files

    # tmux
    cd ~/
    ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
    # kitty
    mkdir -p ~/.config/kitty
    ln -sf ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
    # nvim
    ln -sfn ~/dotfiles/nvim ~/.config/nvim
    # .zshrc and p10k theme config
    ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
    ln -sf ~/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
    # link gitignore
    ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
    ln -sf ~/dotfiles/git/.gitignore ~/.gitignore
    # rg uses this in non-git repos
    ln -sf ~/dotfiles/git/.gitignore ~/.ignore

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
    $1 install bat
    # kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

    if [ "$machine" == "Mac" ]
    then
        $1 install reattach-to-user-namespace
        $1 install nodejs
        $1 install neovim
        $1 install git-delta
    elif [[ "$machine" == "Linux" ]]; then
        $1 install xclip
        $1 install g++
        # node 19.x https://github.com/nodesource/distributions
        curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        # latest neovim nightly
        curl -L -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb
        sudo apt install -y ./nvim-linux64.deb
        rm nvim-linux64.deb
        # chrome
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt-get install libappindicator1
        sudo dpkg -i google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
        # git-delta | better git diff
        gitDeltaFile="git-delta_x.xx.x_amd64.deb"
        curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
        | grep "browser_download_url.*amd64.deb" | grep -v "musl" \
        | cut -d : -f 2,3 | tr -d \" | wget -qi - -O $gitDeltaFile
        sudo dpkg -i $gitDeltaFile && rm $gitDeltaFile
    fi
}

setup_tmux() {

    # plugin to display cpu and gpu usage in status bar
    rm -rf ~/tmux-cpu
    git clone https://github.com/tmux-plugins/tmux-cpu ~/tmux-cpu
}


setup_vim(){

    #Plugin manager
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    #Neovim Python virtualenv
    rm -rf ~/vim_venv
    python3 -m venv ~/vim_venv
    source ~/vim_venv/bin/activate
    pip install black neovim
}

setup_zsh() {

    # change default zsh for usr
    chsh -s $(which zsh)

    # install oh-my-zhs
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

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

    #download p10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
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

GREEN='\033[0;32m'

read -p "Are you sure to install PACKAGES? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    install_packages "$install_prefix"
    setup_vim
    setup_tmux
    install_font $machine
    setup_zsh
    echo -e "${GREEN} SUCCESSFULLY installed all the packages"
fi

link_files
echo -e "\n ${GREEN} SUCCESSFULLY linked all the config files"
