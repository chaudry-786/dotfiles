local keymap = map

vim.cmd("highlight YankHighlight guibg=#5b737e blend=50")
vim.opt.spell = false

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

------------------------------------------------------------------------------
--- LSP
------------------------------------------------------------------------------
keymap("n", "<leader>rn", ":call VSCodeNotify('editor.action.rename')<CR>", "Refactor: rename")
keymap("n", "gr", ":call VSCodeNotify('editor.action.goToReferences')<CR>", "Go to references")
keymap("n", "gD", ":call VSCodeNotify('editor.action.revealDefinitionAside')<CR>", "Reveal definition aside")
keymap("v", "<leader><leader>f", ":call VSCodeNotify('editor.action.formatSelection')<CR>", "Format selection")
keymap("n", "<leader><leader>f", function()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        vim.cmd(":call VSCodeNotify('notebook.formatCell')")
    else
        vim.cmd(":call VSCodeNotify('editor.action.formatDocument')")
    end
end, "Format document/cell.")
keymap("n", "]d", ":call VSCodeNotify('editor.action.marker.nextInFiles')<CR>", "Jump to next error/warning in files")
keymap("n", "[d", ":call VSCodeNotify('editor.action.marker.prevInFiles')<CR>", "Jump to previous error/warning in files")
keymap({"n", "v"}, "<leader>R", function()
    Vscode.call("editor.action.refactor")
end, "Refactor: show available refactoring options.")

------------------------------------------------------------------------------
-- Jupyter notebook
------------------------------------------------------------------------------
keymap("n", "<leader>rc", ":call VSCodeNotify('notebook.cell.execute')<CR>", "Notebook: execute the current cell")
keymap("n", "<leader>rC", ":call VSCodeNotify('notebook.cell.executeCellsAbove')<CR>", "Notebook: execute all cells above the current one")
-- BUG: when action origins from markdown cell then center is not executed
keymap("n", "[c", function()
    Vscode.call("notebook.focusPreviousEditor")
    os.execute("sleep " .. tonumber(0.1))
    Vscode.call("notebook.centerActiveCell")
end, "Notebook: focus previous cell and center it")

keymap("n", "]c", function()
    Vscode.call("notebook.focusNextEditor")
    os.execute("sleep " .. tonumber(0.1))
    Vscode.call("notebook.centerActiveCell")
end, "Notebook: focus next cell and center it")
keymap("n", "[C", ":call VSCodeNotify('notebook.focusTop')<CR>", "Notebook: focus on the top cell")
keymap("n", "]C", ":call VSCodeNotify('notebook.focusBottom')<CR>", "Notebook: focus on the bottom cell")
keymap("n", "<leader>co", ":call VSCodeNotify('notebook.cell.insertCodeCellBelowAndFocusContainer')<CR>", "Notebook: insert a code cell below and focus it")
keymap("n", "<leader>cO", ":call VSCodeNotify('notebook.cell.insertCodeCellAboveAndFocusContainer')<CR>", "Notebook: insert a code cell above and focus it")
keymap("n", "<leader>cj", ":call VSCodeNotify('notebook.cell.joinBelow')<CR>", "Notebook: join the current cell with the cell below")
keymap("n", "<leader>cJ", ":call VSCodeNotify('notebook.cell.joinAbove')<CR>", "Notebook: join the current cell with the cell above")
keymap("n", "<leader>cs", ":call VSCodeNotify('notebook.cell.split')<CR>", "Notebook: split the current cell")
keymap("n", "<leader>cc", ":call VSCodeNotify('notebook.cell.clearOutputs')<CR>", "Notebook: clear outputs of the current cell")
keymap("n", "<leader>cC", ":call VSCodeNotify('notebook.clearAllCellsOutputs')<CR>", "Notebook: clear outputs of all cells")
keymap("n", "<leader>cx", ":call VSCodeNotify('notebook.cell.cancelExecution')<CR>", "Notebook: cancel the execution of the current cell")
keymap("n", "<leader>cd", ":call VSCodeNotify('notebook.cell.delete')<CR>", "Notebook: delete the current cell")
keymap("n", "<leader>cm", ":call VSCodeNotify('notebook.cell.changeToMarkdown')<CR>", "Notebook: change the current cell to Markdown")
keymap("n", "<leader>cM", ":call VSCodeNotify('notebook.cell.changeToCode')<CR>", "Notebook: change the current cell to Code")

