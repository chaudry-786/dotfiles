require("smart-splits").setup({})

-- alt+shift+hjkl
vim.keymap.set("n", "<A-S-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-S-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-S-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-S-l>", require("smart-splits").resize_right)
