local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local kmap_funs = require("keymaping_functions")

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Global variable
function map(mode, lhs, rhs, desc_or_opts, expr_mapping)
    local mapping_opts
    if type(desc_or_opts) == "table" then
        mapping_opts = desc_or_opts
    else
        -- Description passed, add it to default opts
        mapping_opts = vim.tbl_extend("force", opts, { desc = desc_or_opts })
    end
    if expr_mapping then mapping_opts.expr = true end
    --  ----------------ANALYSIS PIECE----------------
    --  NOTE: String type mappings are not yet tracked. too many issues
    local original_rhs = rhs
    local wrapped_rhs
    if type(original_rhs) == "function" then
        -- Wrap the function to log the keypress
        wrapped_rhs = function()
            -- Log key press asynchronously.
            vim.defer_fn(function()
                kmap_funs.log_keypress(lhs, mapping_opts.desc or "No description")
            end, 1)
            if expr_mapping then
                return original_rhs()
            end
            original_rhs()
        end
    else
        wrapped_rhs = original_rhs
    end
    keymap(mode, lhs, wrapped_rhs, mapping_opts)

    -- Write mapping to File
    local rhs_type = (type(rhs) == "string") and "string" or "function"
    kmap_funs.write_mapping_to_file(mode, lhs, mapping_opts.desc, rhs_type)
end

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end

-- Just track function, purely for tracking mappings.
function e_map(mode, lhs, rhs, desc)
    map(mode, lhs, function() return rhs end, desc, true)
