"""Tests for the WSL -> Windows sync scripts. Run: python3 utils/test_wsl_sync.py"""

import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts"))

import wsl_terminal_sync  # noqa: E402
import wsl_vscode_sync  # noqa: E402
from wsl_common import DOTFILES, load_jsonc, strip_jsonc  # noqa: E402


class TestJsonc(unittest.TestCase):
    def test_comments_and_trailing_commas(self):
        text = """{
            // line comment
            "url": "https://example.com/a//b", /* block */
            "s": "not a /* comment */ here",
            "quote": "say \\"hi\\" // still string",
            "list": [1, 2, /* x */ 3,],
            "obj": {"a": 1, // trailing
            },
        }"""
        self.assertEqual(
            json.loads(strip_jsonc(text)),
            {
                "url": "https://example.com/a//b",
                "s": "not a /* comment */ here",
                "quote": 'say "hi" // still string',
                "list": [1, 2, 3],
                "obj": {"a": 1},
            },
        )

    def test_repo_files_parse(self):
        for rel in ("vscode/settings.json", "vscode/wsl_settings.json", "vscode/keybindings.json",
                    "winTerminal/settings.json"):
            with self.subTest(rel):
                load_jsonc(os.path.join(DOTFILES, rel))


class TestVscodeSync(unittest.TestCase):
    def test_sync(self):
        with tempfile.TemporaryDirectory() as tmp:
            user_dir = os.path.join(tmp, "Code", "User")
            wsl_vscode_sync.sync(DOTFILES, user_dir)

            settings = load_jsonc(os.path.join(user_dir, "settings.json"))
            base = load_jsonc(os.path.join(DOTFILES, "vscode", "settings.json"))
            wsl = load_jsonc(os.path.join(DOTFILES, "vscode", "wsl_settings.json"))
            self.assertEqual(set(settings), set(base) | set(wsl))
            for key, value in wsl.items():
                if isinstance(value, dict):
                    self.assertEqual(settings[key], {**base.get(key, {}), **value})
                else:
                    self.assertEqual(settings[key], value)
            self.assertTrue(os.path.exists(os.path.join(user_dir, "keybindings.json")))
            snippets = os.listdir(os.path.join(user_dir, "snippets"))
            self.assertIn("python.json", snippets)
            self.assertFalse([s for s in snippets if s.endswith(".txt")])

    def test_wsl_overrides(self):
        with tempfile.TemporaryDirectory() as tmp:
            a, b = os.path.join(tmp, "a.json"), os.path.join(tmp, "b.json")
            with open(a, "w") as f:
                f.write('{"x": 1, "y": 2, "[python]": {"fmt": "black", "tab": 4}}')
            with open(b, "w") as f:
                f.write('{"x": 3, "[python]": {"fmt": "ruff"}}')
            self.assertEqual(
                wsl_vscode_sync.merge_settings(a, b), {"x": 3, "y": 2, "[python]": {"fmt": "ruff", "tab": 4}}
            )


class TestTerminalSync(unittest.TestCase):
    CURRENT = {
        "defaultProfile": "{guid-1}",
        "profiles": {
            "defaults": {"opacity": 90, "font": {"face": "Cascadia Mono"}},
            "list": [{"guid": "{guid-1}", "name": "Ubuntu", "source": "Windows.Terminal.Wsl"}],
        },
        "schemes": [{"name": "Gruvbox Dark", "background": "#000000"}, {"name": "Campbell"}],
        "actions": [{"command": "paste", "id": "User.paste"}],
        "keybindings": [{"id": "User.paste", "keys": "ctrl+v"}, {"id": "Terminal.Old", "keys": "shift+enter"}],
    }

    def test_merge_keeps_existing(self):
        ours = load_jsonc(os.path.join(DOTFILES, "winTerminal", "settings.json"))
        merged = wsl_terminal_sync.merge(self.CURRENT, ours)

        self.assertEqual(merged["defaultProfile"], "{guid-1}")
        self.assertEqual(merged["profiles"]["list"], self.CURRENT["profiles"]["list"])
        defaults = merged["profiles"]["defaults"]
        self.assertEqual(defaults["opacity"], 90)
        self.assertEqual(defaults["font"]["face"], "JetBrainsMonoNL Nerd Font")
        self.assertEqual(defaults["colorScheme"], "Gruvbox Dark")

        schemes = {s["name"]: s for s in merged["schemes"]}
        self.assertIn("Campbell", schemes)
        self.assertEqual(schemes["Gruvbox Dark"]["background"], "#282828")

        keys = {kb["keys"]: kb["id"] for kb in merged["keybindings"]}
        self.assertEqual(keys["ctrl+v"], "User.paste")
        self.assertTrue(keys["shift+enter"].startswith("User.sendInput"))
        self.assertEqual(len([kb for kb in merged["keybindings"] if kb["keys"] == "shift+enter"]), 1)
        # merging twice changes nothing
        self.assertEqual(wsl_terminal_sync.merge(merged, ours), merged)

    def test_sync_file_backup_and_create(self):
        with tempfile.TemporaryDirectory() as tmp:
            app = os.path.join(tmp, "Packages", "Microsoft.WindowsTerminal_8wekyb3d8bbwe")
            os.makedirs(os.path.join(app, "LocalState"))
            settings = os.path.join(app, "LocalState", "settings.json")
            with open(settings, "w") as f:
                f.write("// comment\n" + json.dumps(self.CURRENT))

            self.assertTrue(wsl_terminal_sync.sync(tmp))
            files = os.listdir(os.path.join(app, "LocalState"))
            self.assertEqual(len([f for f in files if ".bak-" in f]), 1)
            self.assertEqual(load_jsonc(settings)["profiles"]["defaults"]["colorScheme"], "Gruvbox Dark")

            # second sync: no change, no new backup
            wsl_terminal_sync.sync(tmp)
            self.assertEqual(len([f for f in os.listdir(os.path.join(app, "LocalState")) if ".bak-" in f]), 1)

    def test_default_profile(self):
        settings = {
            "defaultProfile": "{ps}",
            "profiles": {
                "list": [
                    {"guid": "{ps}", "name": "Windows PowerShell"},
                    {"guid": "{old}", "name": "Ubuntu-22.04", "source": "Windows.Terminal.Wsl"},
                    {"guid": "{new}", "name": "Ubuntu 24.04 LTS", "source": "CanonicalGroupLimited.Ubuntu24.04LTS_79rhkp1fndgsc"},
                ]
            },
        }
        self.assertTrue(wsl_terminal_sync.set_default_profile(settings, "Ubuntu-24.04"))
        self.assertEqual(settings["defaultProfile"], "{new}")
        self.assertFalse(wsl_terminal_sync.set_default_profile(settings, "Debian"))
        self.assertEqual(settings["defaultProfile"], "{new}")

    def test_not_installed(self):
        with tempfile.TemporaryDirectory() as tmp:
            self.assertFalse(wsl_terminal_sync.sync(tmp))


if __name__ == "__main__":
    unittest.main()
