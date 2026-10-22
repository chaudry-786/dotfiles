#!/bin/bash
#
# Simulated WSL run of scripts/installation.sh in docker: powershell.exe and
# wslpath are faked (utils/wsl_stub) on a fake C: drive in /mnt/c. Checks the
# Windows side steps: font, VS Code + extensions + settings, Windows Terminal.
# Also runs the sync unit tests (utils/test_wsl_sync.py).
#
# This can't prove real Windows behaviour (winget, font registration), only
# that the installer drives it correctly.
#
# Usage: utils/test_wsl.sh [ubuntu-version]   (default: 24.04)

set -e

UBUNTU_VERSION="${1:-24.04}"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/utils/docker_common.sh"

build_test_image "$UBUNTU_VERSION"

# shellcheck disable=SC2016
$DOCKER run --rm "$IMAGE" bash -c '
set -e
fail() { echo "FAIL: $*"; exit 1; }
sudo mkdir -p /mnt/c && sudo chown tester /mnt/c
export PATH="$HOME/dotfiles/utils/wsl_stub:$PATH" DOTFILES_WSL=1 WIN_LOG=/tmp/win.log
install="dotfiles/scripts/installation.sh --skip zsh,packages,tmux,vim,languages"

echo "########## 1. install (WSL)"
$install --yes

echo "########## 2. checks"
grep -q "winget install -e --id Microsoft.VisualStudioCode" $WIN_LOG || fail "VS Code not installed with winget"
grep -q "winget install -e --id Microsoft.WindowsTerminal" $WIN_LOG || fail "Windows Terminal not installed with winget"
for ext in ms-vscode-remote.remote-wsl asvetliakov.vscode-neovim; do
    grep -qx "$ext" /mnt/c/.fake/win-extensions.txt || fail "extension $ext not installed on Windows"
done
grep -q -- "--install-extension" /mnt/c/.fake/wsl-code.log || fail "extensions not installed on WSL side"
[ "$(ls /mnt/c/Users/tester/AppData/Local/Microsoft/Windows/Fonts/*.ttf | wc -l)" -ge 10 ] || fail "fonts not installed"
python3 - <<EOF || fail "settings not synced"
import json
s = json.load(open("/mnt/c/Users/tester/AppData/Roaming/Code/User/settings.json"))
assert s["vscode-neovim.useWSL"] is True
t = json.load(open("/mnt/c/Users/tester/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"))
assert t["profiles"]["defaults"]["colorScheme"] == "Gruvbox Dark"
assert t["profiles"]["defaults"]["font"]["face"] == "JetBrainsMonoNL Nerd Font"
EOF
[ -d /mnt/c/Users/tester/AppData/Local/Temp/dotfiles-fonts ] && fail "temp font dir not cleaned up"

echo "########## 3. re-run: nothing missing or outdated, nothing reinstalled"
: > $WIN_LOG
$install --check
$install --yes
grep -q "winget install" $WIN_LOG && fail "re-run installed something again"

echo "########## 4. sync unit tests"
python3 dotfiles/utils/test_wsl_sync.py

echo "########## ALL TESTS PASSED"
'
