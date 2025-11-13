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


safe_git_clone() {
    local repo_url=$1
    local destination=$2
    # Replace tilde with the home directory path
    destination=$(eval echo "$destination")
    shift 2

    # Check if the destination directory already exists
    if [ -d "$destination" ]; then
        echo "Removing existing directory: $destination"
        rm -rf "$destination"
    fi

    # Clone the repository with any additional arguments provided
    git clone "$@" "$repo_url" "$destination"
}

setup_ubuntu() {
    if [[ $(grep -i Microsoft /proc/version) ]]; then
        echo "MAchine identified as WSL. No action needed from setup_ubuntu"
        return 0
    fi
    sudo apt-get install chrome-gnome-shell gnome-tweak-tool

    # tip: list all commands:
    # gsettings list-keys org.gnome.desktop.wm.keybindings

    # SETUP KEYMAPPINGS
    #move between workspaces
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control>Right']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control>Left']"

    # maximise and unmaximize window with window+up and dow arros
    # gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    # gsettings set org.gnome.desktop.wm.keybindings  unmaximize "['<Super>Down']"

    #map caps to ctrl
    gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

}

install_and_setup_tmux () {
    $1 install tmux
    cd ~/
    ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
    safe_git_clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
}


install_and_setup_kitty () {
    # install kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

    # link config file
    mkdir -p ~/.config/kitty
    ln -sf ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
}


