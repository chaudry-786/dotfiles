-- only trigger on these keys
vim.g["qs_highlight_on_keys"] = { 'f', 'F', 't', 'T' }

-- highlights
vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = '#00dfff', bold = true, underline = true })
vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = '#afff5f', bold = true, underline = true })
