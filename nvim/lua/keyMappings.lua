local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- converts raw string input to termcodes to be fed as keys
local function t(key)
    return vim.api.nvim_replace_termcodes(key, true, true, true)
end

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- avoid repeating hjkl keys
local id
local function avoid_hjkl(mode, mov_keys)
    for _, key in ipairs(mov_keys) do
        local count = 0
        vim.keymap.set(mode, key, function()
            if count >= 5 then
                id = vim.notify("Hold it Cowboy!", vim.log.levels.WARN, {
                    icon = "🤠",
                    replace = id,
                    keep = function()
                        return count >= 5
                    end,
                })
            else
                count = count + 1
                -- after 5 seconds decrement
                vim.defer_fn(function()
                    count = count - 1
                end, 5000)
                return key
            end
        end, { expr = true })
    end
end

-- Hard mode toggle
HardMode = false
function ToggleHardMode()
    local modes = { "n", "v" }
    local movement_keys = { "h", "j", "k", "l" }
    if HardMode then
        for _, mode in pairs(modes) do
            for _, m_key in pairs(movement_keys) do
                vim.api.nvim_del_keymap(mode, m_key)
            end
        end
        vim.notify("Hard mode OFF", vim.log.levels.INFO, { timeout = 5 })
    else
        for _, mode in pairs(modes) do
            avoid_hjkl(mode, movement_keys)
        end
        vim.notify("Hard mode ON", vim.log.levels.INFO, { timeout = 5 })
    end
    HardMode = not HardMode
end

-- ToggleHardMode()
keymap("n", "<leader>th", ":lua ToggleHardMode()<CR>", opts)

-- do not copy delete and change command
vim.keymap.set({ "n", "v" }, "d", [["_d]], opts)
vim.keymap.set({ "n", "v" }, "D", [["_D]], opts)
vim.keymap.set({ "n", "v" }, "c", [["_c]], opts)
vim.keymap.set({ "n", "v" }, "C", [["_C]], opts)

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
vim.keymap.set("v", "p", betterPasteVisual, expr_opts)

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
keymap("", "H", "^", {})
keymap("", "L", "$", {})

-- buffers shortcuts
keymap("n", "<leader>l", ":bnext<CR>", opts)
keymap("n", "<leader>h", ":bprevious<CR>", opts)
keymap("n", "<leader>d", ":bdelete<CR>", opts)
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

-- reload Config and all the modules
function _G.ReloadConfig()
    local customUserModules = {
        ["options"] = true,
        ["keyMappings"] = true,
        ["autocmds"] = true,
        ["highlights"] = true,
        ["textObjects"] = true
    }
    for name, _ in pairs(package.loaded) do
        if string.match(name, "^plug%-config") or customUserModules[name] then
            package.loaded[name] = nil
        end
    end
    dofile(vim.env.MYVIMRC)
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { timeout = 5 })
end

keymap("n", "<leader>so", "<cmd>lua ReloadConfig()<CR>", { noremap = true, silent = false })

--  move code alt+arrows
keymap("n", "<M-Up>", [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], opts)
keymap("n", "<M-Down>", [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], opts)
keymap("i", "<M-Up>", [[<C-O>m`<C-O>:move -2<CR><C-O>``]], opts)
keymap("i", "<M-Down>", [[<C-O>m`<C-O>:move +1<CR><C-O>``]], opts)
keymap("v", "<M-Up>", [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], opts)
keymap("v", "<M-Down>", [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], opts)

-- keep jumps and search in middle also n and N are smart to go only one way
-- when search is going either way (up or down).
vim.keymap.set("n", "n", function() return vim.v.searchforward == 1 and "nzz" or "Nzz" end,
    { expr = true, noremap = true })
vim.keymap.set("n", "N", function() return vim.v.searchforward == 1 and "Nzz" or "nzz" end,
    { expr = true, noremap = true })
keymap("n", "<C-o>", "<C-o>zz", opts)
keymap("n", "<C-i>", "<C-i>zz", opts)

-- copy whole buffer
keymap("n", "<leader>y", ":%y+<CR>", opts)

-- escape: also clears highlighting
keymap("n", "<esc>", "<Cmd>noh<return><esc>", opts)

-- indent and keep stay in visualMode
keymap("v", ">", ">gv", opts)
keymap("v", "<", "<gv", opts)

-- fuzzy help for anything
keymap("n", "<leader>?", ":! tmux neww ~/dotfiles/scripts/chtfzf.sh -t <CR>", opts)

-- very magic mode enabled by default
-- do not use silent in command mode, it delays rhs key input until the next key
keymap("n", "/", [[/\v]], { noremap = true })
keymap("n", "?", [[?\v]], { noremap = true })
-- ["incomingKey"] = { currentCmdValue = [[valueToBeSetInCmdLine] },
local cmdLineReturns = {
    [t("s")] = { [""] = [[%s/\v]],["'<,'>"] = [['<,'>s/\v]] },
    [t("g")] = { [""] = [[g/\v]],["'<,'>"] = [['<,'>g/\v]] },
    [t("v")] = { [""] = [[vimgrep /\v/ **/*]] .. string.rep("<Left>", 6) },
    [t("<BS>")] = { ["%s/\\v"] = "s",["g/\\v"] = "g",["'<,'>s/\\v"] = "'<,'>s",["'<,'>g/\\v"] = "'<,'>g",
        ["vimgrep /\\v/ **/*"] = "v" },
}
function _G.cmdLineMappings(key)
    local cmdline, cmdtype = vim.fn.getcmdline(), vim.fn.getcmdtype()
    -- incoming keys are automatically converted to termcode
    if cmdtype == ":" and cmdLineReturns[key] and cmdLineReturns[key][cmdline] then
        vim.fn.setcmdline("")
        return t(cmdLineReturns[key][cmdline])
    end
    return key
end

local function set_cmdline_keymaps(keys)
    for _, key in ipairs(keys) do
        local mapping = string.format([[v:lua.cmdLineMappings("%s")]], key)
        keymap("c", key, mapping, { noremap = true, expr = true })
    end
end
set_cmdline_keymaps({ "s", "g", "v", "<BS>" })

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

--fold movement
keymap("", "[z", "zk", opts)
keymap("", "]z", "zj", opts)

function ToggleSpellCheck()
    vim.opt.spell = not (vim.opt.spell:get())
end
keymap("n", "<leader>ts", ":lua ToggleSpellCheck()<CR>", opts)
