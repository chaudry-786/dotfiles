vim.g.gruvbox_baby_highlights = {
    -- Normal = { bg = "#171717" },
    CocHighlightText = { bg = "#32302f" }
}
vim.g.gruvbox_baby_background_color = "dark"
vim.g.gruvbox_baby_string_style = "italic"

vim.cmd [[colorscheme gruvbox-baby]]
vim.highlight.create("Folded", { guifg = "#d65d0e", guibg = "#171717", gui = "italic,bold", ctermfg = 45,
    cterm = "bold,underline" })
