"""Helpers shared by the WSL -> Windows settings sync scripts."""

import json
import os
import shutil
import subprocess

DOTFILES = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

POWERSHELL_FALLBACK = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"


def _scan(text, handle):
    """Walk text, copying strings as-is and calling handle(text, i, out) outside
    strings. handle returns the next index, or None to copy the character."""
    out = []
    i, n = 0, len(text)
    in_string = False
    while i < n:
        c = text[i]
        if in_string:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 1
            elif c == '"':
                in_string = False
            i += 1
            continue
        if c == '"':
            in_string = True
        else:
            next_i = handle(text, i, out)
            if next_i is not None:
                i = next_i
                continue
        out.append(c)
        i += 1
    return "".join(out)


def _skip_comment(text, i, out):
    if text.startswith("//", i):
        end = text.find("\n", i)
        return len(text) if end == -1 else end
    if text.startswith("/*", i):
        end = text.find("*/", i + 2)
        return len(text) if end == -1 else end + 2
    return None


def _skip_trailing_comma(text, i, out):
    if text[i] == "," and text[i + 1 :].lstrip()[:1] in ("}", "]"):
        return i + 1
    return None


def strip_jsonc(text):
    """Remove // and /* */ comments and trailing commas, leaving strings intact."""
    return _scan(_scan(text, _skip_comment), _skip_trailing_comma)


def load_jsonc(path):
    """Load a JSON file that may contain comments and trailing commas (VS Code, Windows Terminal)."""
    with open(path, encoding="utf-8-sig") as f:
        text = f.read()
    if not text.strip():
        return {}
    return json.loads(strip_jsonc(text))


def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.write("\n")


def _powershell():
    return shutil.which("powershell.exe") or (POWERSHELL_FALLBACK if os.path.exists(POWERSHELL_FALLBACK) else None)


def get_windows_env(name):
    """Read a Windows environment variable (e.g. APPDATA) through WSL interop."""
    pwsh = _powershell()
    if pwsh:
        try:
            completed = subprocess.run(
                [pwsh, "-NoProfile", "-NonInteractive", "-Command", f"[Environment]::GetEnvironmentVariable('{name}')"],
                capture_output=True,
                text=True,
                timeout=30,
                cwd="/mnt/c" if os.path.isdir("/mnt/c") else None,
            )
            value = completed.stdout.strip()
            if value:
                return value
        except (OSError, subprocess.TimeoutExpired):
            pass

    cmd = shutil.which("cmd.exe")
    if cmd:
        try:
            completed = subprocess.run(
                [cmd, "/c", f"echo %{name}%"],
                capture_output=True,
                text=True,
                timeout=30,
                cwd="/mnt/c" if os.path.isdir("/mnt/c") else None,
            )
            value = completed.stdout.strip()
            if value and value != f"%{name}%":
                return value
        except (OSError, subprocess.TimeoutExpired):
            pass

    value = input(f"Could not read Windows %{name}%. Please enter it (e.g. C:\\Users\\you\\AppData\\Roaming): ").strip()
    if not value:
        raise SystemExit(f"Windows %{name}% not provided")
    return value


def to_wsl_path(windows_path):
    return subprocess.run(["wslpath", "-u", windows_path], capture_output=True, text=True, check=True).stdout.strip()
