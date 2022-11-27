-- get rid of traling whitespace
local function TrimWhiteSpace()
    local save = vim.fn.winsaveview()
    vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
end

vim.api.nvim_create_autocmd("BufWritePre", { pattern = '*', callback = TrimWhiteSpace })

-- briefly highlight yanked text
-- move cursor (invoking CusorMoved) so coc highlight briefly goes away for clear highlight
-- vim.api.nvim_set_keymap("n", "y", "lhy", { noremap = true, silent = true })
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#34495E" })
vim.api.nvim_create_autocmd("TextYankPost",
    { pattern = '*', callback = function() vim.highlight.on_yank({ timeout = 300, higroup = "YankHighlight" }) end })