------------------------------------------------------------------------------
-- Telescope
------------------------------------------------------------------------------
keymap("n", "<leader>ff", ":call VSCodeNotify('workbench.action.quickOpen')<CR>", "Quick Open: open the file navigator")
keymap("n", "<leader>fb", ":call VSCodeNotify('workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup')<CR>", "Quick Open: open the previously used editor")
keymap("n", "<leader>fc", ":call VSCodeNotify('workbench.action.showCommands')<CR>", "Command Palette: show available commands")
keymap("n", "<leader>fg", ":call VSCodeNotify('workbench.action.findInFiles')<CR>", "Find: search across files")
keymap("n", "<leader>fo", function()
    Vscode.call('workbench.action.quickOpen', { args = { ":@" } })
end, "Quick Open: navigate to a recent file")
keymap("n", "<leader>fO", function()
    Vscode.call('workbench.action.quickOpen', { args = { "#" } })
end, "Quick Open: navigate to a recent symbol")
keymap("n", "<leader>ov", ":call VSCodeNotify('dataWrangler.openNotebookVariable')<CR>", "Notebook: open the variable viewer in Data Wrangler")

------------------------------------------------------------------------------
-- Folds
------------------------------------------------------------------------------
keymap("n", "zc", ":call VSCodeNotify('editor.fold')<CR>", "Fold: fold the current code block")
keymap("n", "zC", ":call VSCodeNotify('editor.foldRecursively')<CR>", "Fold: fold all code blocks recursively")
keymap("n", "zo", ":call VSCodeNotify('editor.unfold')<CR>", "Unfold: unfold the current code block")
keymap("n", "zO", ":call VSCodeNotify('editor.unfoldRecursively')<CR>", "Unfold: unfold all code blocks recursively")
keymap("n", "za", ":call VSCodeNotify('editor.toggleFold')<CR>", "Toggle Fold: toggle the folding state of the current code block")

local fold_table = {}

-- Function to fold at a specific level
local function set_fold_level(level)
    if level < 1 or level > 7 then
        print("Fold level must be between 1 and 7.")
        return
    end
    local fold_command = string.format("editor.foldLevel%d", level)
    Vscode.call(fold_command)
end

keymap("n", "zM", ":call VSCodeNotify('editor.foldAll')<CR>", "Fully close all folds (fold level 1)")
keymap("n", "zR", ":call VSCodeNotify('editor.unfoldAll')<CR>", "Fully open all folds (fold level 7)")
-- BUG: not working
keymap("n", "zm", function()
    local filename = vim.fn.expand('%:p')
    -- Get the current fold level, default to 7 if not set
    local current_level = fold_table[filename] or 7
    current_level = math.max(1, current_level - 1)
    fold_table[filename] = current_level
    set_fold_level(current_level)
end, "Close more folds by decreasing the current fold level")
keymap("n", "zr", function()
    local filename = vim.fn.expand('%:p')
    -- Get the current fold level, default to 1 if not set
    local current_level = fold_table[filename] or 1
    current_level = math.min(7, current_level + 1)
    fold_table[filename] = current_level
    set_fold_level(current_level)
end, "Open more folds by increasing the current fold level")

-- Recursivly fold and unfold
keymap("n", "<CR>", ":call VSCodeNotify('editor.toggleFoldRecursively')<CR>", "Fold: toggle fold recursively")
keymap("n", "[z", ":call VSCodeNotify('editor.gotoPreviousFold')<CR>", "Fold: go to previous fold")
keymap("n", "]z", ":call VSCodeNotify('editor.gotoNextFold')<CR>", "Fold: go to next fold")

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
keymap("n", "<leader>tb", ":call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>", "Debug: Toggle breakpoint")
keymap("n", "<leader>tB", ":call VSCodeNotify('workbench.debug.viewlet.action.removeAllBreakpoints')<CR>", "Debug: Remove all breakpoints")
keymap("n", "<leader>dc", ":call VSCodeNotify('editor.debug.action.conditionalBreakpoint')<CR>", "Debug: Set conditional breakpoint")
keymap("n", "<leader><Down>", ":call VSCodeNotify('workbench.action.debug.continue')<CR>", "Debug: Continue execution")
keymap("n", "<leader>dw", ":call VSCodeNotify('editor.debug.action.selectionToWatch')<CR>", "Debug: Add selection to watch")
keymap("n", "<leader>dh", ":call VSCodeNotify('editor.debug.action.showDebugHover')<CR>", "Debug: Show debug hover information")
keymap("n", "<leader>dr", ":call VSCodeNotify('editor.debug.action.selectionToRepl')<CR>", "Debug: Send selection to REPL")
keymap("n", "[b", ":call VSCodeNotify('editor.debug.action.goToPreviousBreakpoint')<CR>", "Debug: Go to previous breakpoint")
keymap("n", "]b", ":call VSCodeNotify('editor.debug.action.goToNextBreakpoint')<CR>", "Debug: Go to next breakpoint")

