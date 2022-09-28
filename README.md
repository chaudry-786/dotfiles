## Major components

### Text editor: Neovim
##### Major plugins
    Coc.nvim (Conquer of Completion) (requires node)
    Tree-sitter (for better syntax highlighting, folding and other modules)
    various other plugins

### Shell: Zsh
    oh-my-zsh (framework to manage zsh configuration)
    p10k theme used for terminal. Use a NerdFont font for better glyphs/icons. JetBrains Mono NerdFont will be installed.
    fzf (fuzzy finder)
    fzf-tab (replaces zsh tab with fuzzy finder)
    various other plugins

### Terminal multiplexer: tmux
    Custom config, no plugins used.

### Terminal emulator
    On Ubuntu I use kitty (config included) and on MacOS Iterm2.
        Kitty doesn't render as crispy on external monitor on MacOS

## Installation
Installtion script will install relevant packages and create links for config files.
`cd ~ && git clone git@github.com:sabah1994/dotfiles.git && dotfiles/scripts/installation.sh`