end
----------------------------------------
-- General
----------------------------------------
e_map({ "n", "v" }, "d", [["_d]], "Delete without copying.")
e_map({ "n", "v" }, "D", [["_D]], "Delete to end of line without copying.")
e_map({ "n", "v" }, "c", [["_c]], "Change without copying.")
e_map({ "n", "v" }, "C", [["_C]], "Change to end of line without copying.")
e_map("", "L", "$", "Move to the end of the line")
map("", "H", kmap_funs.goto_start_of_line, "Move to the start of the line")
e_map("t", "<Esc>", [[<C-\><C-n>]], "Exit terminal mode")
e_map("n", "<leader>y", ":%y+<CR>", "Copy the whole buffer")
e_map("n", "<esc>", "<Cmd>noh<return><esc>", "Escape: Also clears highlighting")
if not vim.g.vscode then
    map("n", "<leader>tc", [[:lua ToggleConceallevel()<CR>]], "Toggle conceal level")
    map("n", "<leader>?", ":! tmux neww ~/dotfiles/scripts/chtfzf.sh -t <CR>", "Fuzzy help for anything")
end

e_map("v", ">", ">gv", "Indent and stay in Visual mode")
e_map("v", "<", "<gv", "Indent and stay in Visual mode")
map("n", "<leader>ts", kmap_funs.toggle_spelling, "Toggle spelling")

-- DON'T RELY ON HJKL
map("", "hh", kmap_funs.do_nothing, "DO NOT USE HJKL")
map("", "jj", kmap_funs.do_nothing, "DO NOT USE HJKL")
map("", "kk", kmap_funs.do_nothing, "DO NOT USE HJKL")
map("", "ll", kmap_funs.do_nothing, "DO NOT USE HJKL")

----------------------------------------
-- Buffers and save
----------------------------------------
if not vim.g.vscode then
    map("n", "<leader>l", ":bnext<CR>", "Switch to the next buffer")
    map("n", "<leader>h", ":bprevious<CR>", "Switch to the previous buffer")
    map("n", "<leader>q", ":quit<CR>", "Quit Vim")
    map("n", "<leader><leader>q", ":qall<CR>", "Quit all windows")
    map("i", "<C-S>", "<C-O>:update<CR>", "Insert mode: Save and stay")
    map("n", "<C-S>", ":update<CR>", "Normal mode: Save")
    map("v", "<C-S>", "<C-C>:update<CR>", "Visual mode: Save")
else
    map("n", "<leader>l", kmap_funs.vscode_right_tab, "Switch to the next buffer")
    map("n", "<leader>h", kmap_funs.vscode_left_tab, "Switch to the previous buffer")
    map("n", "<leader>q", kmap_funs.vscode_quit, "Quit Vim")
    map("n", "<leader><leader>q", kmap_funs.vscode_quit_all, "Quit all windows")
end

----------------------------------------
-- Windows
----------------------------------------
if not vim.g.vscode then
    map("n", "<leader>|", ":vsplit<CR>", "Vertical split window")
    map("n", "<leader>-", ":split<CR>", "Horizontal split window")
    map("n", "<leader>>", "<c-w><c-r>", "Rotate window right")
    map("n", "<leader><", "<c-w><c-r>", "Rotate window left")
else
    map("n", "<leader>|", kmap_funs.vscode_vsplit, "Vertical split window")
    map("n", "<leader>-", kmap_funs.vscode_hsplit, "Horizontal split window")
end

----------------------------------------
-- Move code alt-arrows
----------------------------------------
if not vim.g.vscode then
    map("n", "<M-Up>", [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], "Move code up")
    map("n", "<M-Down>", [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], "Move code down")
    map("i", "<M-Up>", [[<C-O>m`<C-O>:move -2<CR><C-O>``]], "Insert mode: Move code up")
    map("i", "<M-Down>", [[<C-O>m`<C-O>:move +1<CR><C-O>``]], "Insert mode: Move code down")
    map("v", "<M-Up>", [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], "Visual mode: Move code up")
    map("v", "<M-Down>", [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], "Visual mode: Move code down")
end

----------------------------------------
-- Smart jump, stay in the middle and don't
-- jump on * and # (only highlight)
----------------------------------------
if not vim.g.vscode then
    e_map("n", "<C-o>", "<C-o>zz", "Keep jumps and search in the middle (Ctrl+O)")
    e_map("n", "<C-i>", "<C-i>zz", "Keep jumps and search in the middle (Ctrl+I)")
end
map("n", "n", kmap_funs.smart_n, "Keep jumps and search in the middle, go one way (up or down)", true)
map("n", "N", kmap_funs.smart_N, "Keep jumps and search in the middle, go one way (up or down)", true)
e_map("n", "*", ":keepjumps normal! mi*`i<CR>", "Highlight occurrences of word under cursor (forward)")
e_map("n", "#", ":keepjumps normal! mi#`i<CR>", "Highlight occurrences of word under cursor (backward)")

----------------------------------------
-- Very magic mode.
----------------------------------------
e_map("n", "/", [[/\v]], { noremap = true, desc = "Enable very magic for forward search" })
e_map("n", "?", [[?\v]], { noremap = true, desc = "Enable very magic for backward search" })
-- no vscode
map("c", "/", kmap_funs.enable_very_magic, { noremap = true, desc = "Enable very magic in command mode" }, true)

----------------------------------------
-- Quickfix list
----------------------------------------
map("n", "<leader>tq", kmap_funs.toggle_quickfix, "Toggle quickfix window")
e_map("n", "[q", ":cprevious<CR>zz", "Jump to previous quickfix entry")
e_map("n", "]q", ":cnext<CR>zz", "Jump to next quickfix entry")
e_map("n", "[Q", ":cfirst<CR>zz", "Jump to first quickfix entry")
e_map("n", "]Q", ":clast<CR>zz", "Jump to last quickfix entry")

----------------------------------------
-- Paste
----------------------------------------
map("n", "<leader>p", kmap_funs.paste_on_below_line, "Paste text on a new line, maintaining indent", true)
map("n", "<leader>P", kmap_funs.paste_on_above_line, "Paste text on a new line above, maintaining indent", true)
map("v", "p", kmap_funs.better_paste_visual, "Paste text on a new line above, maintaining indent", true)
-- if new line at the end, paste below, also maintain indent and delete extra line
kmap_funs.betterPasteNormal('')