local function set_debug_mapings()
    keymap("n", "<Left>", ":call VSCodeNotify('workbench.action.debug.stepOut')<CR>", { silent = true, desc = "Debug Step Out" })
    keymap("n", "<Down>", ":call VSCodeNotify('workbench.action.debug.stepOver')<CR>", { silent = true, desc = "Debug Step Over" })
    keymap("n", "<Right>", ":call VSCodeNotify('workbench.action.debug.stepInto')<CR>", { silent = true, desc = "Debug Step Into" })
    keymap("n", "<Up>", ":call VSCodeNotify('workbench.action.debug.restart')<CR>", { silent = true, desc = "Debug Restart" })
end

-- Start debugger
local function debug_start()
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
end, "Debugger start")

-- End debugger
local function debug_end()
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
end, "Debugger end")

keymap("n", "<Leader>td", function()
    if debug_mode then
        debug_end()
    else
        debug_start()
    end
end, "Toggle debugger")


------------------------------------------------------------------------------
-- Run file
------------------------------------------------------------------------------
local function run_file()
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

keymap('n', '<leader>rf', run_file,
    "Run file in terminal")

------------------------------------------------------------------------------
-- Tests
------------------------------------------------------------------------------
keymap("n", "<leader>rt", ":call VSCodeNotify('testing.runAtCursor')<CR>", "Testing: Run test at cursor")
keymap("n", "<leader>rl", ":call VSCodeNotify('testing.reRunLastRun')<CR>", "Testing: Re-run last test")
local function run_tests()
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

keymap("n", "<leader>rT", run_tests, "Testing: Run all tests")
keymap("n", "<Leader>dt", function()
    set_debug_mapings()
    Vscode.action("testing.debugAtCursor")
    debug_mode = true
end, "Debug test at cusor.")
keymap("n", "<Leader>dl", function()
    set_debug_mapings()
    Vscode.action("testing.debugLastRun")
    debug_mode = true
end, "Debug last run test.")

------------------------------------------------------------------------------
-- Git
------------------------------------------------------------------------------
keymap("n", "[h", ":call VSCodeNotify('workbench.action.editor.previousChange')<CR>", "Navigate: previous change")
keymap("n", "]h", ":call VSCodeNotify('workbench.action.editor.nextChange')<CR>", "Navigate: next change")
keymap("n", "<leader>ghp", ":call VSCodeNotify('editor.action.dirtydiff.next')<CR>", "Git: go to next dirty diff")
keymap("n", "<leader>ghu", ":call VSCodeNotify('git.revertSelectedRanges')<CR>", "Git: revert selected changes")
keymap({ "v", "n" }, "<Leader>gha", function()
    Vscode.action("git.stageSelectedRanges")
    os.execute("sleep 0.2")
end, "Git: stage the currently selected lines or ranges.")
keymap("n", "<leader>ga", ":call VSCodeNotify('git.stage')<CR>", "Git: stage changes for the current file.")
keymap("n", "<leader>gb", ":call VSCodeNotify('gitlens.toggleLineBlame')<CR>", "GitLens: toggle blame information for the current line.")
keymap("n", "<leader>gB", ":call VSCodeNotify('gitlens.toggleFileBlame')<CR>", "GitLens: toggle blame information for the entire file.")
keymap("n", "<leader>gc", ":call VSCodeNotify('git.clean')<CR>", "Git: clean untracked files from the working directory.")
keymap("n", "<leader>gr", ":call VSCodeNotify('git.unstage')<CR>", "Git: unstage changes from the current file.")
keymap("n", "<leader>gd", ":call VSCodeNotify('git.openChange')<CR>", "Git: open a diff for the changes in the current file.")
keymap("n", "<leader>gD", ":call VSCodeNotify('merge-conflict.compare')<CR>", "Merge Conflict: compare changes between branches.")

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
end, "Insert Snippet: Trigger snippet insertion based on the current word at the cursor.")

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
end, "Toggle Fold Mode: Enable or disable fold mode and notify the user.")
