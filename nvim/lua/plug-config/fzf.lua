local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<leader>/", ":FzfBLines<CR>", opts)
keymap("n", "<leader>fb", ":FzfBuffers<CR>", opts)
keymap("n", "<leader>fc", ":FzfCommands<CR>", opts)
keymap("n", "<leader>ff", ":FzfFiles<CR>", opts)
keymap("n", "<leader>fg", ":FzfAg<CR>", opts)
keymap("n", "<leader>fh", ":FzfHelptags<CR>", opts)
keymap("n", "<leader>fm", ":FzfMaps<CR>", opts)

vim.g["fzf_command_prefix"] = "Fzf"
-- " Other useful commands
-- " Commits   | For commits
-- " BCommits  | Commits related to current buffer
