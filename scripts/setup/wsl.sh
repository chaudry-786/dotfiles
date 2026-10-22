# shellcheck shell=bash
# Windows side of a WSL install: VS Code, font and Windows Terminal.
# Everything goes through powershell.exe (WSL interop).

WIN_FONT_REG='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
WIN_FONT_CHECK_FILE="JetBrainsMonoNLNerdFont-Regular"

win_init() {
    if has powershell.exe; then
        POWERSHELL=powershell.exe
    elif [ -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
        POWERSHELL=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    else
        die "powershell.exe is not reachable from WSL. Enable interop ([interop] enabled=true in /etc/wsl.conf), then run 'wsl --shutdown' from Windows."
    fi
    WIN_LOCALAPPDATA=$(win_env LOCALAPPDATA)
    WIN_TEMP=$(win_env TEMP)
    [ -n "$WIN_LOCALAPPDATA" ] && [ -n "$WIN_TEMP" ] || die "Could not read Windows environment through powershell.exe"
}

# Run a PowerShell command on Windows. cd to a Windows drive so powershell
# doesn't complain about a \\wsl$ working directory.
win_ps() {
    (cd /mnt/c 2>/dev/null || cd /; "$POWERSHELL" -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$@") | tr -d '\r'
}

win_env() { win_ps "[Environment]::GetEnvironmentVariable('$1')"; }
to_wsl() { wslpath -u "$1"; }
to_win() { wslpath -w "$1"; }

win_has_winget() {
    [ -n "$(win_ps "Get-Command winget -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name")" ]
}

win_winget_install() {
    win_has_winget || die "winget not found on Windows. Install 'App Installer' from the Microsoft Store and re-run."
    win_ps "winget install -e --id $1 --silent --accept-package-agreements --accept-source-agreements ${2:-}"
}

#------------------------------------------------
# VS Code
#------------------------------------------------
win_code_dir() {
    local d
    for d in "$WIN_LOCALAPPDATA\\Programs\\Microsoft VS Code" "C:\\Program Files\\Microsoft VS Code"; do
        if [ -f "$(to_wsl "$d")/bin/code.cmd" ]; then
            echo "$d"
            return 0
        fi
    done
    return 1
}

# Windows side VS Code CLI (installs extensions on Windows)
win_code() {
    local d
    d=$(win_code_dir) || return 1
    win_ps "& '$d\\bin\\code.cmd' $*"
}

# WSL side VS Code CLI shipped with the Windows install (installs into the
# VS Code server in WSL). It's not on PATH until the next login after install.
wsl_code() {
    local d
    d=$(win_code_dir) || return 1
    "$(to_wsl "$d")/bin/code" "$@"
}

win_missing_vscode() {
    if ! win_code_dir >/dev/null; then
        echo "VS Code (Windows)"
        return 0
    fi
    missing_extensions_from "$(win_code --list-extensions)" | sed 's/^/extension /'
}

win_install_vscode() {
    if ! win_code_dir >/dev/null; then
        win_winget_install Microsoft.VisualStudioCode "--scope user"
        win_code_dir >/dev/null || die "VS Code was not found after installing it with winget"
    fi

    local ext args=()
    for ext in $(missing_extensions_from "$(win_code --list-extensions)"); do
        args+=(--install-extension "$ext")
    done
    if [ ${#args[@]} -gt 0 ]; then
        win_code "${args[@]}" || warn "Some extensions failed to install on Windows"
        # workspace extensions (python, eslint, ...) run inside WSL. Best effort:
        # VS Code also offers to install them when a WSL window is opened.
        wsl_code "${args[@]}" || warn "Could not install extensions in the WSL VS Code server"
    fi
    win_relink_vscode
}

# Windows can't follow links into WSL, so settings are merged and copied
win_relink_vscode() {
    win_code_dir >/dev/null || return 0
    has python3 || pkg_install python3
    python3 "$DOTFILES/scripts/setup/wsl_vscode_sync.py"
}

#------------------------------------------------
# Font
#------------------------------------------------
win_font_installed() {
    [ -f "$(to_wsl 'C:\Windows\Fonts')/$WIN_FONT_CHECK_FILE.ttf" ] && return 0
    [ -n "$(win_ps "(Get-ItemProperty '$WIN_FONT_REG' -ErrorAction SilentlyContinue).'$WIN_FONT_CHECK_FILE (TrueType)'")" ]
}

# Install the .ttf files in $1 for the current Windows user (no admin needed)
win_install_fonts() {
    local tmp
    tmp="$(to_wsl "$WIN_TEMP")/dotfiles-fonts"
    rm -rf "$tmp"
    mkdir -p "$tmp"
    cp "$1"/*.ttf "$DOTFILES/scripts/setup/install_fonts.ps1" "$tmp/"
    win_ps "& '$(to_win "$tmp")\\install_fonts.ps1' -Source '$(to_win "$tmp")'"
    rm -rf "$tmp"
    win_font_installed || die "Font installation on Windows failed"
}

#------------------------------------------------
# Windows Terminal
#------------------------------------------------
win_terminal_installed() {
    local base
    base=$(to_wsl "$WIN_LOCALAPPDATA")
    [ -d "$base/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe" ] ||
        [ -d "$base/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe" ] ||
        [ -d "$base/Microsoft/Windows Terminal" ]
}

win_missing_terminal() {
    win_terminal_installed || echo "Windows Terminal"
}

win_install_terminal() {
    win_terminal_installed || win_winget_install Microsoft.WindowsTerminal
    win_relink_terminal
}

win_relink_terminal() {
    win_terminal_installed || return 0
    has python3 || pkg_install python3
    python3 "$DOTFILES/scripts/setup/wsl_terminal_sync.py"
}

#------------------------------------------------
# Updates
#------------------------------------------------
win_vscode_update() {
    win_code_dir >/dev/null || return 0
    win_has_winget || return 0
    # columns: Name Id Version Available Source
    win_ps "winget list -e --id Microsoft.VisualStudioCode --upgrade-available --accept-source-agreements" \
        | awk '/Microsoft.VisualStudioCode/ {print $(NF-2), $(NF-1)}'
}
