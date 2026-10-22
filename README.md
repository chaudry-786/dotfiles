# dotfiles

Zsh, Neovim, tmux, kitty, VS Code and Windows Terminal setup for **Ubuntu** and **Windows (WSL)**.
One script installs everything, and the same script keeps it up to date.

- [Fresh Ubuntu](#fresh-ubuntu)
- [Fresh Windows (WSL)](#fresh-windows-wsl)
- [What gets installed](#what-gets-installed)
- [Keeping it up to date](#keeping-it-up-to-date)

---

## Fresh Ubuntu

Supported: Ubuntu 24.04 or newer, x86_64, a user with sudo rights. Takes about 20–30 minutes.

**1. Install git and ssh** (not always there on a fresh install):
```bash
sudo apt update && sudo apt install -y git openssh-client
```

**2. Create an SSH key and add it to GitHub** (see [SSH key for GitHub](#ssh-key-for-github)).

**3. Clone and run:**
```bash
git clone personal:chaudry-786/dotfiles ~/dotfiles
~/dotfiles/scripts/installation.sh
```

**4. Do the "Next steps" the script prints at the end**, usually: log out and back in (zsh becomes your shell).

---

## Fresh Windows (WSL)

Everything is run from inside Ubuntu (WSL). The script also installs and configures the Windows side for you:
VS Code, Windows Terminal and the font.

Supported: Windows 11 or Windows 10 (22H2). Takes about 20–30 minutes.

**1. Install WSL with Ubuntu.** Open **PowerShell as Administrator** and run:
```powershell
wsl --install -d Ubuntu-24.04
```
Restart Windows when asked. Ubuntu opens after the restart (or start it from the Start menu) and asks for a
new UNIX username and password. That password is your sudo password.

**2. Check winget works.** In a normal PowerShell window:
```powershell
winget --version
```
If it isn't found (older Windows 10), install **App Installer** from the Microsoft Store.

**3. In the Ubuntu window, do the same as on Ubuntu:**
```bash
sudo apt update && sudo apt install -y git openssh-client
```
Create an SSH key inside Ubuntu (see [SSH key for GitHub](#ssh-key-for-github)), then:
```bash
git clone personal:chaudry-786/dotfiles ~/dotfiles
~/dotfiles/scripts/installation.sh
```
Clone into the Linux home (`~/dotfiles`), not into `/mnt/c/...`. The Windows drive is much slower from WSL.

**4. Do the "Next steps" the script prints at the end**, usually:
- close the Ubuntu window and open **Windows Terminal**. It now opens Ubuntu by default with the
  JetBrainsMono Nerd Font and the Gruvbox theme.
- open projects with `code <folder>` from WSL.

---

## SSH key for GitHub

Needed to clone (and later push) the dotfiles. Run inside Ubuntu / WSL:
```bash
# 1. create the key (press enter to accept the location; a passphrase is optional)
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519

# 2. add the "personal" host alias used by this repo's remote (personal:chaudry-786/dotfiles)
cat >> ~/.ssh/config <<'EOF'
Host personal github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config

# 3. print the public key
cat ~/.ssh/id_ed25519.pub
```
4. Copy the printed line and add it as a new key at <https://github.com/settings/ssh/new>.
5. Test it with `ssh -T personal`. The first time, type `yes`. It should answer "Hi chaudry-786! You've successfully authenticated".

---

## What the script does

When you run `~/dotfiles/scripts/installation.sh`:

1. **Checks first, before changing anything.** It stops and explains how to fix anything missing:
   - you're not root
   - Ubuntu/x86_64
   - internet
   - sudo rights
   - free disk space
   - on WSL: that Windows can be reached (`powershell.exe`) and that winget exists

   It asks for your sudo password once and keeps it valid for the whole run.
2. **Shows a plan:** every step, ✓ if already installed, `+` with what it will install.
3. **Asks once:** `[y]es all / [c]hoose per step / [n]o`. Use `--yes` to skip this question.
4. **Installs**, then **shows available updates** and lets you choose (see [Keeping it up to date](#keeping-it-up-to-date)).
5. **Verifies** that everything is installed and works from a new zsh.
6. **Prints the next steps** that only you can do.

Re-running it is safe: anything already installed is skipped.

## What gets installed

| Step | Ubuntu | WSL |
|---|---|---|
| `base` | curl, git, wget; GNOME: caps lock → ctrl, ctrl+←/→ switches workspace | curl, git, wget |
| `zsh` | zsh (default shell), oh-my-zsh, powerlevel10k, autosuggestions, syntax highlighting, fzf, fzf-tab, zoxide | same |
| `packages` | ripgrep, bat, git-delta, lazygit, exa, xclip; node LTS (nvm) + tree-sitter-cli; python 3.11.5 (pyenv) | same |
| `tmux` | tmux + plugins (tpm, tmux-cpu, tmux-yank) | same |
| `kitty` | kitty terminal with config | — (Windows Terminal is used) |
| `vim` | neovim nightly, its plugins (versions from `nvim/lazy-lock.json`), python venv `~/vim_venv` | same |
| `link` | links `.gitconfig`, `.gitignore`, `.clang-format` | same |
| `languages` | gcc/make (build-essential), lua 5.3 | same |
| `font` | JetBrainsMonoNL Nerd Font (latest release) | installed on **Windows** for your user |
| `vscode` | VS Code (.deb, updates through apt), extensions, settings linked | VS Code on **Windows** (winget), extensions on Windows and in WSL, settings copied |
| `terminal` | — | Windows Terminal (winget); font, theme and keybindings merged into its settings (your profiles are kept, a backup is written); Ubuntu set as the default profile |

Config files are linked from this repo, so editing them in `~/dotfiles` takes effect right away.
Windows can't follow links into WSL, so the VS Code and Windows Terminal settings are copied instead.
Re-run the script after changing those.

Your git name and email are not set by the script. `~/.gitconfig` is linked to this repo, so don't use
`git config --global`. The script prints the command to use instead:
`git config --file ~/.config/git/config user.email "you@example.com"`.

## Keeping it up to date

Run the same script again:
```bash
~/dotfiles/scripts/installation.sh
```
It installs anything new that was added to the dotfiles, then shows a table of available updates, for example:
```
UPDATE                           INSTALLED                LATEST
lazygit                          0.40.2                   0.66.2
node (LTS)                       22.11.0                  24.11.1
oh-my-zsh                        1a2b3c4                  +12 commits
```
It asks about each one: `[y]es / [n]o / [a]ll remaining / [s]kip the rest`.

It covers:
- apt packages
- the zsh, tmux and pyenv plugins
- nvm, node and npm packages
- lazygit and zoxide
- neovim nightly
- kitty
- the font
- the vim venv
- VS Code on Windows

Python stays at 3.11.5. Neovim plugins are updated from inside nvim (`:Lazy`), which updates `nvim/lazy-lock.json`.

### Options
```bash
installation.sh --yes                   # no questions: install everything and apply all updates
installation.sh --check                 # only report what's missing / outdated (exit code 1 if anything)
installation.sh --skip font,vscode      # skip steps (names from the table above)
```

### Testing the installer
- `utils/test_install.sh [ubuntu-version]` installs on a fresh Ubuntu docker container, re-runs it, and checks
  that updates are detected (default 24.04, also tested on 26.04).
- `utils/test_wsl.sh` runs the WSL path in docker, with a fake Windows (`utils/wsl_stub`).
- `python3 utils/test_wsl_sync.py` runs the unit tests for the VS Code / Windows Terminal settings sync.

---

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

    Custom config, plugins managed by tpm (cpu usage in status bar, yank to system clipboard).

### Terminal emulator

    On Ubuntu I use kitty (config included), on Windows Windows Terminal (config included) and on MacOS Iterm2.
        Kitty doesn't render as crispy on external monitor on MacOS

### Commong keymappings
-- f = find
-- g = git
-- r = run
-- t = toggle
-- c = cell
-- s = surround

-- movements
-- []C = class
-- []Q = first and last qfix list
-- []a = diagnostics
-- []f = function
-- []h = git hunk
-- []i = conditional
-- []l = loop
-- []q = qfix list


### VSCode limitations
    / mapping doesn't expand in command line.


WISH list:
    django aliasas
    run django shell form jupyet notebook
        https://stackoverflow.com/questions/35483328/how-do-i-set-up-jupyter-ipython-notebook-for-django
    GraphQL extension: https://marketplace.visualstudio.com/items?itemName=GraphQL.vscode-graphql
    Postman VS code: https://marketplace.visualstudio.com/items?itemName=Postman.postman-for-vscode
