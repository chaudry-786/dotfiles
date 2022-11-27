local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<leader>f", ":<C-u>FzfFiles<CR>", opts)
keymap("n", "<leader>gf", ":<C-u>FzfGFiles?<CR>", opts)
keymap("n", "<leader>b", ":<C-u>FzfBuffers<CR>", opts)
keymap("n", "<leader>/", ":<C-u>FzfAg<CR>", opts)
keymap("n", "<leader>c", ":<C-u>FzfCommands<CR>", opts)

vim.g["fzf_command_prefix"] = "Fzf"
-- " Other useful commands
-- " Commits   | For commits
-- " BCommits  | Commits related to current buffer
