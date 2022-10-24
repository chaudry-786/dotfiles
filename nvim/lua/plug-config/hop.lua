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
vim.api.nvim_set_hl(0, "HopNextKey", { bold=true, fg = "#ff007c", bg = "None" })
vim.api.nvim_set_hl(0, "HopNextKey1", { bold=true, fg = "#00dfff", bg = "None" })
vim.api.nvim_set_hl(0, "HopNextKey2", { fg = "#2b8db3", bg = "None" })
