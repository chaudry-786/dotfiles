-- get rid of traling whitespace
local function TrimWhiteSpace()
    local save = vim.fn.winsaveview()
    vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
end

vim.api.nvim_create_autocmd("BufWritePre", { group = "CustomAutoCmds", pattern = '*', callback = TrimWhiteSpace })

-- briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost",
    { group = "CustomAutoCmds", pattern = '*', callback = function() vim.highlight.on_yank({ timeout = 300, higroup = "YankHighlight" }) end })
