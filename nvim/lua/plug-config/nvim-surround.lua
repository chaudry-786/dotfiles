require("nvim-surround").setup({
    keymaps = {
        insert = false,
        insert_line = false,
        normal = "ys",
        normal_line = false,
        normal_cur = false,
        normal_cur_line = false,
        visual = "<leader>s",
        visual_line = false,
        delete = "ds",
        change = "cs",
    }
})

e_map({ "n" }, "ys", [[<Plug>(nvim-surround-normal)]], "Surround text in normal mode.")
e_map({ "v" }, "<leader>s", [[<Plug>(nvim-surround-visual)]], "Surround selected text in visual mode.")
e_map({ "n" }, "ds", [[<Plug>(nvim-surround-delete)]], "Delete surrounding characters.")
e_map({ "n" }, "cs", [[<Plug>(nvim-surround-change)]], "Change surrounding characters.")