# shellcheck shell=bash
# Install steps. Each step <name> has:
#   missing_<name>   prints what is not installed yet (one per line), nothing if done
#   install_<name>   installs only what is missing, then relinks
#   relink_<name>    (optional) links/copies config files, run on every run

LINUX_APT_PACKAGES=(curl git bat xclip g++ gawk build-essential unzip ripgrep git-delta fontconfig python3-venv)
PYENV_BUILD_DEPS=(build-essential libbz2-dev libffi-dev liblzma-dev libncurses-dev libreadline-dev libsqlite3-dev
    libssl-dev libxml2-dev libxmlsec1-dev llvm make tk-dev wget xz-utils zlib1g-dev)
MAC_BREW_PACKAGES=(curl git bat reattach-to-user-namespace node neovim git-delta ripgrep tmux zsh)
PYTHON_VERSION=3.11.5
NERD_FONT_NAME="JetBrainsMonoNL Nerd Font"

apt_missing() {
    local p
    for p in $(printf '%s\n' "$@" | awk '!seen[$0]++'); do
        dpkg -s "$p" >/dev/null 2>&1 || echo "$p"
    done
}

pkg_install() {
    [ $# -gt 0 ] || return 0
    $APT install "$@"
}

git_clone_missing() {
    local repo_url=$1 destination=$2
    shift 2
    [ -d "$destination/.git" ] && return 0
    safe_git_clone "$repo_url" "$destination" "$@"
}

#------------------------------------------------
# base: tools every other step needs, and GNOME settings (Ubuntu desktop)
#------------------------------------------------
BASE_APT_PACKAGES=(curl git wget ca-certificates)
GNOME_APT_PACKAGES=(gnome-browser-connector gnome-tweaks)

gnome_desktop() {
    ! is_wsl && has gnome-shell && has gsettings
}

missing_base() {
    apt_missing "${BASE_APT_PACKAGES[@]}"
    gnome_desktop && apt_missing "${GNOME_APT_PACKAGES[@]}"
    return 0
}

install_base() {
    # shellcheck disable=SC2046
    pkg_install $(apt_missing "${BASE_APT_PACKAGES[@]}")
    # shellcheck disable=SC2046
    gnome_desktop && pkg_install $(apt_missing "${GNOME_APT_PACKAGES[@]}")
    relink_base
}

relink_base() {
    gnome_desktop || return 0

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

#------------------------------------------------
# zsh
#------------------------------------------------
missing_zsh() {
    has zsh || echo "zsh"
    if has zsh && [ "$machine" == "Linux" ] && [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$(command -v zsh)" ]; then
        echo "zsh as login shell"
    fi
    [ -d ~/.oh-my-zsh ] || echo "oh-my-zsh"
    [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || echo "zsh-autosuggestions"
    [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || echo "zsh-syntax-highlighting"
    [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || echo "powerlevel10k"
    [ -x ~/.fzf/bin/fzf ] || echo "fzf"
    [ -d ~/.fzf-tab ] || echo "fzf-tab"
    has zoxide || [ -x ~/.local/bin/zoxide ] || echo "zoxide"
}

install_zsh() {
    has zsh || pkg_install zsh
    if [ "$machine" == "Linux" ] && [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$(command -v zsh)" ]; then
        sudo chsh -s "$(command -v zsh)" "$(id -un)"
    fi

    # KEEP_ZSHRC: don't let the installer replace ~/.zshrc (it's linked below)
    if [ ! -d ~/.oh-my-zsh ]; then
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # auto suggestion plugin
    git_clone_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    # command line syntax highlighting
    git_clone_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    #download p10k theme
    git_clone_missing "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" --depth 1

    # fzf download and setup (.zshrc already sources ~/.fzf.zsh)
    git_clone_missing "https://github.com/junegunn/fzf.git" "$HOME/.fzf" --depth 1
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

    #fzf-tab (replaces zsh default tab completion with fuzzy finder)
    git_clone_missing "https://github.com/Aloxaf/fzf-tab.git" "$HOME/.fzf-tab"
    #sourced in ~/.zshrc

    #zoxide
    if ! [ -x ~/.local/bin/zoxide ] && ! has zoxide; then
        install_zoxide
    fi

    relink_zsh
}

install_zoxide() {
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    [ "$machine" == "Linux" ] && sudo ln -sf "$HOME/.local/bin/zoxide" /usr/bin/zoxide
    return 0
}

relink_zsh() {
    ln -sf "$DOTFILES/zsh/.zshrc" ~/.zshrc
    ln -sf "$DOTFILES/zsh/.p10k.zsh" ~/.p10k.zsh
    #pytest autocompletion
    ln -sf "$DOTFILES/zsh/completion_pytest.zsh" ~/.completion_pytest.zsh
}

#------------------------------------------------
# packages
#------------------------------------------------
missing_packages() {
    if [ "$machine" == "Mac" ]; then
        local p
        for p in "${MAC_BREW_PACKAGES[@]}"; do
            brew list "$p" >/dev/null 2>&1 || echo "$p"
        done
        return 0
    fi
    apt_missing "${LINUX_APT_PACKAGES[@]}" "${PYENV_BUILD_DEPS[@]}"
    load_tool_env
    [ -s ~/.nvm/nvm.sh ] || echo "nvm"
    has node || echo "node"
    has tree-sitter || echo "tree-sitter-cli"
    has lazygit || echo "lazygit"
    [ -d ~/.pyenv ] || echo "pyenv"
    { has pyenv && pyenv versions --bare | grep -qx "$PYTHON_VERSION"; } || echo "python $PYTHON_VERSION"
    has exa || echo "exa"
}

install_packages() {
    if [ "$machine" == "Mac" ]; then
        # shellcheck disable=SC2046
        pkg_install $(missing_packages)
        return 0
    fi

    # shellcheck disable=SC2046
    pkg_install $(apt_missing "${LINUX_APT_PACKAGES[@]}" "${PYENV_BUILD_DEPS[@]}")

    # ubuntu names the bat binary batcat
    if has batcat && ! has bat; then
        mkdir -p ~/.local/bin
        ln -sf "$(command -v batcat)" ~/.local/bin/bat
    fi

    # node and npm installation
    load_tool_env
    [ -s ~/.nvm/nvm.sh ] || install_nvm
    has node || install_node
    has tree-sitter || npm install -g tree-sitter-cli

    # lazy git
    has lazygit || install_lazygit

    # pyenv
    [ -d ~/.pyenv ] || install_pyenv
    load_tool_env
    pyenv install --skip-existing -v "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"

    has exa || install_exa
}

install_nvm() {
    local tag
    tag=$(gh_latest_tag nvm-sh/nvm)
    # PROFILE=/dev/null: .zshrc already loads nvm, don't let the installer edit it
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${tag:-master}/install.sh" | PROFILE=/dev/null bash
    load_tool_env
}

install_node() {
    load_tool_env
    nvm_run install --lts
    nvm_run alias default 'lts/*'
}

update_node() {
    load_tool_env
    nvm_run install --lts --reinstall-packages-from=current
    nvm_run alias default 'lts/*'
}

install_lazygit() {
    local version tmp
    version=$(gh_latest_tag jesseduffield/lazygit)
    [ -n "$version" ] || die "Could not find latest lazygit release"
    tmp=$(mktemp -d)
    curl -fLo "$tmp/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/${version}/lazygit_${version#v}_Linux_x86_64.tar.gz"
    sudo tar xf "$tmp/lazygit.tar.gz" -C /usr/local/bin lazygit
    rm -rf "$tmp"
}

install_pyenv() {
    curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    load_tool_env
}

install_exa() {
    local tmp
    tmp=$(mktemp -d)
    curl -fL -o "$tmp/exa.zip" https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
    rm -rf "$HOME/exa_extracted"
    mkdir "$HOME/exa_extracted"
    unzip -q "$tmp/exa.zip" -d "$HOME/exa_extracted"
    sudo ln -sf "$HOME/exa_extracted/bin/exa" "/usr/bin/exa"
    rm -rf "$tmp"
}

#------------------------------------------------
# tmux
#------------------------------------------------
# plugins from the @plugin lines in .tmux.conf
tmux_plugins() {
    sed -nE "s|^set -g @plugin '[^/]+/([^']+)'.*|\1|p" "$DOTFILES/tmux/.tmux.conf"
}

missing_tmux() {
    has tmux || echo "tmux"
    local p
    for p in $(tmux_plugins); do
        [ -d ~/.tmux/plugins/"$p" ] || echo "tmux plugin $p"
    done
}

install_tmux() {
    has tmux || pkg_install tmux
    git_clone_missing "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
    relink_tmux
    # tpm needs a running tmux server that has loaded .tmux.conf
    tmux -L dotfiles-install new-session -d -s install 2>/dev/null || true
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" ~/.tmux/plugins/tpm/bin/install_plugins || warn "Could not install tmux plugins (press prefix + I in tmux)"
    tmux -L dotfiles-install kill-server 2>/dev/null || true
}

relink_tmux() {
    ln -sf "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf
}

#------------------------------------------------
# kitty (not on WSL, Windows Terminal is used there)
#------------------------------------------------
missing_kitty() {
    [ -x ~/.local/kitty.app/bin/kitty ] || [ -d /Applications/kitty.app ] || echo "kitty"
}

install_kitty() {
    install_kitty_app
    relink_kitty
}

install_kitty_app() {
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
    state_set kitty-version "$(curl -fsSL https://sw.kovidgoyal.net/kitty/current-version.txt)"
    [ "$machine" == "Linux" ] || return 0
    mkdir -p ~/.local/bin ~/.local/share/applications
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
}

relink_kitty() {
    mkdir -p ~/.config/kitty
    ln -sf "$DOTFILES/kitty/kitty.conf" ~/.config/kitty/kitty.conf
}

#------------------------------------------------
# vim
#------------------------------------------------
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

missing_vim() {
    has nvim || echo "neovim"
    ~/vim_venv/bin/python -c "import pynvim, black" >/dev/null 2>&1 || echo "neovim python venv (~/vim_venv)"
    [ -d "$NVIM_DATA/lazy/lazy.nvim" ] || echo "neovim plugins"
}

install_vim() {
    has nvim || install_nvim
    ~/vim_venv/bin/python -c "import pynvim, black" >/dev/null 2>&1 || install_vim_venv
    relink_vim
    install_nvim_plugins
}

# Install the plugins at the versions in nvim/lazy-lock.json, so the first
# start of neovim is a normal one
install_nvim_plugins() {
    load_tool_env
    nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || true
    [ -d "$NVIM_DATA/lazy/lazy.nvim" ] || warn "Could not install neovim plugins, they will install on the first start of nvim"
}

install_nvim() {
    if [ "$machine" == "Mac" ]; then
        pkg_install neovim
        return 0
    fi
    # nightly release neovim
    local tmp
    tmp=$(mktemp -d)
    curl -fL -o "$tmp/nvim.tar.gz" https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
    rm -rf "$HOME/nvim_extracted"
    mkdir "$HOME/nvim_extracted"
    tar xzf "$tmp/nvim.tar.gz" -C "$HOME/nvim_extracted"
    sudo ln -sf "$HOME/nvim_extracted/nvim-linux-x86_64/bin/nvim" "/usr/bin/nvim"
    rm -rf "$tmp"
}

install_vim_venv() {
    #Neovim Python virtualenv
    load_tool_env
    # without pyenv (packages step skipped) the system python needs python3-venv
    if [ "$machine" == "Linux" ] && ! has pyenv; then
        # shellcheck disable=SC2046
        pkg_install $(apt_missing python3 python3-venv)
    fi
    rm -rf ~/vim_venv
    python3 -m venv ~/vim_venv
    ~/vim_venv/bin/pip install -q black neovim
}

relink_vim() {
    # link the config folder
    mkdir -p ~/.config
    ln -sfn "$DOTFILES/nvim" ~/.config/nvim
}

#------------------------------------------------
# link
#------------------------------------------------
missing_link() { :; }

install_link() { relink_link; }

relink_link() {
    # link gitignore
    ln -sf "$DOTFILES/git/.gitconfig" ~/.gitconfig
    ln -sf "$DOTFILES/git/.gitignore" ~/.gitignore

    # rg uses this in non-git repos
    ln -sf "$DOTFILES/git/.gitignore" ~/.ignore

    # clang-format
    ln -sf "$DOTFILES/langSettings/.clang-format" ~/.clang-format
}

#------------------------------------------------
# languages
#------------------------------------------------
missing_languages() {
    if [ "$machine" == "Linux" ]; then
        # gcc and make
        apt_missing build-essential lua5.3
    else
        has lua || echo "lua"
    fi
}

install_languages() {
    if [ "$machine" == "Linux" ]; then
        # shellcheck disable=SC2046
        pkg_install $(apt_missing build-essential lua5.3)
    else
        pkg_install lua
    fi
}

#------------------------------------------------
# font: JetBrainsMonoNL Nerd Font (on WSL it's installed on Windows)
#------------------------------------------------
missing_font() {
    if is_wsl; then
        win_font_installed || echo "$NERD_FONT_NAME (Windows)"
    elif [ "$machine" == "Mac" ]; then
        brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 || echo "$NERD_FONT_NAME"
    else
        fc-list 2>/dev/null | grep -qi "$NERD_FONT_NAME" || echo "$NERD_FONT_NAME"
    fi
}

install_font() {
    if [ "$machine" == "Mac" ]; then
        brew install --cask font-jetbrains-mono-nerd-font
        return 0
    fi

    local tmp
    tmp=$(mktemp -d)
    fetch_nerd_font "$tmp"
    if is_wsl; then
        win_install_fonts "$tmp/fonts"
        state_set win-nerd-font-version "$NERD_FONT_TAG"
    else
        has fc-cache || pkg_install fontconfig
        mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
        cp "$tmp"/fonts/*.ttf ~/.local/share/fonts/JetBrainsMonoNerd/
        fc-cache -f ~/.local/share/fonts
        state_set nerd-font-version "$NERD_FONT_TAG"
    fi
    rm -rf "$tmp"
}

# Fetch only the NL (no ligatures) JetBrainsMono .ttf files of the latest
# nerd-fonts release into $1/fonts: shallow, blobless clone + sparse checkout
# (~40MB instead of the multi GB repo). Sets NERD_FONT_TAG.
fetch_nerd_font() {
    local dir=$1
    NERD_FONT_TAG=$(gh_latest_tag ryanoasis/nerd-fonts)
    [ -n "$NERD_FONT_TAG" ] || die "Could not find latest nerd-fonts release"
    git -c advice.detachedHead=false clone -q --depth 1 --branch "$NERD_FONT_TAG" \
        --filter=blob:none --no-checkout https://github.com/ryanoasis/nerd-fonts "$dir/repo"
    git -C "$dir/repo" sparse-checkout set --no-cone '/patched-fonts/JetBrainsMono/NoLigatures/**/JetBrainsMonoNLNerdFont-*.ttf'
    git -C "$dir/repo" checkout -q
    mkdir -p "$dir/fonts"
    find "$dir/repo/patched-fonts" -name '*.ttf' -exec cp {} "$dir/fonts/" \;
    [ -n "$(ls -A "$dir/fonts")" ] || die "No font files found in nerd-fonts $NERD_FONT_TAG"
}

#------------------------------------------------
# vscode (on WSL: VS Code on Windows, see wsl.sh)
#------------------------------------------------
vscode_extensions() {
    { grep -v '^[[:space:]]*$' "$DOTFILES/vscode/extensions.txt"; is_wsl && echo "ms-vscode-remote.remote-wsl"; } \
        | tr '[:upper:]' '[:lower:]' | sort -u
}

# prints extensions from $1 (newline separated, installed) missing in vscode_extensions
missing_extensions_from() {
    comm -23 <(vscode_extensions) <(echo "$1" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | sort -u)
}

vscode_user_dir() {
    if [ "$machine" == "Mac" ]; then
        echo "$HOME/Library/Application Support/Code/User"
    else
        echo "$HOME/.config/Code/User"
    fi
}

missing_vscode() {
    if is_wsl; then
        win_missing_vscode
        return 0
    fi
    if ! has code; then
        echo "VS Code"
        return 0
    fi
    missing_extensions_from "$(code --list-extensions 2>/dev/null)" | sed 's/^/extension /'
}

install_vscode() {
    if is_wsl; then
        win_install_vscode
        return 0
    fi
    if ! has code; then
        if [ "$machine" == "Mac" ]; then
            brew install --cask visual-studio-code
        else
            # the .deb also adds Microsoft's apt repo, so apt keeps it updated
            local tmp
            tmp=$(mktemp -d)
            curl -fL -o "$tmp/code.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
            pkg_install "$tmp/code.deb"
            rm -rf "$tmp"
        fi
    fi
    local ext
    for ext in $(missing_extensions_from "$(code --list-extensions 2>/dev/null)"); do
        code --install-extension "$ext" || warn "Could not install extension $ext"
    done
    relink_vscode
}

relink_vscode() {
    if is_wsl; then
        win_relink_vscode
        return 0
    fi
    has code || return 0
    local user_dir
    user_dir=$(vscode_user_dir)
    mkdir -p "$user_dir"
    ln -sf "$DOTFILES/vscode/keybindings.json" "$user_dir/keybindings.json"
    ln -sf "$DOTFILES/vscode/settings.json" "$user_dir/settings.json"
    ln -sfn "$DOTFILES/vscode/snippets" "$user_dir/snippets"
}

#------------------------------------------------
# terminal: Windows Terminal (WSL only, see wsl.sh)
#------------------------------------------------
missing_terminal() { win_missing_terminal; }
install_terminal() { win_install_terminal; }
relink_terminal() { win_relink_terminal; }
