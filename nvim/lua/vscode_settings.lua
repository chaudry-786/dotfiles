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
        Vscode.call("notebook.cell.execute")
    end,
    opts)

keymap("n", "<leader>rC",
    function()
        Vscode.call("notebook.cell.executeCellsAbove")
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

keymap("n", "<leader>co",
    function()
        Vscode.call("notebook.cell.insertCodeCellBelowAndFocusContainer")
    end,
    opts)
keymap("n", "<leader>cO",
    function()
        Vscode.call("notebook.cell.insertCodeCellAboveAndFocusContainer")
    end,
    opts)

-- Telescope
keymap("n", "<leader>ff", function()
    Vscode.call("workbench.action.quickOpen")
end, opts)
keymap("n", "<leader>fc", function()
    Vscode.call("workbench.action.showCommands")
end, opts)

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

-- Debuger
vim.cmd("nnoremap <leader>tb :call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>")
vim.cmd("nnoremap <leader>tB :call VSCodeNotify('workbench.debug.viewlet.action.removeAllBreakpoints')<CR>")
vim.cmd("nnoremap <leader>dc :call VSCodeNotify('editor.debug.action.conditionalBreakpoint')<CR>")

-- Start debugger
local function set_mappings()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        vim.cmd("nnoremap <buffer> <leader>ds :call VSCodeNotify('jupyter.runAndDebugCell')<CR>")
    else
        vim.cmd("nnoremap <buffer> <leader>ds :call VSCodeNotify('workbench.action.debug.start')<CR>")
    end
    vim.cmd("nnoremap <Left> :call VSCodeNotify('workbench.action.debug.stepOut')<CR>")
    vim.cmd("nnoremap <Down> :call VSCodeNotify('workbench.action.debug.stepOver')<CR>")
    vim.cmd("nnoremap <Right> :call VSCodeNotify('workbench.action.debug.stepInto')<CR>")
    vim.cmd("nnoremap <Up> :call VSCodeNotify('workbench.action.debug.restart')<CR>")
end
vim.api.nvim_create_autocmd({ 'BufRead', }, {
    pattern = '*',
    callback = set_mappings,
})

-- End debugger
keymap("n", "<leader>de", function()
    Vscode.call("workbench.action.debug.stop")
    Vscode.call("workbench.action.closeSidebar")
    vim.cmd("unmap <Left>")
    vim.cmd("unmap <Down>")
    vim.cmd("unmap <Right>")
    vim.cmd("unmap <Up>")
end, opts)
vim.cmd("nnoremap <leader><Down> :call VSCodeNotify('workbench.action.debug.continue')<CR>")
vim.cmd("nnoremap <leader>dw :call VSCodeNotify('editor.debug.action.selectionToWatch')<CR>")
vim.cmd("nnoremap <leader>dh :call VSCodeNotify('editor.debug.action.showDebugHover')<CR>")
vim.cmd("nnoremap <leader>dr :call VSCodeNotify('editor.debug.action.selectionToRepl')<CR>")


-- Run file
function run_file()
    local filetype_and_commands = {
        py = "python %s",
        lua = "lua %s",
        js = "node %s",
        c = "gcc %s -o %s && ./%s",
        rs = "cargo run",
        sh = "sh %s"
    }
    local filename = vim.fn.expand("%:p")
    local file_extension = vim.fn.expand("%:e")
    local command_template = filetype_and_commands[file_extension]

    if command_template then
        local command
        if file_extension == "c" then
            local output_file = vim.fn.expand("%:t:r")
            command = string.format(command_template, filename, output_file, output_file)
        else
            command = string.format(command_template, filename)
        end
        Vscode.call('workbench.action.terminal.focus')
        Vscode.call('workbench.action.terminal.sendSequence', { args = { text = "clear" .. "\x0D" } })
        Vscode.call('workbench.action.terminal.sendSequence', { args = { text = command .. "\x0D" } })
    else
        Vscode.notify("Unsupported file type: " .. file_extension)
    end
end

vim.api.nvim_set_keymap('n', '<leader>rf', ':lua run_file()<CR>',
    opts)

-- Tests
vim.cmd("nnoremap <leader>rt :call VSCodeNotify('testing.runAtCursor')<CR>")
vim.cmd("nnoremap <leader>rT :call VSCodeNotify('testing.runAll')<CR>")
vim.cmd("nnoremap <leader>dt :call VSCodeNotify('testing.debugAtCursor')<CR>")
