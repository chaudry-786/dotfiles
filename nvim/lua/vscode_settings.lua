local keymap = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }

vim.cmd("highlight YankHighlight guibg=#5b737e blend=50")
vim.opt.spell = false

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

------------------------------------------------------------------------------
--- LSP
------------------------------------------------------------------------------
vim.cmd([[nnoremap <leader>rn :call VSCodeNotify('editor.action.rename')<CR>]])
vim.cmd([[nnoremap gr :call VSCodeNotify('editor.action.goToReferences')<CR>]])
vim.cmd([[xnoremap <leader><leader>f :call VSCodeNotify('editor.action.formatSelection')<CR>]])
vim.cmd([[nnoremap <leader><leader>f :call VSCodeNotify('editor.action.formatDocument')<CR>]])
vim.cmd("nnoremap ]a :call VSCodeNotify('editor.action.marker.next')<CR>")
vim.cmd("nnoremap [a :call VSCodeNotify('editor.action.marker.prev')<CR>")

------------------------------------------------------------------------------
-- Jupyter notebook
------------------------------------------------------------------------------
vim.cmd("nnoremap <leader>rc :call VSCodeNotify('notebook.cell.execute')<CR>")
vim.cmd("nnoremap <leader>rC :call VSCodeNotify('notebook.cell.executeCellsAbove')<CR>")
-- BUG: when action origins from markdown cell then center is not executed
keymap("n", "[c", function()
    Vscode.call("notebook.focusPreviousEditor")
    os.execute("sleep " .. tonumber(0.1))
    Vscode.call("notebook.centerActiveCell")
end, opts)
keymap("n", "]c", function()
    Vscode.call("notebook.focusNextEditor")
    os.execute("sleep " .. tonumber(0.1))
    Vscode.call("notebook.centerActiveCell")
end, opts)
vim.cmd("nnoremap [C :call VSCodeNotify('notebook.focusTop')<CR>")
vim.cmd("nnoremap ]C :call VSCodeNotify('notebook.focusBottom')<CR>")
vim.cmd("nnoremap <leader>co :call VSCodeNotify('notebook.cell.insertCodeCellBelowAndFocusContainer')<CR>")
vim.cmd("nnoremap <leader>cO :call VSCodeNotify('notebook.cell.insertCodeCellAboveAndFocusContainer')<CR>")
vim.cmd("nnoremap <leader>cj :call VSCodeNotify('notebook.cell.joinBelow')<CR>")
vim.cmd("nnoremap <leader>cJ :call VSCodeNotify('notebook.cell.joinAbove')<CR>")
vim.cmd("nnoremap <leader>cs :call VSCodeNotify('notebook.cell.split')<CR>")
vim.cmd("nnoremap <leader>cc :call VSCodeNotify('notebook.cell.clearOutputs')<CR>")
vim.cmd("nnoremap <leader>cC :call VSCodeNotify('notebook.clearAllCellsOutputs')<CR>")
vim.cmd("nnoremap <leader>cx :call VSCodeNotify('notebook.cell.cancelExecution')<CR>")
vim.cmd("nnoremap <leader>cd :call VSCodeNotify('notebook.cell.delete')<CR>")
vim.cmd("nnoremap <leader>cm :call VSCodeNotify('notebook.cell.changeToMarkdown')<CR>")
vim.cmd("nnoremap <leader>cM :call VSCodeNotify('notebook.cell.changeToCode')<CR>")

------------------------------------------------------------------------------
-- Telescope
------------------------------------------------------------------------------
vim.cmd("nnoremap <leader>ff :call VSCodeNotify('workbench.action.quickOpen')<CR>")
vim.cmd("nnoremap <leader>fc :call VSCodeNotify('workbench.action.showCommands')<CR>")
keymap("n", "<leader>fg", function()
    Vscode.call('workbench.action.terminal.focus')
    Vscode.call('workbench.action.terminal.sendSequence', { args = { text = "export TERM_PROGRAM=vscode && clear" .. "\x0D" } })
    Vscode.call('workbench.action.terminal.sendSequence', { args = { text = "\x07" .. "\x0D" } })
end, opts)

vim.cmd("nnoremap <leader>fo :call VSCodeNotify('workbench.action.gotoSymbol')<CR>")
vim.cmd("nnoremap <leader>ov :call VSCodeNotify('dataWrangler.openNotebookVariable')<CR>")

------------------------------------------------------------------------------
-- Folds
------------------------------------------------------------------------------
vim.cmd("nnoremap zM :call VSCodeNotify('editor.foldAll')<CR>")
vim.cmd("nnoremap zR :call VSCodeNotify('editor.unfoldAll')<CR>")
vim.cmd("nnoremap zc :call VSCodeNotify('editor.fold')<CR>")
vim.cmd("nnoremap zC :call VSCodeNotify('editor.foldRecursively')<CR>")
vim.cmd("nnoremap zo :call VSCodeNotify('editor.unfold')<CR>")
vim.cmd("nnoremap zO :call VSCodeNotify('editor.unfoldRecursively')<CR>")
vim.cmd("nnoremap za :call VSCodeNotify('editor.toggleFold')<CR>")

