"""Merge winTerminal/settings.json from the dotfiles into Windows Terminal's settings.

Your existing profiles and settings are kept. From the dotfiles file:
  - top level settings (e.g. alwaysShowTabs) are set
  - profiles.defaults (font, colours, ...) are merged into Windows Terminal's defaults
  - schemes are added/replaced by name, actions by id, keybindings by keys
  - the profile of this WSL distro becomes the default profile
A timestamped backup is written next to the settings file before changing it.
"""

import copy
import os
import re
import shutil
import sys
import time

from wsl_common import DOTFILES, get_windows_env, load_jsonc, to_wsl_path, write_json

# (app folder that exists once installed, settings file), relative to %LOCALAPPDATA%
TERMINAL_SETTINGS = [
    ("Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe", "LocalState/settings.json"),
    ("Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe", "LocalState/settings.json"),
    ("Microsoft/Windows Terminal", "settings.json"),
]


def upsert(items, new_items, key):
    """Replace items with the same key (e.g. scheme name), append the rest."""
    result = [i for i in items if i.get(key) not in {n.get(key) for n in new_items}]
    return result + copy.deepcopy(new_items)


def merge(current, ours):
    merged = copy.deepcopy(current)
    for k, v in ours.items():
        if k not in ("profiles", "schemes", "actions", "keybindings"):
            merged[k] = copy.deepcopy(v)

    profiles = merged.get("profiles")
    # old settings format: "profiles" is a plain list
    if isinstance(profiles, list):
        profiles = {"list": profiles}
    profiles = profiles or {}
    profiles.setdefault("list", [])
    profiles["defaults"] = {**profiles.get("defaults", {}), **ours.get("profiles", {}).get("defaults", {})}
    merged["profiles"] = profiles

    merged["schemes"] = upsert(merged.get("schemes", []), ours.get("schemes", []), "name")
    merged["actions"] = upsert(merged.get("actions", []), [a for a in ours.get("actions", []) if "id" in a], "id")
    merged["keybindings"] = upsert(merged.get("keybindings", []), ours.get("keybindings", []), "keys")
    return merged


def _norm(name):
    return re.sub(r"[^a-z0-9]", "", name.lower())


def distro_profile(settings, distro):
    """The profile Windows Terminal generated for a WSL distro, e.g. "Ubuntu-24.04"
    (WSL generator) or "Ubuntu 24.04 LTS" (Store app)."""
    for profile in settings.get("profiles", {}).get("list", []):
        source = profile.get("source", "")
        if ("Wsl" in source or "Canonical" in source) and _norm(distro) in _norm(profile.get("name", "")):
            return profile
    return None


def set_default_profile(settings, distro):
    profile = distro and distro_profile(settings, distro)
    if profile and profile.get("guid"):
        settings["defaultProfile"] = profile["guid"]
        return True
    return False


def undefined_actions(settings):
    """User keybindings that point to an action id that doesn't exist."""
    ids = {a.get("id") for a in settings.get("actions", [])}
    return [
        kb for kb in settings.get("keybindings", []) if str(kb.get("id", "")).startswith("User.") and kb["id"] not in ids
    ]


def sync_file(settings_path, ours, distro=None):
    current = load_jsonc(settings_path) if os.path.exists(settings_path) else {}
    merged = merge(current, ours)
    if distro and not set_default_profile(merged, distro):
        print(
            f"Note: no Windows Terminal profile for {distro} yet. "
            "Open Windows Terminal once and re-run the installer to make it the default.",
            file=sys.stderr,
        )
    if merged == current:
        print(f"Windows Terminal settings already up to date: {settings_path}")
        return merged
    if os.path.exists(settings_path):
        backup = f"{settings_path}.bak-{time.strftime('%Y%m%d-%H%M%S')}"
        shutil.copyfile(settings_path, backup)
        print(f"Backup: {backup}")
    write_json(settings_path, merged)
    print(f"Windows Terminal settings synced: {settings_path}")
    return merged


def sync(local_app_data, distro=None):
    ours = load_jsonc(os.path.join(DOTFILES, "winTerminal", "settings.json"))
    synced = 0
    for app_dir, settings_file in TERMINAL_SETTINGS:
        app_dir = os.path.join(local_app_data, app_dir)
        if not os.path.isdir(app_dir):
            continue
        path = os.path.join(app_dir, settings_file)
        merged = sync_file(path, ours, distro)
        synced += 1
        for kb in undefined_actions(merged):
            print(
                f"Warning: keybinding {kb.get('keys')} -> {kb['id']} has no action. "
                "Add the action to winTerminal/settings.json",
                file=sys.stderr,
            )
    if not synced:
        print("Windows Terminal not found, nothing to sync", file=sys.stderr)
        return False
    return True


def main():
    local_app_data = to_wsl_path(get_windows_env("LOCALAPPDATA"))
    try:
        return 0 if sync(local_app_data, os.environ.get("WSL_DISTRO_NAME")) else 1
    except (ValueError, OSError) as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
