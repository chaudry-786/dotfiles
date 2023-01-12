local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

require("leap")
keymap("", "s", "<Plug>(leap-forward-to)", { silent = true })
keymap("", "S", "<Plug>(leap-backward-to)", { silent = true })

-- easy linewise movement
require "hop".setup()
keymap("", "<leader>j", "<cmd>HopLineAC<CR>", opts)
keymap("", "<leader>k", "<cmd>HopLineBC<CR>", opts)
