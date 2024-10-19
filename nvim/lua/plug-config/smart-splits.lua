require("smart-splits").setup({})

-- alt+shift+hjkl smart resize
map("n", "<A-S-h>", require("smart-splits").resize_left, "Resize window to the left")
map("n", "<A-S-j>", require("smart-splits").resize_down, "Resize window down")
map("n", "<A-S-k>", require("smart-splits").resize_up, "Resize window up")
map("n", "<A-S-l>", require("smart-splits").resize_right, "Resize window to the right")
