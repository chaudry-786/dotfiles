require("nvim-surround").setup({
    keymaps = {
        insert = false,
        insert_line = false,
        normal = "yS",
        normal_line = false,
        normal_cur = false,
        normal_cur_line = false,
        visual = "<leader>S",
        visual_line = false,
        delete = "dS",
        change = "cS",
    }
})

e_map({ "n" }, "yS", [[<Plug>(nvim-surround-normal)]], "Surround text in normal mode.")
e_map({ "v" }, "S", [[<Plug>(nvim-surround-visual)]], "Surround selected text in visual mode.")
e_map({ "n" }, "dS", [[<Plug>(nvim-surround-delete)]], "Delete surrounding characters.")
e_map({ "n" }, "cS", [[<Plug>(nvim-surround-change)]], "Change surrounding characters.")