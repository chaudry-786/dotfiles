local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
require 'hop'.setup()

-- key-mappings
keymap("", "s", "<cmd>HopChar1<CR>", opts)
keymap("", "<leader>k", "<cmd>HopLineBC<CR>", opts)
keymap("", "<leader>j", "<cmd>HopLineAC<CR>", opts)
keymap("", "<leader><leader>k", "<cmd>HopWordBC<CR>", opts)
keymap("", "<leader><leader>j", "<cmd>HopWordAC<CR>", opts)

-- highlights
vim.highlight.create("HopNextKey", { gui = "bold", guifg = "#ff007c", guibg = "None" })
vim.highlight.create("HopNextKey1", { gui = "bold", guifg = "#00dfff", guibg = "None" })
vim.highlight.create("HopNextKey2", { guifg = "#2b8db3", guibg = "None" })
