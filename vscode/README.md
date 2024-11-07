# Install extensions

cat vscode/extensions.txt | xargs -L 1 code --install-extension

Update extensions list: code --list-extensions > vscode/extensions.txt