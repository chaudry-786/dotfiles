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

            -- At start automatically start tracking a session
            -- If no session was loaded and Session.vim file doens't exist in current dir
            vim.defer_fn(function()
                if not sessionLoaded then
                    vim.cmd("Obsession")
                end
            end, 1000)
        end

    }
)