link_files () {
    # link gitignore
    ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
    ln -sf ~/dotfiles/git/.gitignore ~/.gitignore

    # rg uses this in non-git repos
    ln -sf ~/dotfiles/git/.gitignore ~/.ignore

    # clang-format
    ln -sf ~/dotfiles/langSettings/.clang-format ~/.clang-format
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


install_languages() {
    # gcc and make
    $1 install build-essential
    $1 install lua5.3
}


install_packages() {
    local installer="$1 install"

    # install curl first, because it's dependency on other installations
    $installer curl

    local packages=("git" "ripgrep" "bat")

    if [ "$machine" == "Mac" ]; then
        packages+=("reattach-to-user-namespace" "nodejs" "neovim" "git-delta")
    elif [ "$machine" == "Linux" ]; then
        packages+=("xclip" "g++" "gawk" "build-essential" "unzip")

	for package in "${packages[@]}"; do
	    $installer "$package"
	done

        # node and npm installation
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
        nvm install node --lts
        source ~/.zshrc
        npm install -g tree-sitter-cli

        # git-delta | better git diff
        gitDeltaFile="git-delta_x.xx.x_amd64.deb"
        curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" \
        | grep "browser_download_url.*amd64.deb" | grep -v "musl" \
        | cut -d : -f 2,3 | tr -d \" | wget -qi - -O "$gitDeltaFile"
        sudo dpkg -i "$gitDeltaFile" && rm "$gitDeltaFile"

        # lazy git
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit

        # pyenv
	    sudo apt install build-essential curl libbz2-dev libffi-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev llvm make tk-dev wget xz-utils zlib1g-dev
        curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
        source ~/.zshrc
        pyenv install -v 3.11.5
        pyenv global 3.11.5
        sudo apt install python3-venv

        # Exa
        curl -L -O https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
        rm -rf "$HOME/exa_extracted"
        mkdir "$HOME/exa_extracted"
        unzip exa-linux-x86_64-v0.10.1.zip -d "$HOME/exa_extracted"
        sudo ln -sf "$HOME/exa_extracted/bin/exa" "/usr/bin/exa"
        rm exa-linux-x86_64-v0.10.1.zip
    fi

}


install_and_setup_vim(){

    # stable release neovim
    curl -L -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
    rm -rf "$HOME/nvim_extracted"
    mkdir "$HOME/nvim_extracted"
    tar xzvf nvim-linux-x86_64.tar.gz -C "$HOME/nvim_extracted"
    sudo ln -sf "$HOME/nvim_extracted/nvim-linux-x86_64/bin/nvim" "/usr/bin/nvim"
    rm nvim-linux-x86_64.tar.gz

    # link the config folder
    ln -sfn ~/dotfiles/nvim ~/.config/nvim

    #Neovim Python virtualenv
    rm -rf ~/vim_venv
    python3 -m venv ~/vim_venv
    source ~/vim_venv/bin/activate
    pip install black neovim
}


install_and_setup_zsh() {

    # install zsh and oh-my-zsh
    $1 install zsh
    chsh -s $(which zsh)
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc

    # auto suggestion plugin
    safe_git_clone "https://github.com/zsh-users/zsh-autosuggestions" ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # command line syntax highlighting
    safe_git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # fzf download and setup
    safe_git_clone "https://github.com/junegunn/fzf.git" "$HOME/.fzf" --depth 1
    yes | ~/.fzf/install

    #fzf-tab (replaces zsh default tab completion with fuzzy finder)
    safe_git_clone "https://github.com/Aloxaf/fzf-tab.git" "$HOME/.fzf-tab"
    #sourced in ~/.zshrc

    #download p10k theme
    safe_git_clone "https://github.com/romkatv/powerlevel10k.git" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" --depth 1
    ln -sf ~/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh

    #pytest autocompletion
    ln -sf ~/dotfiles/zsh/completion_pytest.zsh ~/.completion_pytest.zsh

    #zoxide
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    sudo ln -sf "$HOME/.local/bin/zoxide" /usr/bin/zoxide
}


install_font(){
    # insatll jetBrainsMono Nerd Font
    if [[ $(grep -i Microsoft /proc/version) ]]; then
        echo "For WSL/Windows please download fonts from and install manually. (Drap and Drop) "
        echo "https://www.nerdfonts.com/font-downloads"
    else
        cd ~
        safe_git_clone "https://www.github.com/ryanoasis/nerd-fonts"  "$HOME/nerd-fonts" --filter=blob:none --sparse
        cd nerd-fonts
        git sparse-checkout add --skip-checks patched-fonts/JetBrainsMono install.sh
        ./install.sh JetBrainsMono
    fi
}

setup_vscode () {
    if [[ $(grep -i Microsoft /proc/version) ]]; then
        python3 ~/dotfiles/scripts/wsl_vscode_sync.py
    else
        ln -sf ~/dotfiles/vscode/keybindings.json ~/.config/Code/User/keybindings.json
        ln -sf ~/dotfiles/vscode/settings.json ~/.config/Code/User/settings.json
        ln -sfn ~/dotfiles/vscode/snippets ~/.config/Code/User/snippets
    fi


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
    setup_ubuntu
else
    echo "Machine not identified, exiting"
    exit 1
fi


function ask_for_confirmation() {
    local action="$1"
    shift
    local func_to_execute="$1"
    shift
    read -p "Would you like to $action? (y/n): " -n 1 -r
    echo # Move to a new line after user input
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $func_to_execute "$@"  # Execute the function passed as an argument along with its arguments
        return 0  # Return success (0) if the user confirms
    fi
}


GREEN='\033[0;32m'

echo "Welcome to the installation script!"

ask_for_confirmation "install and setup Zsh" install_and_setup_zsh "$install_prefix"
ask_for_confirmation "install packages" install_packages "$install_prefix"
ask_for_confirmation "install and setup Tmux" install_and_setup_tmux "$install_prefix"
ask_for_confirmation "install and setup Kitty" install_and_setup_kitty
ask_for_confirmation "install and setup Vim" install_and_setup_vim
ask_for_confirmation "link files" link_files
ask_for_confirmation "install languages" install_languages "$install_prefix"
ask_for_confirmation "install font" install_font "$machine"
ask_for_confirmation "Setup vscode" setup_vscode "$machine"

echo -e "${GREEN} SUCCESSFULL"
