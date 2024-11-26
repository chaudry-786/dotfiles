local keymap = map
vim = vim

vim.cmd("highlight YankHighlight guibg=#5b737e blend=50")
vim.opt.spell = false

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

-- Wrap vscode command
local function v_c(command_name, args)
    return function()
        if args then
            Vscode.call(command_name, args)
        else
            Vscode.call(command_name)
        end
    end
end

------------------------------------------------------------------------------
--- General
------------------------------------------------------------------------------
-- swap windows
keymap("n", "<leader>>", v_c("workbench.action.moveActiveEditorGroupRight"), "Rotate window right")
keymap("n", "<leader><", v_c("workbench.action.moveActiveEditorGroupLeft"), "Rotate window left")

------------------------------------------------------------------------------
--- LSP
------------------------------------------------------------------------------
keymap("n", "<leader>rn", v_c("editor.action.rename"), "Refactor: rename")
keymap("n", "gd", v_c("editor.action.revealDefinition"), "Go to definition")
keymap("n", "gD", v_c("editor.action.revealDefinitionAside"), "Reveal definition aside")
keymap("n", "gr", v_c("editor.action.goToReferences"), "Go to references")

local function add_tripel_quotes(original_visual_text)
    local cursor_pos = vim.fn.getpos(".")
    local o_pos = vim.fn.getpos("v")
    local visual_text = table.concat(vim.fn.getregion(o_pos, cursor_pos), "\n")

    if visual_text == original_visual_text then
        Vscode.notify("Text not changed, not doing anything.")
        return
    end

    local start_pos
    local end_pos

    -- Combine line and col number to find true start position
    if (cursor_pos[2] + cursor_pos[3]) < (o_pos[2] + o_pos[3]) then
        start_pos = o_pos
        end_pos = cursor_pos
    else
        start_pos = cursor_pos
        end_pos = o_pos
    end

    local start_line = vim.fn.getline(start_pos[2])
    local preceeding_text = string.sub(start_line, start_pos[3] - 3, start_pos[3] - 1)
    -- Workout how many quotes to add
    local quote_starting_pos = string.find(preceeding_text, [["+$]])
    local quotest_to_add
    if quote_starting_pos == nil then
        -- If double quote doesn't exist, then return
        return
        -- quotest_to_add = string.rep([["]], 3)
    else
        quotest_to_add = string.rep([["]], quote_starting_pos - 1)
    end
    local line_to_udpate = start_line:gsub('()', { [start_pos[3]] = quotest_to_add })
    vim.fn.setline(start_pos[2], line_to_udpate)

    -- End quotes
    local end_line = vim.fn.getline(end_pos[2])
    local after_text = string.sub(end_line, end_pos[3] + 1, end_pos[3] + 4)
    -- Workout how many quotes to add
    local quote_starting_pos = string.find(after_text, [[^"+]])
    if quote_starting_pos == nil then
        -- If double quote doesn't exist, then return
        return
        -- quotest_to_add = string.rep([["]], 3)
    else
        quotest_to_add = string.rep([["]], 3 - quote_starting_pos)
    end
    local line_to_udpate = end_line:gsub('()', { [end_pos[3] + 1] = quotest_to_add })
    vim.fn.setline(end_pos[2], line_to_udpate)
end

keymap("v", "<leader><leader>f", function()
    -- Apply default visual format or SQL specific if 'select' is found in query
    if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
        local visual_text = table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos(".")), "\n")
        if string.find(string.lower(visual_text), "select") then
            Vscode.call("prettier-sql-vscode.format-selection")
            vim.defer_fn(function()
                add_tripel_quotes(visual_text)
            end, 100)
        end
    end
    Vscode.call("editor.action.formatSelection")
end, "Format document/cell.")

keymap("n", "<leader><leader>f", function()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        Vscode.call('notebook.formatCell')
    else
        Vscode.call("editor.action.formatDocument")
    end
end, "Format document/cell.")
keymap("n", "]d", v_c("editor.action.marker.nextInFiles"), "Jump to next error/warning in files")
keymap("n", "[d", v_c("editor.action.marker.prevInFiles"), "Jump to previous error/warning in files")
keymap({ "n", "v" }, "<leader>R", v_c("editor.action.refactor"), "Refactor: show available refactoring options.")

------------------------------------------------------------------------------
-- Jupyter notebook
------------------------------------------------------------------------------
keymap("n", "<leader>rc", v_c("notebook.cell.execute"), "Notebook: execute the current cell")
keymap("n", "<leader>rC", v_c("notebook.cell.executeCellsAbove"), "Notebook: execute all cells above the current one")
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
keymap("n", "[C", v_c("notebook.focusTop"), "Notebook: focus on the top cell")
keymap("n", "]C", v_c("notebook.focusBottom"), "Notebook: focus on the bottom cell")
keymap("n", "<leader>co", v_c("notebook.cell.insertCodeCellBelowAndFocusContainer"),
    "Notebook: insert a code cell below and focus it")
keymap("n", "<leader>cO", v_c("notebook.cell.insertCodeCellAboveAndFocusContainer"),
    "Notebook: insert a code cell above and focus it")
keymap("n", "<leader>cj", v_c("notebook.cell.joinBelow"), "Notebook: join the current cell with the cell below")
keymap("n", "<leader>cJ", v_c("notebook.cell.joinAbove"), "Notebook: join the current cell with the cell above")
keymap("n", "<leader>cs", v_c("notebook.cell.split"), "Notebook: split the current cell")
keymap("n", "<leader>cc", v_c("notebook.cell.clearOutputs"), "Notebook: clear outputs of the current cell")
keymap("n", "<leader>cC", v_c("notebook.clearAllCellsOutputs"), "Notebook: clear outputs of all cells")
keymap("n", "<leader>cx", v_c("notebook.cell.cancelExecution"), "Notebook: cancel the execution of the current cell")
keymap("n", "<leader>cd", v_c("notebook.cell.delete"), "Notebook: delete the current cell")
keymap("n", "<leader>cm", v_c("notebook.cell.changeToMarkdown"), "Notebook: change the current cell to Markdown")
keymap("n", "<leader>cM", v_c("notebook.cell.changeToCode"), "Notebook: change the current cell to Code")

------------------------------------------------------------------------------
-- Telescope
------------------------------------------------------------------------------
keymap("n", "<leader>ff", v_c("workbench.action.quickOpen"), "Quick Open: open the file navigator")
keymap("n", "<leader>fb", v_c("workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup"),
    "Quick Open: open the previously used editor")
keymap("n", "<leader>fc", v_c("workbench.action.showCommands"), "Command Palette: show available commands")
-- Grep/Replace
keymap("n", "<leader>fG",
    v_c("editor.actions.findWithArgs", { args = { searchString = "hi", isRegex = true, replaceString = "" } }),
    "Find: search across current buffer")
keymap("v", "<leader>fG",
    v_c("editor.actions.findWithArgs",
        { args = { searchString = "", isRegex = true, findInSelection = true, replaceString = "" }, }),
    "Find: search across current buffer")
keymap("n", "<leader>fg", v_c("workbench.action.findInFiles", { args = { query = "", isRegex = true } }),
    "Find: search across files")
keymap("v", "<leader>fg",
    v_c("workbench.action.findInFiles", { args = { searchString = "${selectedText}", isRegex = true } }),
    "Find: search selection across files")
keymap("n", "<leader>fo", v_c("workbench.action.quickOpen", { args = { "@:" } }),
    "Quick Open: navigate to symbols in the current file")
keymap("n", "<leader>fO", v_c("workbench.action.quickOpen", { args = { "#" } }),
    "Quick Open: navigate to symbols in the entire project")
keymap("n", "<leader>ov", v_c("dataWrangler.openNotebookVariable"), "Notebook: open the variable viewer in Data Wrangler")

------------------------------------------------------------------------------
-- Folds
------------------------------------------------------------------------------
keymap("n", "zc", v_c("editor.fold"), "Fold: fold the current code block")
keymap("n", "zC", v_c("editor.foldRecursively"), "Fold: fold all code blocks recursively")
keymap("n", "zo", v_c("editor.unfold"), "Unfold: unfold the current code block")
keymap("n", "zO", v_c("editor.unfoldRecursively"), "Unfold: unfold all code blocks recursively")
keymap("n", "za", v_c("editor.toggleFold"), "Toggle Fold: toggle the folding state of the current code block")
keymap("n", "zA", v_c("editor.toggleFoldRecursively"), "Fold: toggle fold recursively")
keymap("n", "<CR>", v_c("editor.toggleFoldRecursively"), "Fold: toggle fold recursively")

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

keymap("n", "zM", v_c("editor.foldAll"), "Fully close all folds (fold level 1)")
keymap("n", "zR", v_c("editor.unfoldAll"), "Fully open all folds (fold level 7)")
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

keymap("n", "[z", v_c("editor.gotoPreviousFold"), "Fold: go to previous fold")
keymap("n", "]z", v_c("editor.gotoNextFold"), "Fold: go to next fold")

------------------------------------------------------------------------------
-- Debuger
------------------------------------------------------------------------------
local debug_mode = false
keymap("n", "<leader>tb", v_c("editor.debug.action.toggleBreakpoint"), "Debug: Toggle breakpoint")
keymap("n", "<leader>tB", v_c("workbench.debug.viewlet.action.removeAllBreakpoints"), "Debug: Remove all breakpoints")
keymap("n", "<leader>dc", v_c("editor.debug.action.conditionalBreakpoint"), "Debug: Set conditional breakpoint")
keymap("n", "<leader><Down>", v_c("workbench.action.debug.continue"), "Debug: Continue execution")
keymap("n", "<leader>dw", v_c("editor.debug.action.selectionToWatch"), "Debug: Add selection to watch")
keymap("n", "<leader>dh", v_c("editor.debug.action.showDebugHover"), "Debug: Show debug hover information")
keymap("n", "<leader>dr", v_c("editor.debug.action.selectionToRepl"), "Debug: Send selection to REPL")
keymap("n", "[b", v_c("editor.debug.action.goToPreviousBreakpoint"), "Debug: Go to previous breakpoint")
keymap("n", "]b", v_c("editor.debug.action.goToNextBreakpoint"), "Debug: Go to next breakpoint")

local function set_debug_mapings()
    keymap("n", "<Left>", v_c("workbench.action.debug.stepOut"), "Debug Step Out")
    keymap("n", "<Down>", v_c("workbench.action.debug.stepOver"), "Debug Step Over")
    keymap("n", "<Right>", v_c("workbench.action.debug.stepInto"), "Debug Step Into")
    keymap("n", "<Up>", v_c("workbench.action.debug.restart"), "Debug Restart")
end

-- Start debugger
local function debug_start()
    local filename = vim.fn.expand('%:t')
    if filename:match('%.ipynb[#%%]') then
        Vscode.call('jupyter.runAndDebugCell')
    elseif filename:match('^test_.*%.py$') or filename:match('.*_test%.py$') then
        -- Async call
        Vscode.action('testing.debugAtCursor')
    elseif filename:match('%.rs$') then
        Vscode.call('rust-analyzer.debug')
    else
        Vscode.call('workbench.action.debug.start')
    end
    set_debug_mapings()
    debug_mode = true
end

keymap("n", "<leader>ds", function()
    debug_start()
end, "Debugger start")

-- End debugger
local function debug_end()
    Vscode.call("workbench.action.debug.stop")
    Vscode.call("workbench.action.closeSidebar")
    vim.cmd("map <Left> <Nop>")
    vim.cmd("map <Down> <Nop>")
    vim.cmd("map <Right> <Nop>")
    vim.cmd("map <Up> <Nop>")
    debug_mode = false
end
-- Disable arrow keys
debug_end()

keymap("n", "<leader>de", function()
    debug_end()
end, "Debugger end")

keymap("n", "<leader>td", function()
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
        py = "src; python %s",
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
-- Other mappings in vim-test
keymap("n", "<leader><leader>rt", v_c("testing.runAtCursor"), "Testing: Run test at cursor")
keymap("n", "<leader><leader>rl", v_c("testing.reRunLastRun"), "Testing: Re-run last test")
keymap("n", "<leader>dt", function()
    set_debug_mapings()
    Vscode.action("testing.debugAtCursor")
    debug_mode = true
end, "Debug test at cusor.")
keymap("n", "<leader>dl", function()
    set_debug_mapings()
    Vscode.action("testing.debugLastRun")
    debug_mode = true
end, "Debug last run test.")

------------------------------------------------------------------------------
-- Git
------------------------------------------------------------------------------
keymap("n", "[h", v_c("workbench.action.editor.previousChange"), "Navigate: previous change")
keymap("n", "]h", v_c("workbench.action.editor.nextChange"), "Navigate: next change")
keymap("n", "<leader>ghp", v_c("editor.action.dirtydiff.next"), "Git: go to next dirty diff")
keymap("n", "<leader>ghu", v_c("git.revertSelectedRanges"), "Git: revert selected changes")
keymap({ "v", "n" }, "<leader>gha", function()
    Vscode.action("git.stageSelectedRanges")
    os.execute("sleep 0.2")
end, "Git: stage the currently selected lines or ranges.")
keymap("n", "<leader>ga", v_c("git.stage"), "Git: stage changes for the current file.")
keymap("n", "<leader>gb", v_c("gitlens.toggleLineBlame"), "GitLens: toggle blame information for the current line.")
keymap("n", "<leader>gB", v_c("gitlens.toggleFileBlame"), "GitLens: toggle blame information for the entire file.")
keymap("n", "<leader>gc", v_c("git.clean"), "Git: clean untracked files from the working directory.")
keymap("n", "<leader>gr", v_c("git.unstage"), "Git: unstage changes from the current file.")
keymap("n", "<leader>gd", v_c("git.openChange"), "Git: open a diff for the changes in the current file.")
keymap("n", "<leader>gD", v_c("merge-conflict.compare"), "Merge Conflict: compare changes between branches.")

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