local fold_table = {}
keymap("n", "<CR>", function()
    local filename = vim.fn.expand('%:p')
    local current_line = vim.fn.line(".")

    local key = filename .. ":" .. current_line
    if not fold_table[key] then
        -- Fold the line
        vim.cmd("call VSCodeNotify('editor.foldRecursively')")
        fold_table[key] = "folded"
    elseif fold_table[key] == "folded" then
        -- Unfold the line
        vim.cmd("call VSCodeNotify('editor.unfold')")
        fold_table[key] = "unfolded"
    else
        -- Unfold the line recursively
        vim.cmd("call VSCodeNotify('editor.unfoldRecursively')")
        fold_table[key] = nil
    end
end, opts)


vim.cmd("nnoremap [z :call VSCodeNotify('editor.gotoPreviousFold')<CR>")
vim.cmd("nnoremap ]z :call VSCodeNotify('editor.gotoNextFold')<CR>")

vim.cmd([[
function! MoveCursor(direction) abort
    if(reg_recording() == '' && reg_executing() == '')
        return 'g'.a:direction
    else
        return a:direction
    endif
endfunction

nmap <expr> j MoveCursor('j')
nmap <expr> k MoveCursor('k')
]])


------------------------------------------------------------------------------
-- Debuger
------------------------------------------------------------------------------
local debug_mode = false
vim.cmd("nnoremap <leader>tb :call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>")
vim.cmd("nnoremap <leader>tB :call VSCodeNotify('workbench.debug.viewlet.action.removeAllBreakpoints')<CR>")
vim.cmd("nnoremap <leader>dc :call VSCodeNotify('editor.debug.action.conditionalBreakpoint')<CR>")
vim.cmd("nnoremap <leader><Down> :call VSCodeNotify('workbench.action.debug.continue')<CR>")
vim.cmd("nnoremap <leader>dw :call VSCodeNotify('editor.debug.action.selectionToWatch')<CR>")
vim.cmd("nnoremap <leader>dh :call VSCodeNotify('editor.debug.action.showDebugHover')<CR>")
vim.cmd("nnoremap <leader>dr :call VSCodeNotify('editor.debug.action.selectionToRepl')<CR>")
vim.cmd([[nnoremap [b :call VSCodeNotify('editor.debug.action.goToPreviousBreakpoint')<CR>]])
vim.cmd("nnoremap ]b :call VSCodeNotify('editor.debug.action.goToNextBreakpoint')<CR>>")

function set_debug_mapings()
    vim.cmd("nnoremap <Left> :call VSCodeNotify('workbench.action.debug.stepOut')<CR>")
    vim.cmd("nnoremap <Down> :call VSCodeNotify('workbench.action.debug.stepOver')<CR>")
    vim.cmd("nnoremap <Right> :call VSCodeNotify('workbench.action.debug.stepInto')<CR>")
    vim.cmd("nnoremap <Up> :call VSCodeNotify('workbench.action.debug.restart')<CR>")
end

-- Start debugger
function debug_start()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        vim.cmd(":call VSCodeNotify('jupyter.runAndDebugCell')")
    else
        vim.cmd(":call VSCodeNotify('workbench.action.debug.start')")
    end
    set_debug_mapings()
    debug_mode = true
end

keymap("n", "<Leader>ds", function()
    debug_start()
end, opts)

-- End debugger
function debug_end()
    Vscode.call("workbench.action.debug.stop")
    Vscode.call("workbench.action.closeSidebar")
    vim.cmd("unmap <Left>")
    vim.cmd("unmap <Down>")
    vim.cmd("unmap <Right>")
    vim.cmd("unmap <Up>")
    debug_mode = false
end
keymap("n", "<Leader>de", function()
    debug_end()
end, opts)

keymap("n", "<Leader>td", function()
    if debug_mode then
        debug_end()
    else
        debug_start()
    end
end, opts)


------------------------------------------------------------------------------
-- Run file
------------------------------------------------------------------------------
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
    if string.match(filename, "^vscode%-remote") then
        filename = string.match(filename, "/home.*")
    end
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

------------------------------------------------------------------------------
-- Tests
------------------------------------------------------------------------------
vim.cmd("nnoremap <leader>rt :call VSCodeNotify('testing.runAtCursor')<CR>")
vim.cmd("nnoremap <leader>rl :call VSCodeNotify('testing.reRunLastRun')<CR>")
vim.cmd("nnoremap <leader>rT :call VSCodeNotify('testing.runAll')<CR>")
keymap("n", "<Leader>dt", function()
    set_debug_mapings()
    Vscode.action("testing.debugAtCursor")
    debug_mode = true
end, opts)
keymap("n", "<Leader>dl", function()
    set_debug_mapings()
    Vscode.action("testing.debugLastRun")
    debug_mode = true
end, opts)

------------------------------------------------------------------------------
-- Git
------------------------------------------------------------------------------
vim.cmd("nnoremap ]h :call VSCodeNotify('workbench.action.editor.previousChange')<CR>")
vim.cmd("nnoremap [h :call VSCodeNotify('workbench.action.editor.nextChange')<CR>")
vim.cmd("nnoremap <leader>ghp :call VSCodeNotify('editor.action.dirtydiff.next')<CR>")
vim.cmd("nnoremap <leader>ghu :call VSCodeNotify('git.revertSelectedRanges')<CR>")
vim.cmd("nnoremap <leader>gha :call VSCodeNotify('git.stageSelectedRanges')<CR>")
vim.cmd("nnoremap <leader>ga :call VSCodeNotify('git.stage')<CR>")
