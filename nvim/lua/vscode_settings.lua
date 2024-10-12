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
vim.cmd([[nnoremap <silent> <leader>rn :call VSCodeNotify('editor.action.rename')<CR>]])
vim.cmd([[nnoremap <silent> gr :call VSCodeNotify('editor.action.goToReferences')<CR>]])
vim.cmd([[nnoremap <silent> gD :call VSCodeNotify('editor.action.revealDefinitionAside')<CR>]])
vim.cmd([[xnoremap <leader><leader>f :call VSCodeNotify('editor.action.formatSelection')<CR>]])
keymap("n", "<leader><leader>f", function()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        vim.cmd(":call VSCodeNotify('notebook.formatCell')")
    else
        vim.cmd(":call VSCodeNotify('editor.action.formatDocument')")
    end
end, opts)
vim.cmd("nnoremap <silent> ]a :call VSCodeNotify('editor.action.marker.next')<CR>")
vim.cmd("nnoremap <silent> [a :call VSCodeNotify('editor.action.marker.prev')<CR>")

------------------------------------------------------------------------------
-- Jupyter notebook
------------------------------------------------------------------------------
vim.cmd("nnoremap <silent> <leader>rc :call VSCodeNotify('notebook.cell.execute')<CR>")
vim.cmd("nnoremap <silent> <leader>rC :call VSCodeNotify('notebook.cell.executeCellsAbove')<CR>")
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
vim.cmd("nnoremap <silent> [C :call VSCodeNotify('notebook.focusTop')<CR>")
vim.cmd("nnoremap <silent> ]C :call VSCodeNotify('notebook.focusBottom')<CR>")
vim.cmd("nnoremap <silent> <leader>co :call VSCodeNotify('notebook.cell.insertCodeCellBelowAndFocusContainer')<CR>")
vim.cmd("nnoremap <silent> <leader>cO :call VSCodeNotify('notebook.cell.insertCodeCellAboveAndFocusContainer')<CR>")
vim.cmd("nnoremap <silent> <leader>cj :call VSCodeNotify('notebook.cell.joinBelow')<CR>")
vim.cmd("nnoremap <silent> <leader>cJ :call VSCodeNotify('notebook.cell.joinAbove')<CR>")
vim.cmd("nnoremap <silent> <leader>cs :call VSCodeNotify('notebook.cell.split')<CR>")
vim.cmd("nnoremap <silent> <leader>cc :call VSCodeNotify('notebook.cell.clearOutputs')<CR>")
vim.cmd("nnoremap <silent> <leader>cC :call VSCodeNotify('notebook.clearAllCellsOutputs')<CR>")
vim.cmd("nnoremap <silent> <leader>cx :call VSCodeNotify('notebook.cell.cancelExecution')<CR>")
vim.cmd("nnoremap <silent> <leader>cd :call VSCodeNotify('notebook.cell.delete')<CR>")
vim.cmd("nnoremap <silent> <leader>cm :call VSCodeNotify('notebook.cell.changeToMarkdown')<CR>")
vim.cmd("nnoremap <silent> <leader>cM :call VSCodeNotify('notebook.cell.changeToCode')<CR>")

------------------------------------------------------------------------------
-- Telescope
------------------------------------------------------------------------------
vim.cmd("nnoremap <silent> <leader>ff :call VSCodeNotify('workbench.action.quickOpen')<CR>")
vim.cmd("nnoremap <silent> <leader>fc :call VSCodeNotify('workbench.action.showCommands')<CR>")
keymap("n", "<leader>fg", function()
    Vscode.call('workbench.action.terminal.focus')
    Vscode.call('workbench.action.terminal.sendSequence',
        { args = { text = "export TERM_PROGRAM=vscode && clear" .. "\x0D" } })
    Vscode.call('workbench.action.terminal.sendSequence', { args = { text = "\x07" .. "\x0D" } })
end, opts)

vim.cmd("nnoremap <silent> <leader>fo :call VSCodeNotify('workbench.action.gotoSymbol')<CR>")
vim.cmd("nnoremap <silent> <leader>ov :call VSCodeNotify('dataWrangler.openNotebookVariable')<CR>")

------------------------------------------------------------------------------
-- Folds
------------------------------------------------------------------------------
vim.cmd("nnoremap <silent> zc :call VSCodeNotify('editor.fold')<CR>")
vim.cmd("nnoremap <silent> zC :call VSCodeNotify('editor.foldRecursively')<CR>")
vim.cmd("nnoremap <silent> zo :call VSCodeNotify('editor.unfold')<CR>")
vim.cmd("nnoremap <silent> zO :call VSCodeNotify('editor.unfoldRecursively')<CR>")
vim.cmd("nnoremap <silent> za :call VSCodeNotify('editor.toggleFold')<CR>")

local fold_table = {}
keymap("n", "zM", function()
    local filename = vim.fn.expand('%:p') .. ":"
    for key, _ in pairs(fold_table) do
        if string.sub(key, 1, string.len(filename)) == filename then
            fold_table[key] = nil
        end
    end
    vim.cmd("call VSCodeNotify('editor.foldAll')")
end, opts)
keymap("n", "zR", function()
    local filename = vim.fn.expand('%:p')
    local total_lines = vim.fn.line("$") -- Get the total number of lines in the file

    for line = 1, total_lines do
        local key = filename .. ":" .. line
        fold_table[key] = "unfolded_recursively"
    end

    vim.cmd("call VSCodeNotify('editor.unfoldAll')")
end, opts)

