vim.g.gruvbox_baby_highlights = {
    -- Normal = { bg = "#171717" },
    CocHighlightText = { bg = "#32302f" }
}
vim.g.gruvbox_baby_background_color = "dark"
vim.g.gruvbox_baby_string_style = "italic"

vim.cmd [[colorscheme gruvbox-baby]]
vim.api.nvim_set_hl(0, "Folded", { fg = "#d65d0e", italic = true, bold = true })
