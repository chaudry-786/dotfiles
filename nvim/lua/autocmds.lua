-- get rid of traling whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "CustomAutoCmds",
    pattern = "*",
    callback = function()
        local save = vim.fn.winsaveview()
        vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
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

-- automatiaclly, update qf on a given pattern for current buffer.
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
