local keymap = vim.api.nvim_set_keymap

keymap("n", "]h", "<Plug>(GitGutterNextHunk)", {})
keymap("n", "[h", "<Plug>(GitGutterPrevHunk)", {})
keymap("n", "<leader>gha", "<Plug>(GitGutterStageHunk)", {})
keymap("x", "<leader>gha", "<Plug>(GitGutterStageHunk)", {})
keymap("n", "<leader>ghu", "<Plug>(GitGutterUndoHunk)", {})
keymap("n", "<leader>ghp", "<Plug>(GitGutterPreviewHunk)", {})

-- text-objects
keymap("o", "ih", "<Plug>(GitGutterTextObjectInnerPending)", {})
keymap("o", "ah", "<Plug>(GitGutterTextObjectOuterPending)", {})
keymap("x", "ih", "<Plug>(GitGutterTextObjectInnerVisual)", {})
keymap("x", "ah", "<Plug>(GitGutterTextObjectOuterVisual)", {})

-- toggle
keymap("n", "<leader>tg", ":GitGutterToggle<CR>", {})
