local keymap = vim.api.nvim_set_keymap
require 'hop'.setup()

-- key-mappings
-- "Not mapping s in operator mode because it's taken by surround
keymap("n", "s", "<cmd>HopChar1<CR>", {})
keymap("v", "s", "<cmd>HopChar1<CR>", {})
keymap("", "<leader>k", "<cmd>HopLineBC<CR>", {})
keymap("", "<leader>j", "<cmd>HopLineAC<CR>", {})
keymap("", "<leader><leader>k", "<cmd>HopWordBC<CR>", {})
keymap("", "<leader><leader>j", "<cmd>HopWordAC<CR>", {})

-- highlights
vim.highlight.create("HopNextKey", { gui = "bold", guifg = "#ff007c", guibg = "None" })
vim.highlight.create("HopNextKey1", { gui = "bold", guifg = "#00dfff", guibg = "None" })
vim.highlight.create("HopNextKey2", { guifg = "#2b8db3", guibg = "None" })
