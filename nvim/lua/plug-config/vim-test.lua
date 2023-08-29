local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
keymap("n", "<leader>rt", ":TestNearest<CR>", opts)
keymap("n", "<leader>rT", ":TestFile<CR>", opts)
keymap("n", "<leader>rl", ":TestLast<CR>", opts)
keymap("n", "<leader>rs", ":TestSuite<CR>", opts)

-- global
vim.g["test#strategy"] = "vimux"
-- TODO: explore rest of the strategies, goal is
-- to get erros in qf list AND in colourful output
-- potential strategies  neomake, dispatch, make

--language-specific
vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "--disable-warnings"
