require("nvim-surround").setup({})

e_map({ "n" }, "yS", [[<Plug>(nvim-surround-normal)]], "Surround text in normal mode.")
e_map({ "v" }, "S", [[<Plug>(nvim-surround-visual)]], "Surround selected text in visual mode.")
e_map({ "v" }, "<leader>S", [[<Plug>(nvim-surround-visual)]], "Surround selected text in visual mode.")
e_map({ "n" }, "dS", [[<Plug>(nvim-surround-delete)]], "Delete surrounding characters.")
e_map({ "n" }, "cS", [[<Plug>(nvim-surround-change)]], "Change surrounding characters.")
