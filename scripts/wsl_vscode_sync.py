import json
import os
import re
import shutil
import subprocess
import getpass


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

def get_windows_username():
    pwsh = shutil.which("powershell.exe")
    if pwsh:
        try:
            completed = subprocess.run(
                [pwsh, "-NoProfile", "-Command", "$env:UserName"],
                capture_output=True,
                text=True,
                check=False,
                timeout=2
            )
            username = completed.stdout.strip()
            if username:
                return username
        except Exception:
                # Ask the user instead of raising an error
            username = input("Could not detect Windows username. Please enter your Windows username: ").strip()
            if username:
                return username
            else:
                raise ValueError("User name not provided")

# NOTE: Set this before running
WINDOW_USER = get_windows_username()
WINDOWS_BASE_PATH = f"/mnt/c/Users/{WINDOW_USER}/AppData/Roaming/Code/User"
WSL_BASE_PATH = "/home/sabah/dotfiles"

# 1) Merge and copy settings files
settings_file_path = f"{WSL_BASE_PATH}/vscode/settings.json"
wsl_settings_file_path = f"{WSL_BASE_PATH}/vscode/wsl_settings.json"
windows_settings_path = f"{WINDOWS_BASE_PATH}/settings.json"
sync_settings(settings_file_path, wsl_settings_file_path, windows_settings_path)

# 2) Copy keybinding file
shutil.copyfile(f"{WSL_BASE_PATH}/vscode/keybindings.json", f"{WINDOWS_BASE_PATH}/keybindings.json")

# 3) Copy snippets
snippets_dir_wsl = f"{WSL_BASE_PATH}/vscode/snippets/"
snippet_files = os.listdir(f"{WSL_BASE_PATH}/vscode/snippets/")
for f in snippet_files:
    shutil.copyfile(f"{snippets_dir_wsl}/{f}", f"{WINDOWS_BASE_PATH}/snippets/{f}")
