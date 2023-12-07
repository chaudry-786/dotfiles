-- get rid of trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        local save = vim.fn.winsaveview()
        vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
        -- encoding issue on WSL, which pastes extra line break
        vim.api.nvim_command([[keeppatterns %s/\r$//e]])
        vim.fn.winrestview(save)
    end
})

-- briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost",
    {
        group = "CustomAutoCmds",
        pattern = "*",
        callback = function()
            -- briefly cancel highlight by CoC
            vim.cmd("doautocmd CursorMovedI")
            vim.highlight.on_yank({ timeout = 300, higroup = "YankHighlight" })
        end
    })

-- At start, if no session loaded and Session.vim exists then start tracking session
local sessionLoaded = false
vim.api.nvim_create_autocmd("SessionLoadPost",
    {
        group = "CustomAutoCmds",
        pattern = "*",
        callback = function() sessionLoaded = true end
    })
vim.api.nvim_create_autocmd("VimEnter",
    {
        group = "CustomAutoCmds",
        pattern = "*",
        callback = function()
            -- clear jumps
            vim.cmd("clearjumps")
            vim.defer_fn(function()
                if not sessionLoaded and vim.fn.filereadable("Session.vim") == 1 then
                    vim.cmd("Obsession")
                end
            end, 1000)
        end
    }
)

-- automatically, update qf on a given pattern for current buffer.
vim.api.nvim_create_augroup("QfAutoCmds", { clear = true })
local function create_qf_autocmds(qf_patterns)
    local c_autocmd = vim.api.nvim_create_autocmd
    for file_type, pattern in pairs(qf_patterns) do
        c_autocmd({ "BufWinEnter", "BufWritePost" },
            {
                group = "QfAutoCmds",
                pattern = file_type,
                callback = function()
                    if vim.fn.match(vim.fn.getline(1, "$"), pattern) ~= -1 then
                        vim.cmd("silent vimgrep/" .. pattern .. "/j %")
                    else
                        -- clean qflist
                        vim.fn.setqflist({})
                    end
                end
            })
    end
end
local qf_patterns = { ["*.sql"] = [[\v(\a|_)+ AS \(]] }
create_qf_autocmds(qf_patterns)

-- ignore quick fix list from buflist
vim.api.nvim_create_autocmd("FileType", { group = "CustomAutoCmds", pattern = "qf", command = [[ set nobuflisted ]] })

-- Treesitter automatic Python format strings
vim.api.nvim_create_autocmd("InsertCharPre", {
    pattern = { "*.py" },
    group = "CustomAutoCmds",
    callback = function(opts)
        -- Only run if f-string escape character is typed
        if vim.v.char ~= "{" then return end

        -- Get node and return early if not in a string
        local node = vim.treesitter.get_node()

        if not node then return end
        if node:type() ~= "string" then node = node:parent() end
        if not node or node:type() ~= "string" then return end

        local row, col, _, _ = vim.treesitter.get_node_range(node)

        -- Return early if string is already a format string
        local first_char = vim.api.nvim_buf_get_text(opts.buf, row, col, row, col + 1, {})[1]
        if first_char == "f" then return end

        -- Otherwise, make the string a format string
        vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<Esc>`'la")
    end,
})

-- automatically reload file when changed outside of vim
vim.api.nvim_create_autocmd("FocusGained", { group = "CustomAutoCmds", pattern = "*", command = [[checktime]] })

-- automatically resize windows
vim.api.nvim_create_autocmd("VimResized",
    { group = "CustomAutoCmds", pattern = "*", command = [[execute "normal! \<C-w>="]] })

-- turn off spellcheck in terminal
vim.api.nvim_create_autocmd("TermOpen", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        vim.cmd("setlocal nospell")
    end
})

-- Toggle autocommands: useful for executing macros and cdo
vim.keymap.set("n", "<leader>tA", function()
    local currentEventIgnore = vim.o.eventignore
    if not string.find(currentEventIgnore, "all") then
        if currentEventIgnore ~= "" then
            vim.o.eventignore = currentEventIgnore .. ",all"
        else
            vim.o.eventignore = "all"
        end
        print("Auto Commands disabled.")
    else
        vim.o.eventignore = string.gsub(currentEventIgnore, ",?all", "")
        print("Auto Commands re-enabled.")
    end
end, { noremap = true, silent = true })
