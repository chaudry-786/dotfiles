local keymap = map
keymap("n", "<leader>rt", ":TestNearest<CR>", "Run nearest test.")
keymap("n", "<leader>rT", ":TestFile<CR>", "Run tests on entire file.")
keymap("n", "<leader>rl", ":TestLast<CR>", "Run last test.")
keymap("n", "<leader>rs", ":TestSuite<CR>", "Run entire test suite.")

-- global
vim.g["test#strategy"] = "vimux"
-- TODO: explore rest of the strategies, goal is
-- to get errors in qf list AND in colourful output
-- potential strategies  neomake, dispatch, make

--language-specific
vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "--disable-warnings -s"
