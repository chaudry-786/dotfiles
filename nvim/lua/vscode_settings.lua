local keymap = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }

vim.cmd("highlight YankHighlight guibg=#5b737e blend=50")
vim.opt.spell = false

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

--  symbol renaming.
keymap("n", "<leader>rn", function()
    Vscode.call("editor.action.rename")
end, {})

-- formatting
keymap("x", "<leader><leader>f", function()
    Vscode.call("editor.action.formatSelection")
end, {})
keymap("n", "<leader><leader>f", function()
    Vscode.call("editor.action.formatDocument")
end, opts)

-- -- navigate diagnostics
keymap("n", "]a", function()
    Vscode.call("editor.action.marker.next")
end, { silent = true })
keymap("n", "[a", function()
    Vscode.call("editor.action.marker.prev")
end, { silent = true })

keymap("i", "<c-j>",
    function()
        Vscode.call("selectNextSuggestion")
    end,
    opts)

keymap("n", "<leader>rc",
    function()
        Vscode.call("jupyter.runcurrentcell")
        print("another hello")
    end,
    opts)

keymap("n", "<leader>rC",
    function()
        Vscode.call("jupyter.runallcellsabove.palette")
        print("another hello")
    end,
    opts)
keymap("n", "[c",
    function()
        Vscode.call("notebook.focusPreviousEditor")
        Vscode.call("notebook.centerActiveCell")
    end,
    opts)

keymap("n", "]c",
    function()
        Vscode.call("notebook.focusNextEditor")
        Vscode.call("notebook.centerActiveCell")
    end,
    opts)


-- Telescope
keymap("n", "<leader>ff", function()
    Vscode.call("workbench.action.quickOpen")
end, { silent = true })
keymap("n", "<leader>fc", function()
    Vscode.call("workbench.action.showCommands")
end, { silent = true })

-- Folds
vim.cmd("nnoremap zM :call VSCodeNotify('editor.foldAll')<CR>")
vim.cmd("nnoremap zR :call VSCodeNotify('editor.unfoldAll')<CR>")
vim.cmd("nnoremap zc :call VSCodeNotify('editor.fold')<CR>")
vim.cmd("nnoremap zC :call VSCodeNotify('editor.foldRecursively')<CR>")
vim.cmd("nnoremap zo :call VSCodeNotify('editor.unfold')<CR>")
vim.cmd("nnoremap zO :call VSCodeNotify('editor.unfoldRecursively')<CR>")
vim.cmd("nnoremap za :call VSCodeNotify('editor.toggleFold')<CR>")
vim.cmd("nnoremap <CR> :call VSCodeNotify('editor.toggleFold')<CR>")

vim.cmd("nnoremap [z :call VSCodeNotify('editor.gotoPreviousFold')<CR>")
vim.cmd("nnoremap ]z :call VSCodeNotify('editor.gotoNextFold')<CR>")

local smart_fold_movement = [[
function! MoveCursor(direction) abort
    if(reg_recording() == '' && reg_executing() == '')
        return 'g'.a:direction
    else
        return a:direction
    endif
endfunction

nmap <expr> j MoveCursor('j')
nmap <expr> k MoveCursor('k')
]]

vim.cmd(smart_fold_movement)
