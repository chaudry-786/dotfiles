#!/bin/bash
#
# Test scripts/installation.sh on a fresh Ubuntu docker container:
#   0. preflight refuses to run as root
#   1. fresh install with --yes
#   2. re-run with --check: nothing missing, nothing to update
#   3. downgrade lazygit: --check must report it, --yes must update it
#
# Usage: utils/test_install.sh [ubuntu-version]   (default: 24.04)
# Extra installation.sh args can be given via INSTALL_ARGS, e.g.
#   INSTALL_ARGS="--skip vscode,font" utils/test_install.sh 26.04

set -eo pipefail

UBUNTU_VERSION="${1:-24.04}"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/utils/docker_common.sh"

build_test_image "$UBUNTU_VERSION"

# shellcheck disable=SC2016
$DOCKER run --rm -e INSTALL_ARGS="${INSTALL_ARGS:-}" "$IMAGE" bash -c '
set -eo pipefail
install=dotfiles/scripts/installation.sh

echo "########## 0. preflight refuses root"
if sudo $install --check > /tmp/root.log 2>&1 || ! grep -q "run this as root" /tmp/root.log; then
    cat /tmp/root.log; echo "FAIL: preflight did not refuse root"; exit 1
fi

echo "########## 1. fresh install"
$install --yes $INSTALL_ARGS

echo "########## 2. re-run: nothing missing or outdated"
$install --check $INSTALL_ARGS

echo "########## 3. update detection"
curl -fsSL -o /tmp/lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/lazygit_0.40.2_Linux_x86_64.tar.gz
sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
if $install --check $INSTALL_ARGS | tee /tmp/check.log; then
    echo "FAIL: --check did not report the old lazygit"; exit 1
fi
grep -q "^lazygit .*0.40.2" /tmp/check.log || { echo "FAIL: lazygit missing from update list"; exit 1; }
$install --yes $INSTALL_ARGS
$install --check $INSTALL_ARGS

echo "########## ALL TESTS PASSED"
'
