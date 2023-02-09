-- get rid of traling whitespace
local function TrimWhiteSpace()
    local save = vim.fn.winsaveview()
    vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
end

vim.api.nvim_create_autocmd("BufWritePre", { group = "CustomAutoCmds", pattern = '*', callback = TrimWhiteSpace })

local function yankLogic()
    -- temporarily cancels document highlight by coc
    vim.cmd("doautocmd CursorMovedI")
    vim.highlight.on_yank({ timeout = 300, higroup = "YankHighlight" })
end
-- briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost",
    { group = "CustomAutoCmds", pattern = '*', callback = yankLogic })


--Set to true if a session was loaded
local sessionLoaded = false
vim.api.nvim_create_autocmd("SessionLoadPost",
    { group = "CustomAutoCmds", pattern = '*',
        callback = function() sessionLoaded = true end })

vim.api.nvim_create_autocmd("VimEnter",
    { group = "CustomAutoCmds", pattern = '*',
        callback = function()
            -- clear jumps
            vim.cmd("clearjumps")

            -- At start, if no session loaded and Session.vim exists then start tracking session
            vim.defer_fn(function()
                if not sessionLoaded and vim.fn.filereadable("Session.vim") == 1 then
                    vim.cmd("Obsession")
                end
            end, 1000)
        end

    }
)


vim.api.nvim_create_augroup("QfAutoCmds", { clear = true })
-- automatiaclly, update, open and close qf on a given pattern for current buffer.
local function create_qf_autocmds(qf_patterns)

    local c_autocmd = vim.api.nvim_create_autocmd
    for file_type, pattern in pairs(qf_patterns) do
        -- wincmd p = go to previous window (don't focus on qf list)
        c_autocmd("BufWinEnter",
            { group = "QfAutoCmds", pattern = file_type, command = "silent vimgrep/" ..
                pattern .. " % | copen | wincmd p" })
         -- j = do not jump
        c_autocmd("BufWritePost",
            { group = "QfAutoCmds", pattern = file_type, command = "silent vimgrep/" .. pattern .. "j %" })
        c_autocmd("BufWinLeave",
            { group = "QfAutoCmds", pattern = file_type, command = "cclose" })
    end
end

local qf_patterns = { ["*.sql"] = [[\v(\a|_)+ AS \(/]] }
-- create_qf_autocmds(qf_patterns)

-- ignore quick fix list from buflist
vim.api.nvim_create_autocmd("FileType", { group = "CustomAutoCmds", pattern = 'qf', command = [[ set nobuflisted ]] })
