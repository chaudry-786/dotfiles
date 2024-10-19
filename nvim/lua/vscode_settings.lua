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
vim.cmd("nnoremap <silent> ]d :call VSCodeNotify('editor.action.marker.nextInFiles')<CR>")
vim.cmd("nnoremap <silent> [d :call VSCodeNotify('editor.action.marker.prevInFiles')<CR>")
keymap({"n", "v"}, "<leader>R", function()
    Vscode.call("editor.action.refactor")
end, opts)
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
vim.cmd("nnoremap <silent> <leader>fb :call VSCodeNotify('workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup')<CR>")
vim.cmd("nnoremap <silent> <leader>fc :call VSCodeNotify('workbench.action.showCommands')<CR>")
vim.cmd("nnoremap <silent> <leader>fg :call VSCodeNotify('workbench.action.findInFiles')<CR>")
keymap("n", "<leader>fo", function() Vscode.call('workbench.action.quickOpen', { args = { "@:" } }) end, opts)
keymap("n", "<leader>fO", function() Vscode.call('workbench.action.quickOpen', { args = { "#" } }) end, opts)
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
    elseif filename:match('%.rs$') then
        vim.cmd(":call VSCodeNotify('rust-analyzer.debug')")
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
vim.cmd("nnoremap <silent> [h :call VSCodeNotify('workbench.action.editor.previousChange')<CR>")
vim.cmd("nnoremap <silent> ]h :call VSCodeNotify('workbench.action.editor.nextChange')<CR>")
vim.cmd("nnoremap <silent> <leader>ghp :call VSCodeNotify('editor.action.dirtydiff.next')<CR>")
vim.cmd("nnoremap <silent> <leader>ghu :call VSCodeNotify('git.revertSelectedRanges')<CR>")
-- vim.cmd("nnoremap <silent> <leader>gha :call VSCodeNotify('git.stageSelectedRanges')<CR>")
keymap({ "v", "n" }, "<Leader>gha", function()
    Vscode.action("git.stageSelectedRanges")
    os.execute("sleep 0.2")
end, opts)
vim.cmd("nnoremap <silent> <leader>ga :call VSCodeNotify('git.stage')<CR>")
vim.cmd("nnoremap <silent> <leader>gb :call VSCodeNotify('gitlens.toggleLineBlame')<CR>")
vim.cmd("nnoremap <silent> <leader>gB :call VSCodeNotify('gitlens.toggleFileBlame')<CR>")
vim.cmd("nnoremap <silent> <leader>gc :call VSCodeNotify('git.clean')<CR>")
vim.cmd("nnoremap <silent> <leader>gr :call VSCodeNotify('git.unstage')<CR>")
keymap("n", "<leader>gd", function()
    Vscode.action("workbench.action.editorLayoutSingle")
    os.execute("sleep 0.2")
    Vscode.action("git.openChange")
end, opts)
-- Merge conflict editor
keymap("n", "<leader>gD", function()
    Vscode.action("workbench.action.editorLayoutSingle")
    os.execute("sleep 0.2")
    Vscode.action("merge-conflict.compare")
end, opts)

------------------------------------------------------------------------------
-- Snippets
------------------------------------------------------------------------------
keymap("i", "<c-l>", function()
    local cursor_col = vim.fn.col(".")
    local original_line_number = vim.fn.line(".")
    local original_line_content = vim.fn.getline(original_line_number)
    local current_word = original_line_content:sub(1, cursor_col):match("[^%s]+$")

    -- Return early if current_word is empty or nil
    if not current_word or current_word == "" then return end

    -- Step 1: Remove the trigger word from the line before snippet insertion
    local updated_line = original_line_content:gsub(current_word, "", 1)
    vim.fn.setline(original_line_number, updated_line)

    -- Step 2: Try to insert the snippet using the VSCode command
    Vscode.call("editor.action.insertSnippet", {
        args = {
            langId = vim.bo.filetype,
            name = current_word
        }
    })

    -- Step 3: If snippet insertion failed, restore the trigger word
    local new_line_content = vim.fn.getline(original_line_number)
    -- If snippet insertion failed, restore the trigger word
    if new_line_content == original_line_content:gsub(current_word, "", 1) then
        vim.fn.setline(original_line_number, original_line_content)
        vim.fn.cursor(original_line_number, cursor_col)
    end
end, opts)

------------------------------------------------------------------------------
-- Autocommands
------------------------------------------------------------------------------
-- Automatically fold files
local fold_mode = false
vim.api.nvim_create_autocmd("BufReadPost", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        if fold_mode and not debug_mode then
            vim.defer_fn(function()
                Vscode.action('editor.foldAll')
            end, 500)
        end
    end
})
keymap("n", "<leader>tf", function()
    fold_mode = not fold_mode
    if fold_mode then
        Vscode.notify("Fold mode disabled.")
    else
        Vscode.notify("Fold mode enabled.")
    end
end, opts)
