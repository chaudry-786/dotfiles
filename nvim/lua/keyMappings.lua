local keymap = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }
local opts = { noremap = true, silent = true }
local kmap_funs = require("keymaping_functions")

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function define_keymaps(mappings)
    for _, mapping in ipairs(mappings) do
        local mapping_opts = type(mapping[4]) == "table" and mapping[4] or
            vim.tbl_extend("force", opts, { desc = mapping[4] })
        if mapping[5] then mapping_opts.expr = true end
        keymap(mapping[1], mapping[2], mapping[3], mapping_opts)
    end
end

local mappings = {
    ----------------------------------------
    -- General
    ----------------------------------------
    { { "n", "v" }, "d",          [["_d]],                      "Delete without copying." },
    { { "n", "v" }, "D",          [["_D]],                      "Delete to end of line without copying." },
    { { "n", "v" }, "c",          [["_c]],                      "Change without copying." },
    { { "n", "v" }, "C",          [["_C]],                      "Change to end of line without copying." },
    { "",           "L",          "$",                          "Move to the end of the line" },
    { "",           "H",          kmap_funs.goto_start_of_line, "Move to the start of the line", },
    { "t",          "<Esc>",      [[<C-\><C-n>]],               "Exit terminal mode" },
    { "n",          "@",          kmap_funs.execute_macro,      "Execute macro with noautocmd" },
    { "n",          "<leader>y",  ":%y+<CR>",                   "Copy the whole buffer", },
    { "n",          "<esc>",      "<Cmd>noh<return><esc>",      "Escape: Also clears highlighting", },
    { "v",          ">",          ">gv",                        "Indent and stay in Visual mode", },
    { "v",          "<",          "<gv",                        "Indent and stay in Visual mode", },
    { "n",          "<leader>ts", kmap_funs.toggle_spelling,    "Toggle spelling" },
    { "n", "<leader>tc",
        [[:lua ToggleConceallevel()<CR>]], "Toggle conceal level" },
    { "n", "<leader>?",
        ":! tmux neww ~/dotfiles/scripts/chtfzf.sh -t <CR>", "Fuzzy help for anything", },

    ----------------------------------------
    -- Buffers
    ----------------------------------------
    { "n", "<leader>l",         ":bnext<CR>",         "Switch to the next buffer" },
    { "n", "<leader>h",         ":bprevious<CR>",     "Switch to the previous buffer" },
    { "i", "<C-S>",             "<C-O>:update<CR>",   "Insert mode: Save and stay" },
    { "n", "<C-S>",             ":update<CR>",        "Normal mode: Save" },
    { "v", "<C-S>",             "<C-C>:update<CR>",   "Visual mode: Save" },
    { "n", "<leader>q",         ":quit<CR>",          "Quit Vim" },
    { "n", "<leader><leader>q", ":qall<CR>",          "Quit all windows" },

    ----------------------------------------
    -- Windows
    ----------------------------------------
    { "n", "<leader>|",         ":vsplit<CR>",        "Vertical split window" },
    { "n", "<leader>-",         ":split<CR>",         "Horizontal split window" },
    { "n", "<leader>>",         "<c-w><c-r>",         "Rotate window right" },
    { "n", "<leader><",         "<c-w><c-r>",         "Rotate window left" },

    ----------------------------------------
    -- Quick file edit
    ----------------------------------------
    { "n", "<leader>ev",        ":edit $MYVIMRC<CR>", "Edit vimrc file" },
    { "n", "<leader>ez",        ":edit ~/.zshrc<CR>", "Edit zshrc file" },
    { "n", "<leader>ec",        ":CocConfig<CR>",     "Edit Coc configuration" },
    { "n", "<leader>es",
        ":CocCommand snippets.editSnippets<CR>", "Edit Coc snippets" },

    ----------------------------------------
    -- Move code alt-arrows
    ----------------------------------------
    { "n", "<M-Up>",
        [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], "Move code up" },
    { "n", "<M-Down>",
        [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], "Move code down" },
    { "i", "<M-Up>",
        [[<C-O>m`<C-O>:move -2<CR><C-O>``]], "Insert mode: Move code up" },
    { "i", "<M-Down>",
        [[<C-O>m`<C-O>:move +1<CR><C-O>``]], "Insert mode: Move code down" },
    { "v", "<M-Up>",
        [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], "Visual mode: Move code up" },
    { "v", "<M-Down>",
        [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], "Visual mode: Move code down" },

    ----------------------------------------
    -- Smart jump and stay in the middle.
    ----------------------------------------
    { "n", "<C-o>", "<C-o>zz", "Keep jumps and search in the middle (Ctrl+O)", },
    { "n", "<C-i>", "<C-i>zz", "Keep jumps and search in the middle (Ctrl+I)", },
    { "n", "n", kmap_funs.smart_n,
        "Keep jumps and search in the middle, go one way (up or down)", true,
    },
    { "n", "N", kmap_funs.smart_N,
        "Keep jumps and search in the middle, go one way (up or down)", true,
    },

    ----------------------------------------
    -- Very magic mode.
    ----------------------------------------
    { "n", "/", [[/\v]], { noremap = true, desc = "Enable very magic for forward search" } },
    { "n", "?", [[?\v]], { noremap = true, desc = "Enable very magic for backward search" }, },
    { "c", "/",
        kmap_funs.enable_very_magic, { noremap = true, desc = "Enable very magic in command mode" }, true },

    ----------------------------------------
    -- Quickfix list
    ----------------------------------------
    { "n", "<leader>tq", kmap_funs.toggle_quickfix, "Toggle quickfix window" },
    { "n", "[q",         ":cprevious<CR>zz",        "Jump to previous quickfix entry" },
    { "n", "]q",         ":cnext<CR>zz",            "Jump to next quickfix entry" },
    { "n", "[Q",         ":cfirst<CR>zz",           "Jump to first quickfix entry" },
    { "n", "]Q",         ":clast<CR>zz",            "Jump to last quickfix entry" },

    ----------------------------------------
    -- Paste
    ----------------------------------------
    { "n", "<leader>p",
        [[match(getreg(), "\n$") == -1 ? "o<C-r><C-p>+<esc>" : "o<C-r><C-p>+<esc>\"_dd"]],
        "Paste text on a new line, maintaining indent", true
    },
    { "n", "<leader>P",
        [[match(getreg(), "\n$") == -1 ? "O<C-r><C-p>+<esc>" : "O<C-r><C-p>+<esc>\"_dd"]],
        "Paste text on a new line above, maintaining indent", true
    },
    { "v", "p",
        kmap_funs.better_paste_visual,
        "Paste text on a new line above, maintaining indent", true
    },
}
define_keymaps(mappings)

local function betterPasteNormal(register)
    local cmd
    local pre_cursor = (register == "") and "" or '"'
    if not register or register == "" then
        cmd = [[match(getreg(), "\n$") == -1 ? "p" : "o<C-r><C-p>+<esc>\"_ddk"]]
    else
        cmd = string.format(
            [[match(getreg('%s'), "\n$") == -1 ? "\"%sp" : "o<C-r><C-p>%s<esc>\"_ddk"]],
            register, register, register)
    end
    keymap("n", pre_cursor .. register .. "p", cmd, expr_opts)
end

-- if new line at the end, paste below, also maintain indent and delete extra line
-- for all registers
for reg in ("abcdefghijklmnopqrstuvwxyz"):gmatch('.') do
    betterPasteNormal(reg)
end
betterPasteNormal('')
