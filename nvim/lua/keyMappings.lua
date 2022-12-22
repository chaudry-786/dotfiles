local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- avoid repeating hjkl keys
local id
for _, key in ipairs({ "h", "j", "k", "l" }) do
    local count = 0
    vim.keymap.set("n", key, function()
        if count >= 10 then
            id = vim.notify("Hold it Cowboy!", vim.log.levels.WARN, {
                icon = "🤠",
                replace = id,
                keep = function()
                    return count >= 10
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

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- do not copy delete command
keymap("n", "d", "\"_d", opts)
keymap("v", "d", "\"_d", opts)

-- in visual line mode do not join pasted text to next line
keymap("v", "p", [[mode() ==# "V" && match(getreg(), "\n$") == -1 ? "\"_dd<esc>O<esc>p" : "\"_dP"]], expr_opts)
-- paste text on new line, if there is already linebreak do not insert a new one
keymap("n", "<leader>p", [[match(getreg(), "\n$") == -1 ? "o<esc>p" : "p"]], expr_opts)
keymap("n", "<leader>P", [[match(getreg(), "\n$") == -1 ? "O<esc>p" : "P"]], expr_opts)

-- move at the start and end of line easily
keymap("", "H", "^", {})
keymap("", "L", "$", {})

-- buffers shortcuts
keymap("n", "<leader>l", ":bnext<CR>", opts)
keymap("n", "<leader>h", ":bprevious<CR>", opts)
keymap("n", "<leader>d", ":bdelete<CR>", opts)
keymap("n", "<leader>w", ":write<CR>", opts)
keymap("n", "<leader>q", ":quit<CR>", opts)

--  easier split window
keymap("n", "<leader>|", ":vsplit<CR>", opts)
keymap("n", "<leader>-", ":split<CR>", opts)

-- sane resize mappings for windows <C-w>hjkl
local funs = {}
function funs.winResizeMapping()
    local keysToMap = { h = { ">" }, j = { "+" }, k = { "+" }, l = { ">" } }
    -- map all the relevant keys to Nop
    for key in pairs(keysToMap) do
        -- not sure how to do silent with nvim api
        vim.cmd("nmap <C-w>" .. string.upper(key) .. " <Nop>")
    end
    -- if only one window than return
    if vim.fn.winnr("$") == 1 then
        return
    end

    local currentWin = vim.fn.winnr()
    local horizontal = vim.fn.winnr("h") ~= currentWin or vim.fn.winnr("l") ~= currentWin
    local vertical = vim.fn.winnr("j") ~= currentWin or vim.fn.winnr("k") ~= currentWin

    -- top bottom
    for key, value in pairs(keysToMap) do
        if vim.fn.winnr(key) ~= currentWin then
            -- positives in valid directions
            keymap("n", "<C-w>" .. string.upper(key), "<C-w>5" .. value[1], { noremap = true })
        elseif (key == "h" or key == "l") and horizontal then
            -- left right minus
            keymap("n", "<C-w>" .. string.upper(key), "<C-w>5" .. "<", { noremap = true })
        elseif (key == "j" or key == "k") and vertical then
            -- up down minus
            keymap("n", "<C-w>" .. string.upper(key), "<C-w>5" .. "-", { noremap = true })
        end
    end
end

vim.api.nvim_create_autocmd("WinEnter",
    { group = "CustomAutoCmds", pattern = '*',
        callback = funs.winResizeMapping })


-- edit common files quickly
keymap("n", "<leader>ev", ":edit $MYVIMRC<cr>", opts)
keymap("n", "<leader>ez", ":edit ~/.zshrc<cr>", opts)
keymap("n", "<leader>es", ":CocCommand snippets.editSnippets<cr>", opts)
keymap("n", "<leader>ec", ":CocConfig<cr>", opts)

-- reload Config and all the modules
function _G.ReloadConfig()
    local customUserModules = { ["options"] = true, ["keyMappings"] = true, ["autocmds"] = true, ["highlights"] = true,
        ["textObjects"] = true }
    for name, _ in pairs(package.loaded) do
        if string.match(name, "^plug%-config") or customUserModules[name] then
            package.loaded[name] = nil
        end
    end
    dofile(vim.env.MYVIMRC)
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

keymap("n", "<leader>so", "<cmd>lua ReloadConfig()<CR>", { noremap = true, silent = false })

--  move code alt+arrows
keymap("n", "<M-Up>", [[:<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>``]], opts)
keymap("n", "<M-Down>", [[:<C-U>exec "exec 'norm m`' \| move +" . (0+v:count1)<CR>``]], opts)
keymap("i", "<M-Up>", [[<C-O>m`<C-O>:move -2<CR><C-O>``]], opts)
keymap("i", "<M-Down>", [[<C-O>m`<C-O>:move +1<CR><C-O>``]], opts)
keymap("v", "<M-Up>", [[:<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv]], opts)
keymap("v", "<M-Down>", [[:<C-U>exec "'<,'>move '>+" . (0+v:count1)<CR>gv]], opts)

-- keep jumps and search in middle
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "<C-o>", "<C-o>zz", opts)
keymap("n", "<C-i>", "<C-i>zz", opts)

-- copy whole buffer
keymap("n", "<leader>y", ":%y+<CR>", opts)

-- escape: also clears highlighting
keymap("n", "<esc>", "<Cmd>noh<return><esc>", opts)

-- indent and keep stay in visualMode
keymap("v", ">", ">gv", opts)
keymap("v", "<", "<gv", opts)
