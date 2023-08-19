local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
keymap("n", "<leader>xt", ":TestNearest<CR>", opts)
keymap("n", "<leader>xT", ":TestFile<CR>", opts)
keymap("n", "<leader>xl", ":TestLast<CR>", opts)
keymap("n", "<leader>xs", ":TestSuite<CR>", opts)

-- global
vim.g["test#strategy"] = "make"
-- TODO: explore rest of the strategies, goal is
-- to get erros in qf list AND in colourful output
-- potential strategies  neomake, dispatc

--language-specific
vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "--disable-warnings"
