# shellcheck shell=bash
# Finds updates for everything the installer manages, shows a summary and
# lets the user pick which ones to apply.

UPD_NAMES=()
UPD_CUR=()
UPD_NEW=()
UPD_CMDS=()

# apt packages worth showing on their own; the rest go in one "other" item
APT_TRACKED=(zsh tmux git curl bat ripgrep git-delta fontconfig xclip gawk unzip lua5.3 code
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

add_update() {
    UPD_NAMES+=("$1")
    UPD_CUR+=("$2")
    UPD_NEW+=("$3")
    UPD_CMDS+=("$4")
}

check_git_repo() {
    local name=$1 path=$2 extra_cmd=${3:-}
    [ -d "$path/.git" ] || return 0
    git -C "$path" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1 || return 0
    if ! git -C "$path" fetch -q 2>/dev/null; then
        warn "Could not fetch $name"
        return 0
    fi
    local behind
    behind=$(git -C "$path" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
    if [ "$behind" -gt 0 ]; then
        add_update "$name" "$(git -C "$path" rev-parse --short HEAD)" "+$behind commits" \
            "git -C '$path' pull -q --ff-only${extra_cmd:+ && $extra_cmd}"
    fi
}

# name, installed version, latest version, update command
check_version() {
    local name=$1 cur=$2 latest=$3 cmd=$4
    if [ -z "$cur" ] || [ -z "$latest" ]; then
        [ -n "$cur" ] && warn "Could not check latest version of $name"
        return 0
    fi
    version_lt "$cur" "$latest" && add_update "$name" "${cur#v}" "${latest#v}" "$cmd"
    return 0
}

check_apt_updates() {
    [ "$machine" == "Linux" ] || return 0
    local name new cur others=()
    while read -r name cur new; do
        if [[ " ${APT_TRACKED[*]} " == *" $name "* ]]; then
            add_update "apt: $name" "$cur" "$new" "$APT install --only-upgrade $name"
        else
            others+=("$name")
        fi
    done < <(apt list --upgradable 2>/dev/null | sed -nE 's|^([^/]+)/[^ ]+ ([^ ]+) [^ ]+ \[upgradable from: ([^]]+)\]$|\1 \3 \2|p')
    if [ ${#others[@]} -gt 0 ]; then
        add_update "apt: other system packages" "${#others[@]} packages" "upgradable" "$APT upgrade"
    fi
}

check_zsh_updates() {
    check_git_repo "oh-my-zsh" ~/.oh-my-zsh
    check_git_repo "zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    check_git_repo "zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    check_git_repo "powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"
    check_git_repo "fzf" ~/.fzf "~/.fzf/install --bin"
    check_git_repo "fzf-tab" ~/.fzf-tab
    if [ -x ~/.local/bin/zoxide ]; then
        check_version zoxide "$(~/.local/bin/zoxide --version | awk '{print $2}')" \
            "$(gh_latest_tag ajeetdsouza/zoxide)" install_zoxide
    fi
}

check_packages_updates() {
    [ "$machine" == "Linux" ] || return 0
    load_tool_env
    if has nvm; then
        check_version nvm "$(nvm_run --version)" "$(gh_latest_tag nvm-sh/nvm)" install_nvm
        has node && check_version "node (LTS)" "$(node -v)" "$(nvm_run version-remote --lts 2>/dev/null)" update_node
    fi
    if has npm; then
        local pkg cur latest
        while read -r pkg cur latest; do
            [ -n "$pkg" ] && add_update "npm: $pkg" "$cur" "$latest" "npm install -g $pkg@latest"
        done < <(npm outdated -g --json 2>/dev/null | node -e '
            let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
                const o = s.trim() ? JSON.parse(s) : {};
                for (const [k, v] of Object.entries(o)) if (v.current !== v.latest) console.log(k, v.current, v.latest);
            });' || true)
    fi
    has lazygit && check_version lazygit "$(lazygit --version | sed -nE 's/.*[ ,]version=([^,]+),.*/\1/p')" \
        "$(gh_latest_tag jesseduffield/lazygit)" install_lazygit
    check_git_repo "pyenv" ~/.pyenv
    check_git_repo "pyenv-virtualenv" ~/.pyenv/plugins/pyenv-virtualenv
}

check_tmux_updates() {
    local p
    for p in ~/.tmux/plugins/*/; do
        check_git_repo "tmux: $(basename "$p")" "$p"
    done
}

check_kitty_updates() {
    [ -x ~/.local/kitty.app/bin/kitty ] || return 0
    local cur
    cur=$(~/.local/kitty.app/bin/kitty --version 2>/dev/null | awk '{print $2}')
    [ -n "$cur" ] || cur=$(state_get kitty-version)
    check_version kitty "$cur" "$(curl -fsSL https://sw.kovidgoyal.net/kitty/current-version.txt 2>/dev/null)" install_kitty_app
}

check_vim_updates() {
    if [ "$machine" == "Linux" ] && has nvim; then
        local cur latest
        cur=$(nvim --version | head -1 | awk '{print $2}')
        latest=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/tags/nightly 2>/dev/null \
            | grep -oE 'NVIM v[0-9][^ \\"]*' | head -1 | awk '{print $2}')
        if [ -n "$latest" ] && [ "$cur" != "$latest" ]; then
            add_update "neovim nightly" "$cur" "$latest" install_nvim
        fi
    fi
    if [ -x ~/vim_venv/bin/python ]; then
        local pkg cur latest
        while read -r pkg cur latest; do
            [ -n "$pkg" ] && add_update "vim venv: $pkg" "$cur" "$latest" "~/vim_venv/bin/pip install -q -U $pkg"
        done < <(~/vim_venv/bin/python -m pip list --outdated --format=json 2>/dev/null | ~/vim_venv/bin/python -c '
import json, sys
for p in json.load(sys.stdin):
    if p["name"].lower() in ("black", "pynvim", "neovim"):
        print(p["name"], p["version"], p["latest_version"])' 2>/dev/null || true)
    fi
}

check_font_updates() {
    local marker=nerd-font-version
    is_wsl && marker=win-nerd-font-version
    local cur
    cur=$(state_get "$marker")
    # installed some other way, nothing to compare against
    [ -n "$cur" ] || return 0
    check_version "$NERD_FONT_NAME" "$cur" "$(gh_latest_tag ryanoasis/nerd-fonts)" install_font
}

check_vscode_updates() {
    # native linux: the .deb's apt repo is covered by check_apt_updates
    is_wsl || return 0
    local cur new
    read -r cur new < <(win_vscode_update || true) || true
    if [ -n "$new" ]; then
        add_update "VS Code (Windows)" "$cur" "$new" \
            "win_ps 'winget upgrade -e --id Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements'"
    fi
}

collect_updates() {
    info "Checking for updates..."
    if step_enabled packages || step_enabled zsh || step_enabled tmux || step_enabled languages || step_enabled docker; then
        check_apt_updates
    fi
    local step
    for step in zsh packages tmux kitty vim font vscode; do
        step_enabled "$step" && "check_${step}_updates"
    done
    return 0
}

print_updates() {
    local i
    printf "\n${BOLD}%-32s %-24s %-24s${NC}\n" "UPDATE" "INSTALLED" "LATEST"
    for i in "${!UPD_NAMES[@]}"; do
        printf "%-32s %-24s %-24s\n" "${UPD_NAMES[$i]}" "${UPD_CUR[$i]}" "${UPD_NEW[$i]}"
    done
    echo
}

# Ask per update: [y]es / [n]o / [a]ll remaining / [s]kip the rest
apply_updates() {
    if [ ${#UPD_NAMES[@]} -eq 0 ]; then
        info "Everything is up to date"
        return 0
    fi
    print_updates
    [ "$CHECK_ONLY" = true ] && return 0

    local i reply all=$ASSUME_YES failed=()
    for i in "${!UPD_NAMES[@]}"; do
        if [ "$all" != true ]; then
            read -r -n 1 -p "Update ${UPD_NAMES[$i]} (${UPD_CUR[$i]} -> ${UPD_NEW[$i]})? [y]es/[n]o/[a]ll/[s]kip rest: " reply
            echo
            case "$reply" in
                [Yy]) ;;
                [Aa]) all=true ;;
                [Ss]) break ;;
                *) continue ;;
            esac
        fi
        info "Updating ${UPD_NAMES[$i]}"
        eval "${UPD_CMDS[$i]}" || failed+=("${UPD_NAMES[$i]}")
    done
    if [ ${#failed[@]} -gt 0 ]; then
        warn "Failed to update: ${failed[*]}"
        return 1
    fi
}
