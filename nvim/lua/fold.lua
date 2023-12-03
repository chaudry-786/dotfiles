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

function Foldtext()
    local text = vim.treesitter.foldtext()
    local n_lines = vim.v.foldend - vim.v.foldstart
    local text_lines = " lines"
    if n_lines == 1 then
        text_lines = " line"
    end
    table.insert(text, { " + " .. n_lines .. text_lines, { "Folded" } })
    return text
end

vim.opt.foldtext = "v:lua.Foldtext()"

-- non-treesitter methods for some files
vim.api.nvim_create_autocmd("FileType",
    { group = "CustomAutoCmds", pattern = "sql", command = [[ setlocal foldmethod=indent ]] })

--------------------------------------------------
-- Keymaps
--------------------------------------------------
--fold movement
keymap("", "[z", "zk", opts)
keymap("", "]z", "zj", opts)
keymap("n", "<CR>", "zA", opts)
-- close current, go to next and open.
keymap("n", "<C-CR>", "zCzjzOzz", opts)

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
