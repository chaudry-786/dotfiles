#!/bin/bash
#
# One script to install and update everything (Ubuntu, WSL + Windows, Mac).
# Safe to re-run: installs what's missing, then offers available updates.
#
# Usage: installation.sh [-y|--yes] [--check] [--skip step1,step2,...]
#   -y, --yes   don't ask: install everything missing and apply all updates
#   --check     only report what's missing and what can be updated (exit 1 if anything)
#   --skip      comma separated steps to skip:
#               base,zsh,packages,tmux,kitty,vim,link,languages,font,vscode,terminal
#
# See README.md for what to run on a fresh Ubuntu / Windows (WSL) machine.

# Exit on error
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSUME_YES=false
CHECK_ONLY=false
SKIP_STEPS=","

usage() { sed -n '3,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes) ASSUME_YES=true ;;
        --check) CHECK_ONLY=true ;;
        --skip) SKIP_STEPS=",$2,"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

source "$DOTFILES/scripts/install/common.sh"
source "$DOTFILES/scripts/install/components.sh"
source "$DOTFILES/scripts/install/updates.sh"
source "$DOTFILES/scripts/install/wsl.sh"

STEPS=(base zsh packages tmux kitty vim link languages font vscode terminal)
# no associative arrays: macOS ships bash 3.2
step_desc() {
    case "$1" in
        base) echo "base tools$(gnome_desktop && echo " and GNOME settings")" ;;
        zsh) echo "Zsh, oh-my-zsh and plugins" ;;
        packages) echo "packages (node, python, lazygit, ...)" ;;
        tmux) echo "Tmux" ;;
        kitty) echo "Kitty" ;;
        vim) echo "Neovim" ;;
        link) echo "config links" ;;
        languages) echo "languages (gcc, lua)" ;;
        font) echo "JetBrainsMonoNL Nerd Font" ;;
        vscode) echo "VS Code and extensions" ;;
        terminal) echo "Windows Terminal" ;;
    esac
}
DECLINED_STEPS=","

step_enabled() {
    [[ $SKIP_STEPS == *",$1,"* ]] && return 1
    [[ $DECLINED_STEPS == *",$1,"* ]] && return 1
    [ "$1" == base ] && [ "$machine" != "Linux" ] && return 1
    # Windows Terminal is used on WSL instead of kitty
    if is_wsl; then
        [ "$1" != kitty ]
    else
        [ "$1" != terminal ]
    fi
}

