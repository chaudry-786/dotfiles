# shellcheck shell=bash
# Helpers shared by the installation scripts. Sourced by scripts/installation.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

STATE_DIR="$HOME/.local/state/dotfiles"
# pip's "new release of pip" notice is noise here
export PIP_DISABLE_PIP_VERSION_CHECK=1
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

info() { echo -e "${BOLD}==>${NC} $*"; }
warn() { echo -e "${YELLOW}WARN:${NC} $*" >&2; }
die() { echo -e "${RED}ERROR:${NC} $*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

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

# DOTFILES_WSL=1 forces WSL mode (used by scripts/test_wsl.sh)
is_wsl() {
    [ "${DOTFILES_WSL:-}" = 1 ] && return 0
    grep -qi microsoft /proc/version 2>/dev/null
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

# Make tools installed by this script (nvm, pyenv, ~/.local/bin) usable in the
# rest of the script. We can't `source ~/.zshrc` here: this script runs in bash
# and .zshrc is zsh-only (oh-my-zsh, p10k, ...).
load_tool_env() {
    case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ] && ! has nvm; then
        # nvm.sh is not safe to source under `set -e`
        set +e
        . "$NVM_DIR/nvm.sh"
        set -e
    fi

    export PYENV_ROOT="$HOME/.pyenv"
    if [ -d "$PYENV_ROOT/bin" ] && ! has pyenv; then
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi
}

# nvm functions return non-zero in normal situations, run them without `set -e`
nvm_run() {
    local rc
    set +e
    nvm "$@"
    rc=$?
    set -e
    return $rc
}

# true if version $1 < $2 (leading "v" ignored)
version_lt() {
    local a="${1#v}" b="${2#v}"
    [ "$a" != "$b" ] && [ "$(printf '%s\n%s\n' "$a" "$b" | sort -V | head -1)" = "$a" ]
}

# Latest release tag of a GitHub repo, from the releases/latest redirect
# (no API call, so no rate limit)
gh_latest_tag() {
    curl -fsSI "https://github.com/$1/releases/latest" 2>/dev/null \
        | tr -d '\r' | sed -nE 's|^[Ll]ocation: .*/tag/(.+)$|\1|p' | tail -1
}

state_get() { cat "$STATE_DIR/$1" 2>/dev/null || true; }
state_set() { mkdir -p "$STATE_DIR"; echo "$2" > "$STATE_DIR/$1"; }

# Ask a yes/no question. Returns 0 for yes. --yes answers yes to everything.
ask_yn() {
    [ "$ASSUME_YES" = true ] && return 0
    local reply
    read -r -p "$1 (y/n): " -n 1 reply
    echo
    [[ $reply =~ ^[Yy]$ ]]
}
