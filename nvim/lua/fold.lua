local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local set = vim.opt

--------------------------------------------------
-- Options
--------------------------------------------------
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldnestmax = 10
set.foldlevel = 0 --fold level: zr or zm
set.fillchars = { fold = " ", foldopen = " ", foldclose = "", foldsep = " " }
-- set.foldenable = false                                  --do not fold when buffer loads

vim.opt.foldtext = ""

-- non-treesitter methods for some files
vim.api.nvim_create_autocmd("FileType",
    { group = "CustomAutoCmds", pattern = "sql", command = [[ setlocal foldmethod=indent ]] })

--------------------------------------------------
-- Keymaps
--------------------------------------------------
--fold movement
keymap("", "[z", "zk", opts)
keymap("", "]z", "zj", opts)
-- -- toggle child folds recursively
keymap("n", "<CR>", function()
    if vim.fn.foldlevel(vim.fn.line('.')) == 0 then
        -- line not in a fold.
        return
    end
    local fold_status = vim.fn.foldclosed(vim.fn.line('.'))
    if fold_status == -1 then
        vim.cmd("normal! zxzc")
    else
        vim.cmd("normal! zA")
    end
end, opts)

local fold_mode = true
keymap("n", "<leader>tf", function()
    fold_mode = not fold_mode
    if fold_mode then
        vim.opt.foldenable = true
    else
        vim.opt.foldenable = false
    end
end, opts)

--------------------------------------------------
-- AutoCmds
--------------------------------------------------
-- do not map <CR> in qflist and cmdWin
vim.api.nvim_create_autocmd("CmdwinEnter", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        vim.cmd("nnoremap <buffer> <CR> <CR>")
    end
})
vim.api.nvim_create_autocmd("BufReadPost", {
    group = "CustomAutoCmds",
    pattern = "quickfix",
    callback = function()
        vim.cmd("nnoremap <buffer> <CR> <CR>")
    end
})
