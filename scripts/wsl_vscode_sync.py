import json
import os
import re
import shutil


def load_json_without_comments(json_file):
    with open(json_file, "r") as f:
        content = f.read()
    content = re.sub(r"\/\/.*", "", content)
    return json.loads(content)


def sync_settings(settings_file, wsl_settings_file, windows_settings_path):
    try:
        base_settings = load_json_without_comments(settings_file)
        wsl_settings = load_json_without_comments(wsl_settings_file)

        duplicate_keys = set(base_settings.keys()) & set(wsl_settings.keys())
        if duplicate_keys:
            raise ValueError(f"Duplicate keys found: {', '.join(duplicate_keys)}")

        merged_settings = {**base_settings, **wsl_settings}
        os.makedirs(os.path.dirname(windows_settings_path), exist_ok=True)

        with open(windows_settings_path, "w") as outfile:
            json.dump(merged_settings, outfile, indent=4)

        print(f"Settings merged and saved to: {windows_settings_path}")

    except ValueError as ve:
        print(f"Error: {ve}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


settings_file_path = "/home/sabah/dotfiles/vscode/settings.json"
wsl_settings_file_path = "/home/sabah/dotfiles/vscode/wsl_settings.json"
windows_settings_path = "/mnt/c/Users/Sabah.Din/AppData/Roaming/Code/User/settings.json"
sync_settings(settings_file_path, wsl_settings_file_path, windows_settings_path)


# Copy keybinding file
shutil.copy("/home/sabah/dotfiles/vscode/keybindings.json", "/mnt/c/Users/Sabah.Din/AppData/Roaming/Code/User/keybindings.json")