-- Recursivly fold and unfold
vim.cmd("nnoremap <silent> <CR> :call VSCodeNotify('editor.toggleFoldRecursively')<CR>")

vim.cmd("nnoremap <silent> [z :call VSCodeNotify('editor.gotoPreviousFold')<CR>")
vim.cmd("nnoremap <silent> ]z :call VSCodeNotify('editor.gotoNextFold')<CR>")

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
vim.cmd("nnoremap <silent> <leader>tb :call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>")
vim.cmd("nnoremap <silent> <leader>tB :call VSCodeNotify('workbench.debug.viewlet.action.removeAllBreakpoints')<CR>")
vim.cmd("nnoremap <silent> <leader>dc :call VSCodeNotify('editor.debug.action.conditionalBreakpoint')<CR>")
vim.cmd("nnoremap <silent> <leader><Down> :call VSCodeNotify('workbench.action.debug.continue')<CR>")
vim.cmd("nnoremap <silent> <leader>dw :call VSCodeNotify('editor.debug.action.selectionToWatch')<CR>")
vim.cmd("nnoremap <silent> <leader>dh :call VSCodeNotify('editor.debug.action.showDebugHover')<CR>")
vim.cmd("nnoremap <silent> <leader>dr :call VSCodeNotify('editor.debug.action.selectionToRepl')<CR>")
vim.cmd([[nnoremap <silent> [b :call VSCodeNotify('editor.debug.action.goToPreviousBreakpoint')<CR>]])
vim.cmd("nnoremap <silent> ]b :call VSCodeNotify('editor.debug.action.goToNextBreakpoint')<CR>>")

function set_debug_mapings()
    vim.cmd("nnoremap <silent> <Left> :call VSCodeNotify('workbench.action.debug.stepOut')<CR>")
    vim.cmd("nnoremap <silent> <Down> :call VSCodeNotify('workbench.action.debug.stepOver')<CR>")
    vim.cmd("nnoremap <silent> <Right> :call VSCodeNotify('workbench.action.debug.stepInto')<CR>")
    vim.cmd("nnoremap <silent> <Up> :call VSCodeNotify('workbench.action.debug.restart')<CR>")
end

-- Start debugger
function debug_start()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        vim.cmd(":call VSCodeNotify('jupyter.runAndDebugCell')")
    elseif filename:match('^test_.*%.py$') or filename:match('.*_test%.py$') then
        vim.cmd(":call VSCodeNotify('testing.debugAtCursor')")
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
vim.cmd("nnoremap <silent> <leader>rt :call VSCodeNotify('testing.runAtCursor')<CR>")
vim.cmd("nnoremap <silent> <leader>rl :call VSCodeNotify('testing.reRunLastRun')<CR>")
function run_tests()
    local filetype_and_commands = {
        py = "src; pytest . --disable-warnings -s",
    }
    local filename = vim.fn.expand("%:p")
    if string.match(filename, "^vscode%-remote") then
        filename = string.match(filename, "/home.*")
    end
    local file_extension = vim.fn.expand("%:e")
    local command = filetype_and_commands[file_extension]

    if command then
        Vscode.call('workbench.action.terminal.focus')
        Vscode.call('workbench.action.terminal.sendSequence', { args = { text = "clear" .. "\x0D" } })
        Vscode.call('workbench.action.terminal.sendSequence', { args = { text = command .. "\x0D" } })
    else
        Vscode.notify("Unsupported file type: " .. file_extension)
    end
end
vim.api.nvim_set_keymap('n', '<leader>rT', ':lua run_tests()<CR>',
    opts)
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
vim.cmd("nnoremap <silent> ]h :call VSCodeNotify('workbench.action.editor.previousChange')<CR>")
vim.cmd("nnoremap <silent> [h :call VSCodeNotify('workbench.action.editor.nextChange')<CR>")
vim.cmd("nnoremap <silent> <leader>ghp :call VSCodeNotify('editor.action.dirtydiff.next')<CR>")
vim.cmd("nnoremap <silent> <leader>ghu :call VSCodeNotify('git.revertSelectedRanges')<CR>")
vim.cmd("nnoremap <silent> <leader>gha :call VSCodeNotify('git.stageSelectedRanges')<CR>")
vim.cmd("nnoremap <silent> <leader>ga :call VSCodeNotify('git.stage')<CR>")

------------------------------------------------------------------------------
-- Snippets
------------------------------------------------------------------------------
-- snippet auto expension
keymap("i", "<c-l>", function()
    local cursor_col = vim.fn.col(".")
    local current_word = vim.fn.getline("."):sub(1, cursor_col):match("%w+$")
    local original_line_number = vim.fn.line(".")
    local original_line_content = vim.fn.getline(original_line_number)

    -- Call the VSCode command to insert the snippet
    Vscode.call("editor.action.insertSnippet", {
        args = {
            langId = vim.bo.filetype,
            name = current_word
        }
    })

    -- Remove the trigger word if line content changed
    vim.defer_fn(function()
        local new_line_content = vim.fn.getline(original_line_number)
        if new_line_content ~= original_line_content then
            local updated_line = new_line_content:gsub(current_word, "", 1)
            vim.fn.setline(original_line_number, updated_line)
        end
    end, 100)
end, opts)


------------------------------------------------------------------------------
-- Autocommands
------------------------------------------------------------------------------
-- Automatically fold files
vim.api.nvim_create_autocmd("BufReadPost", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        if not debug_mode then
            vim.defer_fn(function()
                Vscode.action('editor.foldAll')
            end, 500)
        end
    end
})
