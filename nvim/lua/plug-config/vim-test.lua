local keymap = e_map
keymap("n", "<leader>rt", ":TestNearest<CR>", "Run nearest test.")
keymap("n", "<leader>rT", ":TestFile<CR>", "Run tests on entire file.")
keymap("n", "<leader>rl", ":TestLast<CR>", "Run last test.")
keymap("n", "<leader>rs", ":TestSuite<CR>", "Run entire test suite.")

if vim.g.vscode then
    vim.g["test#strategy"] = "neovim_vscode"
else
    vim.g["test#strategy"] = "vimux"
end

--language-specific
vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "--disable-warnings -s"
