require('lualine').setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", { "diff", symbols = { added = " ", modified = "柳", removed = " " } } },
        lualine_c = {
            { "filetype", padding = { right = 0, left = 2 }, icon_only = true,
                component_separators = { left = "", right = "" } },
            { "filename", padding = { left = 1 }, color = { gui = "bold,italic", fg = "#ebdbb2" } }
        },
        lualine_x = { { "aerial", padding = { right = 2, left = 2 }, dense = true, } },
        lualine_y = {
            {
                "diagnostics",
                sources = { "coc" },
                sections = { "hint", "warn", "error" },
                symbols = { error = " " },
                always_visible = true -- Show diagnostics even if there are none.
            }
        },
        lualine_z = { "progress", "location" }
    }
})
