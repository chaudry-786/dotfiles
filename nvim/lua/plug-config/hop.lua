local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local optss = { noremap = true, silent = true }
require 'hop'.setup()

-- key-mappings
keymap("", "s", "<cmd>HopChar1<CR>", opts)
keymap("", "<leader><leader>k", "<cmd>HopLineBC<CR>", opts)
keymap("", "<leader><leader>j", "<cmd>HopLineAC<CR>", opts)
keymap("", "<leader>k", "<cmd>HopWordBC<CR>", opts)
keymap("", "<leader>j", "<cmd>HopWordAC<CR>", opts)
