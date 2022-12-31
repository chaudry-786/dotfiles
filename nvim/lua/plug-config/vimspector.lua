local keymap = vim.api.nvim_set_keymap
local buff_keymap = vim.api.nvim_buf_set_keymap
local del_keymap = vim.api.nvim_buf_del_keymap
local opts = { noremap = true, silent = true }
-- Use arrow keys when debugging, makes it much simpler.
-- Because debug mode is rare, only map keys when it's turned on
local debugMode = false
function ToggleDebugMode()
    --[[ Launch or Reset debugger. Set debug mapping for the current buffer and create
    Autocmd to create mappings for buffers of the same file type
    --]]
    if debugMode then
        vim.cmd("call vimspector#Reset()")
        -- unmape all keys from the debugging buffers
        local keysToUnmap = { "<Up>", "<Left>", "<Right>", "<Down>", "<Leader>Dc" }
        for buff, v in pairs(DebugBuffers) do
            -- ensure buffer exists
            if vim.fn.buflisted(buff) == 1 then
                for key in pairs(keysToUnmap) do
                    del_keymap(buff, "n", keysToUnmap[key])
                end
            end
        end
    else
        DebugBuffers = {}
        local debug_filetype = vim.bo.filetype
        -- create an autocommand to create debug mappings automatically for "debug_filetype" buffers
        vim.api.nvim_create_augroup("DebugAutocmd", { clear = true })
        vim.api.nvim_create_autocmd("FileType",
            { group = "DebugAutocmd", pattern = { debug_filetype },
                command = [[lua MapDebugKeys()]] })
        -- Trigger fileType autocmd for existing "debug_filetype" buffers so above command can run
        vim.cmd(string.format("let buf=bufnr('%%') | bufdo if &ft == '%s' | doautocmd FileType | endif | exec 'b' buf",
            debug_filetype))

        vim.cmd("call vimspector#Launch()")
    end
    debugMode = not debugMode
end

function MapDebugKeys()
    -- continue until next break point
    buff_keymap(0, "n", "<Leader>Dc", ":call vimspector#Continue()<CR>", opts)

    -- -- arrow keys
    buff_keymap(0, "n", "<Up>", "<Plug>VimspectorRestart", {})
    buff_keymap(0, "n", "<Left>", "<Plug>VimspectorStepOut", {})
    buff_keymap(0, "n", "<Right>", "<Plug>VimspectorStepInto", {})
    buff_keymap(0, "n", "<Down>", "<Plug>VimspectorStepOver", {})

    -- Keep a track of buffers for which debug keymaps have been set
    DebugBuffers[vim.fn.bufnr()] = true
end

-- Launch and end debug session
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<leader>td", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<Leader>Ds", ":call vimspector#Launch()<CR>", opts)
keymap("n", "<Leader>De", ":call vimspector#Reset()<CR>", opts)

-- breakpoints
keymap("n", "<Leader>tb", ":call vimspector#ToggleBreakpoint()<CR>", opts)
keymap("n", "<Leader>tB", ":call vimspector#ClearBreakpoints()<CR>", opts)


-- reference https://puremourning.github.io/vimspector/configuration.html#predefined-variables
-- examples ~/.vim/plugged/vimspector/support/test
-- TODO: dynamically create debug configs, reduce repeated lines
local breakPointDict = {
    exception = {
        raised = "N",
        uncaught = "",
        userUnhandled = ""
    }
}
vim.g.vimspector_configurations = {
    CurrentFile = {
        adapter = "debugpy",
        filetypes = { "python" },
        configuration = {
            args = { "*${args}" },
            cwd = "${workspaceRoot}",
            program = "${file}",
            python = "${workspaceRoot}/venv/bin/python",
            request = "launch",
            stopOnEntry = false,
            type = "python",
        },
        breakpoints = breakPointDict
    },

    Flask = {
        adapter = "debugpy",
        filetypes = { "python" },
        configuration = {
            args = { "run" },
            cwd = "${workspaceRoot}",
            debugOptions = {},
            env = { FLASK_APP = "app.py" },
            jinja = true,
            program = "${workspaceRoot}/venv/bin/flask",
            python = "${workspaceRoot}/venv/bin/python",
            request = "launch",
            stopOnEntry = false,
            type = "python",
        },
        breakpoints = breakPointDict
    },
    ScrapySpider = {
        adapter = "debugpy",
        filetypes = { "python" },
        configuration = {
            args = { "crawl", "*${spiderName}"},
            cwd = "${cwd}",
            program = "${cwd}/venv/bin/scrapy",
            python = "${cwd}/venv/bin/python",
            request = "launch",
            stopOnEntry = false,
            type = "python",
        },
        breakpoints = breakPointDict
    }
}
