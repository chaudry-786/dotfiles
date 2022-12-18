local keymap = vim.api.nvim_set_keymap
local del_unmap = vim.api.nvim_del_keymap
local opts = { noremap = true, silent = true }
-- Use arrow keys when debugging, makes it much simpler.
-- Because debug mode is rare, only map keys when it's turned on
DebugMode = false
function ToggleDebugMode()
    if DebugMode then
        -- unmape all keys
        local keysToUnmap = { "<Up>", "<Left>", "<Right>", "<Down>", "<Leader>Dc" }
        for key in pairs(keysToUnmap) do
            del_unmap("n", keysToUnmap[key])
        end
        vim.cmd("call vimspector#Reset()")
    else
        -- continue until next break point
        keymap("n", "<Leader>Dc", ":call vimspector#Continue()<CR>", opts)

        -- arrow keys
        keymap("n", "<Up>", "<Plug>VimspectorRestart", {})
        keymap("n", "<Left>", "<Plug>VimspectorStepOut", {})
        keymap("n", "<Right>", "<Plug>VimspectorStepInto", {})
        keymap("n", "<Down>", "<Plug>VimspectorStepOver", {})

        vim.cmd("call vimspector#Launch()")
    end
    DebugMode = not DebugMode
end

-- Launch and end debug session
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)
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
    }
}
