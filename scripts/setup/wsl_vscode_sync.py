"""Copy VS Code settings from the dotfiles (in WSL) to VS Code on Windows.

Windows VS Code can't follow links into WSL, so the files are copied:
  - vscode/settings.json + vscode/wsl_settings.json are merged into settings.json
  - vscode/keybindings.json and vscode/snippets/*.json are copied
"""

import os
import shutil
import sys

from wsl_common import DOTFILES, get_windows_env, load_jsonc, to_wsl_path, write_json


def merge_settings(settings_file, wsl_settings_file):
    """wsl_settings.json overrides settings.json; nested objects such as
    "[python]" are merged key by key."""
    merged = load_jsonc(settings_file)
    for key, value in load_jsonc(wsl_settings_file).items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            value = {**merged[key], **value}
        if key in merged and merged[key] != value:
            print(f"wsl_settings.json overrides {key}")
        merged[key] = value
    return merged


def sync(dotfiles, windows_user_dir):
    vscode_dir = os.path.join(dotfiles, "vscode")

    # 1) Merge and copy settings files
    settings = merge_settings(os.path.join(vscode_dir, "settings.json"), os.path.join(vscode_dir, "wsl_settings.json"))
    write_json(os.path.join(windows_user_dir, "settings.json"), settings)

    # 2) Copy keybinding file
    shutil.copyfile(os.path.join(vscode_dir, "keybindings.json"), os.path.join(windows_user_dir, "keybindings.json"))

    # 3) Copy snippets
    snippets_dir = os.path.join(windows_user_dir, "snippets")
    os.makedirs(snippets_dir, exist_ok=True)
    for f in os.listdir(os.path.join(vscode_dir, "snippets")):
        if f.endswith((".json", ".code-snippets")):
            shutil.copyfile(os.path.join(vscode_dir, "snippets", f), os.path.join(snippets_dir, f))

    print(f"VS Code settings synced to: {windows_user_dir}")


def main():
    windows_user_dir = os.path.join(to_wsl_path(get_windows_env("APPDATA")), "Code", "User")
    try:
        sync(DOTFILES, windows_user_dir)
    except (ValueError, OSError) as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
