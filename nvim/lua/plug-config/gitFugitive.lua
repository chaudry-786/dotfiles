
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<leader>gv", ":Gvdiffsplit<CR>", opts)
-- " git checkout --filename at buffer level (use undo to revert checkout)
keymap("n", "<leader>gc", ":Gread<CR>", opts)
-- "Git add --filename
keymap("n", "<leader>ga", ":Gwrite<CR>", opts)
keymap("n", "<leader>gd", ":G diff<CR>", opts)
keymap("n", "<leader>gds", ":G diff --staged<CR>", opts)
keymap("n", "<leader>gb", ":G blame<CR>", opts)
-- " Notes: useful commands
-- " Git blame       - Open git blame on left, press o open the commit
-- " Git difftool    - Open diff for current buffer in quickfix list
-- " Git difftool -y - Open all git modifed files in a new tab
-- " Gclog           - Open commit history in quick fix list (use cn and cp to
-- " jump between quickfix items)
