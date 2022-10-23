require("nvim-surround").setup({
    keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "yS",
        normal_line = "ySl",
        normal_cur = "<Nop>",
        normal_cur_line = "<Nop>",
        visual = "S",
        visual_line = "gS",
        delete = "dS",
        change = "cS",
    }
})
