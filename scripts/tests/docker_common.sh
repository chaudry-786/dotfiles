# shellcheck shell=bash
# Shared by scripts/test_install.sh and scripts/test_wsl.sh

DOCKER=docker
if ! docker info >/dev/null 2>&1; then
    # e.g. Docker Desktop context selected but not running: use the system daemon
    DOCKER="docker --context default"
    if ! $DOCKER info >/dev/null 2>&1; then
        DOCKER="sudo docker --context default"
    fi
fi

# Build a fresh Ubuntu image (scripts/tests/Dockerfile.install-test) with the dotfiles
# in /home/tester/dotfiles. Sets IMAGE.
build_test_image() {
    IMAGE="dotfiles-install-test:$1"
    # Build context = tracked files only (working tree versions), so the
    # untracked clutter in the repo isn't sent to docker.
    local context
    context=$(mktemp -d)
    (
        cd "$DOTFILES"
        { git ls-files; git ls-files --others --exclude-standard -- scripts ':!scripts/lib'; } \
            | while read -r f; do [ -e "$f" ] && echo "$f"; done \
            | tar -cf - -T - | tar -C "$context" -xf -
    )
    $DOCKER build -q --build-arg UBUNTU="$1" -f "$DOTFILES/scripts/tests/Dockerfile.install-test" -t "$IMAGE" "$context" >/dev/null
    rm -rf "$context"
}
