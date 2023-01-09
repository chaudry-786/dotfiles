require('aerial').setup({
    layout = {
        default_direction = "right",
        min_width = 20,
    },
    nerd_font = true,
    show_guides = true,
    icons = {
        Class    = "\u{f0e8} ",
        Function = "",
        Method   = "",
    }
})

-- toggle | also disables fade plugin
vim.api.nvim_set_keymap("n", "<leader>to", ":AerialToggle <CR>", { silent = true, noremap = true })
