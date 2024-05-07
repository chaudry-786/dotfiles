local keymap = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }
local kmap_funs = require("keymaping_functions")

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(mode, rhs, lhs, desc_or_opts, expr_mapping)
    local mapping_opts = type(desc_or_opts) == "table" and desc_or_opts or
        vim.tbl_extend("force", opts, { desc = desc_or_opts })
    if expr_mapping then mapping_opts.expr = true end
    keymap(mode, rhs, lhs, mapping_opts)
end

if vim.g.vscode then
    Vscode = require("vscode-neovim")
end
----------------------------------------
-- General
----------------------------------------
map({ "n", "v" }, "d", [["_d]], "Delete without copying.")
map({ "n", "v" }, "D", [["_D]], "Delete to end of line without copying.")
map({ "n", "v" }, "c", [["_c]], "Change without copying.")
map({ "n", "v" }, "C", [["_C]], "Change to end of line without copying.")
map("", "L", "$", "Move to the end of the line")
map("", "H", kmap_funs.goto_start_of_line, "Move to the start of the line")
map("t", "<Esc>", [[<C-\><C-n>]], "Exit terminal mode")
map("n", "@", kmap_funs.execute_macro, "Execute macro with noautocmd")
map("n", "<leader>y", ":%y+<CR>", "Copy the whole buffer")
map("n", "<esc>", "<Cmd>noh<return><esc>", "Escape: Also clears highlighting")
if not vim.g.vscode then
    map("n", "<leader>tc", [[:lua ToggleConceallevel()<CR>]], "Toggle conceal level")
    map("n", "<leader>?", ":! tmux neww ~/dotfiles/scripts/chtfzf.sh -t <CR>", "Fuzzy help for anything")
end

map("v", ">", ">gv", "Indent and stay in Visual mode")
map("v", "<", "<gv", "Indent and stay in Visual mode")
map("n", "<leader>ts", kmap_funs.toggle_spelling, "Toggle spelling")

----------------------------------------
-- Buffers
----------------------------------------
if not vim.g.vscode then
    map("n", "<leader>l", ":bnext<CR>", "Switch to the next buffer")
    map("n", "<leader>h", ":bprevious<CR>", "Switch to the previous buffer")
    map("n", "<leader>q", ":quit<CR>", "Quit Vim")
    map("n", "<leader><leader>q", ":qall<CR>", "Quit all windows")
else
    map("n", "<leader>l", kmap_funs.vscode_right_tab, "Switch to the next buffer")
    map("n", "<leader>h", kmap_funs.vscode_left_tab, "Switch to the previous buffer")
    map("n", "<leader>q", kmap_funs.vscode_quit, "Quit Vim")
    map("n", "<leader><leader>q", kmap_funs.vscode_quit_all, "Quit all windows")
end
map("i", "<C-S>", "<C-O>:update<CR>", "Insert mode: Save and stay")
map("n", "<C-S>", ":update<CR>", "Normal mode: Save")
map("v", "<C-S>", "<C-C>:update<CR>", "Visual mode: Save")

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
-- Quick file edit
----------------------------------------
map("n", "<leader>ev", ":edit $MYVIMRC<CR>", "Edit vimrc file")
map("n", "<leader>ez", ":edit ~/.zshrc<CR>", "Edit zshrc file")
map("n", "<leader>ec", ":CocConfig<CR>", "Edit Coc configuration")
map("n", "<leader>es", ":CocCommand snippets.editSnippets<CR>", "Edit Coc snippets")

----------------------------------------
-- Move code alt-arrows
----------------------------------------
map("n", "<M-Up>", [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], "Move code up")
map("n", "<M-Down>", [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], "Move code down")
map("i", "<M-Up>", [[<C-O>m`<C-O>:move -2<CR><C-O>``]], "Insert mode: Move code up")
map("i", "<M-Down>", [[<C-O>m`<C-O>:move +1<CR><C-O>``]], "Insert mode: Move code down")
map("v", "<M-Up>", [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], "Visual mode: Move code up")
map("v", "<M-Down>", [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], "Visual mode: Move code down")

----------------------------------------
-- Smart jump, stay in the middle and don't
-- jump on * and # (only highlight)
----------------------------------------
map("n", "<C-o>", "<C-o>zz", "Keep jumps and search in the middle (Ctrl+O)")
map("n", "<C-i>", "<C-i>zz", "Keep jumps and search in the middle (Ctrl+I)")
map("n", "n", kmap_funs.smart_n, "Keep jumps and search in the middle, go one way (up or down)", true)
map("n", "N", kmap_funs.smart_N, "Keep jumps and search in the middle, go one way (up or down)", true)
map("n", "*", ":keepjumps normal! mi*`i<CR>", "Highlight occurrences of word under cursor (forward)")
map("n", "#", ":keepjumps normal! mi#`i<CR>", "Highlight occurrences of word under cursor (backward)")

----------------------------------------
-- Very magic mode.
----------------------------------------
map("n", "/", [[/\v]], { noremap = true, desc = "Enable very magic for forward search" })
map("n", "?", [[?\v]], { noremap = true, desc = "Enable very magic for backward search" })
-- no vscode
map("c", "/", kmap_funs.enable_very_magic, { noremap = true, desc = "Enable very magic in command mode" }, true)

----------------------------------------
-- Quickfix list
----------------------------------------
map("n", "<leader>tq", kmap_funs.toggle_quickfix, "Toggle quickfix window")
map("n", "[q", ":cprevious<CR>zz", "Jump to previous quickfix entry")
map("n", "]q", ":cnext<CR>zz", "Jump to next quickfix entry")
map("n", "[Q", ":cfirst<CR>zz", "Jump to first quickfix entry")
map("n", "]Q", ":clast<CR>zz", "Jump to last quickfix entry")

----------------------------------------
-- Paste
----------------------------------------
map("n", "<leader>p", [[match(getreg(), "\n$") == -1 ? "o<C-r><C-p>+<esc>" : "o<C-r><C-p>+<esc>\"_dd"]],
    "Paste text on a new line, maintaining indent", true)
map("n", "<leader>P", [[match(getreg(), "\n$") == -1 ? "O<C-r><C-p>+<esc>" : "O<C-r><C-p>+<esc>\"_dd"]],
    "Paste text on a new line above, maintaining indent", true)
map("v", "p", kmap_funs.better_paste_visual, "Paste text on a new line above, maintaining indent", true)
-- if new line at the end, paste below, also maintain indent and delete extra line
-- for all registers
for reg in ("abcdefghijklmnopqrstuvwxyz"):gmatch('.') do
    kmap_funs.betterPasteNormal(reg)
end
kmap_funs.betterPasteNormal('')
