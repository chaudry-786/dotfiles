vim.g.gruvbox_baby_highlights = {
    CocHighlightText = { bg = "#32302f" },
    Visual = { bg = "#6e1515" },
}
vim.g.gruvbox_baby_background_color = "dark"
vim.g.gruvbox_baby_string_style = "italic"
-- change yellow colour to orange
vim.g.gruvbox_baby_color_overrides = { soft_yellow = "#fe8019" }

vim.cmd [[colorscheme gruvbox-baby]]
vim.api.nvim_set_hl(0, "CocUnusedHighlight", { underline = true })
