require("aerial").setup({
    layout = {
        default_direction = "right",
        min_width = 20,
    },
    nerd_font = true,
    show_guides = true,
    icons = {
        Class    = "\u{f0e8} ",
        Function = "",
        Method   = "",
    }
})

-- toggle
map("n", "<leader>to", ":AerialToggle <CR>", "Toggle outline.")