install_homebrew(){
    if ! has brew; then
        echo "==================================="
        echo "Installing Homebrew"
        echo "==================================="
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Check everything the script needs before changing anything, and tell the
# user how to fix what's missing.
preflight() {
    local errors=() warnings=()

    [ "$(id -u)" -ne 0 ] || errors+=("Don't run this as root or with sudo. Run it as your normal user, it uses sudo itself.")

    if [ "$machine" == "Linux" ]; then
        has apt-get || errors+=("Only Ubuntu/Debian (apt) is supported.")
        [ "$(uname -m)" == x86_64 ] || errors+=("Only x86_64 is supported (lazygit, neovim and exa are downloaded as x86_64 builds).")
        has sudo || errors+=("sudo is not installed.")
    fi

    if ! timeout 10 bash -c '</dev/tcp/github.com/443' 2>/dev/null; then
        errors+=("No internet connection (can't reach github.com).")
    fi

    local free_kb
    free_kb=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')
    [ "${free_kb:-0}" -gt $((5 * 1024 * 1024)) ] || warnings+=("Less than 5GB free in $HOME, the installation needs about 3GB.")

    if is_wsl; then
        case "$DOTFILES" in
            /mnt/*) warnings+=("The dotfiles are on the Windows drive ($DOTFILES). Clone them inside WSL (~/dotfiles), it's much faster.") ;;
        esac
        local win_error
        if win_error=$(win_init 2>&1); then
            win_init
            if { step_enabled vscode || step_enabled terminal; } && ! win_has_winget; then
                errors+=("winget is missing on Windows (needed for VS Code and Windows Terminal).
       Install 'App Installer' from the Microsoft Store, or skip with: --skip vscode,terminal")
            fi
        else
            errors+=("${win_error#*ERROR:* }")
        fi
    fi

    local w
    for w in "${warnings[@]}"; do warn "$w"; done
    if [ ${#errors[@]} -gt 0 ]; then
        echo -e "${RED}Can't continue:${NC}"
        for w in "${errors[@]}"; do echo -e "  - $w"; done
        exit 1
    fi

    # ask for the password once now, and keep sudo alive during the long steps
    # (pyenv compiles python) so an unattended run doesn't stop at a prompt
    if [ "$machine" == "Linux" ]; then
        echo "sudo is needed to install packages."
        sudo -v || die "Your user needs sudo rights."
        ( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) >/dev/null 2>&1 &
    fi
}

# Show what is installed and what will be installed, then ask once.
# Sets INSTALL_STEPS. Returns 1 in --check mode if anything is missing.
plan_steps() {
    local step missing missing_any=0
    INSTALL_STEPS=()
    echo
    echo -e "${BOLD}Plan:${NC}"
    for step in "${STEPS[@]}"; do
        if ! step_enabled "$step"; then
            [[ $SKIP_STEPS == *",$step,"* ]] && echo -e "  -  $(step_desc "$step") (skipped)"
            continue
        fi
        missing=$("missing_$step")
        if [ -z "$missing" ]; then
            echo -e "  ${GREEN}✓${NC}  $(step_desc "$step")"
        else
            echo -e "  ${YELLOW}+${NC}  $(step_desc "$step"): $(echo "$missing" | paste -sd, - | sed 's/,/, /g')"
            INSTALL_STEPS+=("$step")
            missing_any=1
        fi
    done
    echo
    if [ ${#INSTALL_STEPS[@]} -eq 0 ]; then
        info "Everything is installed"
    elif is_wsl && [[ " ${INSTALL_STEPS[*]} " == *" vscode "* || " ${INSTALL_STEPS[*]} " == *" terminal "* || " ${INSTALL_STEPS[*]} " == *" font "* ]]; then
        echo "Windows apps (VS Code, Windows Terminal, font) are installed for your Windows user, no admin needed."
        echo "Windows may show a progress window while winget runs."
        echo
    fi
    [ "$CHECK_ONLY" = true ] && return $missing_any
    return 0
}

# Install the planned steps: all, per step, or none
run_steps() {
    local step choice=all
    if [ ${#INSTALL_STEPS[@]} -gt 0 ] && [ "$ASSUME_YES" != true ]; then
        read -r -n 1 -p "Install the steps marked + ? [y]es all / [c]hoose per step / [n]o: " choice
        echo
        case "$choice" in
            [Yy]) choice=all ;;
            [Cc]) choice=ask ;;
            *) choice=none ;;
        esac
    fi
    for step in "${STEPS[@]}"; do
        step_enabled "$step" || continue
        if [[ " ${INSTALL_STEPS[*]} " != *" $step "* ]]; then
            ! declare -F "relink_$step" >/dev/null || "relink_$step"
            continue
        fi
        if [ "$choice" == none ] || { [ "$choice" == ask ] && ! ask_yn "Install $(step_desc "$step")?"; }; then
            DECLINED_STEPS+="$step,"
            continue
        fi
        info "Installing $(step_desc "$step")"
        "install_$step"
    done
}

# Check that every enabled step is complete, and that the tools are available
# from an interactive zsh (the way they are used), which also checks ~/.zshrc.
verify_install() {
    info "Verifying installation"
    local step missing problems=""
    for step in "${STEPS[@]}"; do
        step_enabled "$step" || continue
        missing=$("missing_$step")
        [ -n "$missing" ] && problems+="$(step_desc "$step"): $(echo "$missing" | paste -sd, -)"$'\n'
    done

    local tools=()
    step_enabled zsh && tools+=(fzf zoxide)
    step_enabled packages && [ "$machine" == "Linux" ] && tools+=(node npm tree-sitter pyenv python rg delta lazygit exa)
    step_enabled tmux && tools+=(tmux)
    step_enabled vim && tools+=(nvim)
    if [ ${#tools[@]} -gt 0 ] && has zsh && [ -f ~/.zshrc ]; then
        missing=$(zsh -i -c 'for t in "$@"; do command -v "$t" >/dev/null || echo "$t"; done' zsh "${tools[@]}" 2>/dev/null </dev/null || true)
        [ -n "$missing" ] && problems+="not found in zsh: $(echo "$missing" | paste -sd, -)"$'\n'
    fi

    if [ -n "$problems" ]; then
        echo -e "${RED}Installation incomplete:${NC}"
        echo -n "$problems"
        return 1
    fi
    echo -e "${GREEN}Everything is installed${NC}"
}

# Things only the user can do, shown at the end
next_steps() {
    local steps=()
    if step_enabled zsh && [ "$machine" == "Linux" ] && [ "$(basename "${SHELL:-}")" != zsh ]; then
        if is_wsl; then
            steps+=("Close this terminal and open a new one: zsh is now your shell.")
        else
            steps+=("Log out and back in: zsh is now your shell (open a new terminal until then).")
        fi
    fi
    if is_wsl; then
        step_enabled terminal && steps+=("Restart Windows Terminal to load the font and settings.")
        step_enabled vscode && steps+=("Open projects from WSL with: code <folder>")
    fi
    if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
        steps+=("Set your git identity (not in ~/.gitconfig, that file is linked to the dotfiles repo):
       git config --file ~/.config/git/config user.name \"Your Name\"
       git config --file ~/.config/git/config user.email \"you@example.com\"")
    fi
    [ ${#steps[@]} -gt 0 ] || return 0
    echo
    echo -e "${BOLD}Next steps:${NC}"
    local i
    for i in "${!steps[@]}"; do echo -e "  $((i + 1)). ${steps[$i]}"; done
}

machine=$(what_os)
if [ "$machine" == "Mac" ]; then
    echo "Machine Identifies as Mac"
    APT="brew"
elif [[ "$machine" == "Linux" ]]; then
    echo "Machine Identified as Linux$(is_wsl && echo " (WSL)")"
    APT="sudo DEBIAN_FRONTEND=noninteractive apt-get -y"
else
    echo "Machine not identified, exiting"
    exit 1
fi

echo "Welcome to the installation script!"

preflight
if [ "$machine" == "Mac" ]; then
    [ "$CHECK_ONLY" = true ] || install_homebrew
else
    $APT update -qq
fi

status=0
plan_steps || status=1
[ "$CHECK_ONLY" = true ] || run_steps
collect_updates
apply_updates || status=1
if [ "$CHECK_ONLY" = true ]; then
    [ ${#UPD_NAMES[@]} -eq 0 ] || status=1
    exit $status
fi

verify_install || exit 1
next_steps
[ $status -eq 0 ] || exit 1
echo -e "${GREEN} SUCCESSFULL${NC}"
