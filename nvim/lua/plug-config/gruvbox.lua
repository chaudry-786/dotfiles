vim.g["gruvbox_contrast_dark"] = "hard"
vim.g["gruvbox_sign_column"] = "bg0"
vim.g["gruvbox_italic"] = 1
vim.g["gruvbox_italicize_strings"] = 1
vim.cmd [[colorscheme gruvbox]]
vim.api.nvim_set_hl(0, "CocHintSign", { fg = "#f5e342" }) --Colour for coc hintSign
-- fold colour
vim.api.nvim_set_hl(0, "Folded", { fg = "#d65d0e", bg = "#171717", italic = true, bold = true, ctermfg = 45,
    cterm = "bold,underline" })
-- " For even darker background
-- "cd ~/.vim/plugged/gruvbox/colors/gruvbox.vim let s:gb.dark0_hard  = ['#171717', 233]     " 29-32-33
-- "Line 591 change to: hi! link Operator GruvboxFg1 (https://github.com/morhetz/gruvbox/issues/260)
