local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- do not copy delete and change command
keymap({ "n", "v" }, "d", [["_d]], opts)
keymap({ "n", "v" }, "D", [["_D]], opts)
keymap({ "n", "v" }, "c", [["_c]], opts)
keymap({ "n", "v" }, "C", [["_C]], opts)

-- Friction points in nvim default paste behaviour which lead to this customization:
-- 1) Doesn't indent pasted text.
-- 2) In visual modes, it copies replaced text.
-- 3) In visual mode, adds a new line break at the start pasted text.
-- 4) Personal preference: in visual mode it should get rid of line
--      break at the end of pasted text. so it would replace
--      exactly the highlighted text.

-- better paste mappings
local function betterPasteVisual()
    -- <C-r><C-p>+ :pastes in insert mode and maintains indent
    local register_text = vim.fn.getreg()
    local has_newline = string.match(register_text, "\n$") ~= nil

    if has_newline and vim.fn.mode() == "v" then
        register_text = string.gsub(register_text, "\n$", "")
        vim.fn.setreg("z", register_text)
        return [["_d"zP]]
    elseif not has_newline and vim.fn.mode() == "V" then
        return [["_dO<C-r><C-p>+<esc>]]
    end

    return [["_di<C-r><C-p>+<esc>]]
end
keymap("v", "p", betterPasteVisual, expr_opts)

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

-- paste text on new line, if there is already line break do not insert a new one and maintain indent
keymap("n", "<leader>p", [[match(getreg(), "\n$") == -1 ? "o<C-r><C-p>+<esc>" : "o<C-r><C-p>+<esc>\"_dd"]], expr_opts)
keymap("n", "<leader>P", [[match(getreg(), "\n$") == -1 ? "O<C-r><C-p>+<esc>" : "O<C-r><C-p>+<esc>\"_dd"]], expr_opts)

-- move at the start and end of line easily
keymap("", "L", "$", opts)
-- Use 0 or ^ depending on current position.
keymap("", "H", function()
    local start_pos = vim.fn.col(".")
    if start_pos ~= 1 then
        vim.cmd("normal! ^")
        if start_pos <= vim.fn.col(".") then
            vim.cmd("normal! 0")
        end
    end
end, opts)

-- buffers shortcuts
keymap("n", "<leader>l", ":bnext<CR>", opts)
keymap("n", "<leader>h", ":bprevious<CR>", opts)
keymap("i", "<C-S>", "<C-O>:update<CR>", opts)
keymap("n", "<C-S>", ":update<CR>", opts)
keymap("v", "<C-S>", "<C-C>:update<CR>", opts)
keymap("n", "<leader>q", ":quit<CR>", opts)
keymap("n", "<leader><leader>q", ":qall<CR>", opts)

-- windows shortcuts
keymap("n", "<leader>|", ":vsplit<CR>", opts)
keymap("n", "<leader>-", ":split<CR>", opts)
keymap("n", "<leader>>", "<c-w><c-r>", opts)
keymap("n", "<leader><", "<c-w><c-r>", opts)

-- edit common files quickly
keymap("n", "<leader>ev", ":edit $MYVIMRC<cr>", opts)
keymap("n", "<leader>ez", ":edit ~/.zshrc<cr>", opts)
keymap("n", "<leader>es", ":CocCommand snippets.editSnippets<cr>", opts)
keymap("n", "<leader>ec", ":CocConfig<cr>", opts)

--  move code alt+arrows
keymap("n", "<M-Up>", [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], opts)
keymap("n", "<M-Down>", [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], opts)
keymap("i", "<M-Up>", [[<C-O>m`<C-O>:move -2<CR><C-O>``]], opts)
keymap("i", "<M-Down>", [[<C-O>m`<C-O>:move +1<CR><C-O>``]], opts)
keymap("v", "<M-Up>", [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], opts)
keymap("v", "<M-Down>", [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], opts)

-- keep jumps and search in middle also n and N are smart to go only one way
-- when search is going either way (up or down).
keymap("n", "n", function() return vim.v.searchforward == 1 and "nzz" or "Nzz" end, expr_opts)
keymap("n", "N", function() return vim.v.searchforward == 1 and "Nzz" or "nzz" end, expr_opts)
keymap("n", "<C-o>", "<C-o>zz", opts)
keymap("n", "<C-i>", "<C-i>zz", opts)

-- copy whole buffer
keymap("n", "<leader>y", ":%y+<CR>", opts)

-- escape: also clears highlighting
keymap("n", "<esc>", "<Cmd>noh<return><esc>", opts)

-- indent and stay in visualMode
keymap("v", ">", ">gv", opts)
keymap("v", "<", "<gv", opts)

-- fuzzy help for anything
keymap("n", "<leader>?", ":! tmux neww ~/dotfiles/scripts/chtfzf.sh -t <CR>", opts)

-- very magic mode enabled by default in command line
-- do not use silent in command mode, it delays rhs key input until the next key
keymap("n", "/", [[/\v]], { noremap = true })
keymap("n", "?", [[?\v]], { noremap = true })
local function enable_very_magic()
    local cmdline, cmdtype = vim.fn.getcmdline(), vim.fn.getcmdtype()
    if cmdtype ~= ":" then
        return "/"
    end
    -- list of valid command-line inputs that trigger very magic mode
    local valid_values = { "s", [['<,'>s]], "%s", "g", [['<,'>g]], "g!", [['<,'>g!]] }
    if vim.tbl_contains(valid_values, cmdline) then
        return "/\\v"
    elseif cmdline == "v" then
        return [[imgrep /\v/ **/*]] .. string.rep("<Left>", 6)
    elseif cmdline == "vext" then
        -- for "vext/" command, grep over current file extension
        local current_extension = vim.fn.expand("%:e")
        vim.fn.setcmdline("vimgrep /\\v/ **/*." .. current_extension, 12)
        return
    elseif string.match(cmdline, "^vext:") then
        -- for "vext:ext1,ext2,ext3/" command, grep over specified extensions
        local extensions = string.sub(cmdline, 6, -1) -- extract extensions from the command
        vim.fn.setcmdline("vimgrep /\\v/ **/*.{" .. extensions .. ",}", 12)
        return
    end
    return "/"
end
keymap("c", "/", enable_very_magic, { noremap = true, expr = true })

function ToggleQuickfixList()
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            vim.cmd "cclose"
            return
        end
    end
    vim.cmd "copen"
end

--quick fix list
keymap("n", "<leader>tq", ":lua ToggleQuickfixList()<CR>", opts)
keymap("n", "[q", ":cprevious<CR>zz", opts)
keymap("n", "]q", ":cnext<CR>zz", opts)
keymap("n", "[Q", ":cfirst<CR>zz", opts)
keymap("n", "]Q", ":clast<CR>zz", opts)

function ToggleSpellCheck()
    vim.opt.spell = not (vim.opt.spell:get())
end
keymap("n", "<leader>ts", ":lua ToggleSpellCheck()<CR>", opts)

-- by default set this to 2
vim.o.conceallevel = 2
function ToggleConceallevel()
    if vim.o.conceallevel == 2 then
        vim.o.conceallevel = 0
    else
        vim.o.conceallevel = 2
    end
end
keymap('n', '<leader>tc', [[:lua ToggleConceallevel()<CR>]], opts)

-- <Esc> to exit terminal-mode
keymap("t", "<Esc>", [[<C-\><C-n>]], opts)

-- execute macro with noautocmd
keymap("n", "@", function()
    vim.fn.execute("noautocmd norm! " .. vim.v.count1 .. "@" .. vim.fn.getcharstr() .. "<CR>")
end,
    { noremap = true, silent = true })
