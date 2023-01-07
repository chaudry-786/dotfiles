require("nvim-surround").setup({
    keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_line = "yS",
        normal_cur = "<Nop>",
        normal_cur_line = "<Nop>",
        visual = "s",
        visual_line = "S",
        delete = "ds",
        change = "cs",
    }
})
