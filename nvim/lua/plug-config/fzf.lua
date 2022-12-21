local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Include hidden files in ripgrep command
vim.cmd([[
command! -bang -nargs=* FzfRg
  \ call fzf#vim#grep(
  \   'rg --hidden --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
]])

keymap("n", "<leader>/", ":FzfBLines<CR>", opts)
keymap("n", "<leader>fb", ":FzfBuffers<CR>", opts)
keymap("n", "<leader>fc", ":FzfCommands<CR>", opts)
keymap("n", "<leader>ff", ":FzfFiles<CR>", opts)
keymap("n", "<leader>fg", ":FzfRg<CR>", opts)
keymap("n", "<leader>fh", ":FzfHelptags<CR>", opts)
keymap("n", "<leader>fm", ":FzfMaps<CR>", opts)

vim.g["fzf_command_prefix"] = "Fzf"
-- " Other useful commands
-- " Commits   | For commits
-- " BCommits  | Commits related to current buffer
