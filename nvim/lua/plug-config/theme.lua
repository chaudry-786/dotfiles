require("rose-pine").setup({
    disable_italics = true,
    bold_vert_split = true,
    highlight_groups = {
        Folded = { bg = "gold", blend = 6, fg = "subtle" },
        CocHighlightText = { bg = "subtle", blend = 30 },
        Visual = { bg = "foam", blend = 25 },
        YankHighlight = { bg = "foam", blend = 50 },
    }
})

vim.cmd("colorscheme rose-pine")
