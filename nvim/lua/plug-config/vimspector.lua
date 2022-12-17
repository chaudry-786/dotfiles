local keymap = vim.api.nvim_set_keymap
local del_unmap = vim.api.nvim_del_keymap
local opts = { noremap = true, silent = true }
-- Use arrow keys when debugging, makes it much simpler.
-- Because debug mode is rare, only map keys when it's turned on
DebugMode = false
function ToggleDebugMode()
    if DebugMode then
        -- unmape all keys
        local keysToUnmap = { "<Up>", "<Left>", "<Right>", "<Down>", "<Leader>ds", "<Leader>de", "<Leader>dc",
            "<Leader>db", "<Leader>dB" }
        for key in pairs(keysToUnmap) do
            del_unmap("n", keysToUnmap[key])
        end
        keymap("n", "<leader>d", ":bdelete<CR>", opts)
        vim.cmd("call vimspector#Reset()")
        print("DebugMode is OFF")
    else
        keymap("n", "<Leader>ds", ":call vimspector#Launch()<CR>", opts)
        keymap("n", "<Leader>de", ":call vimspector#Reset()<CR>", opts)
        keymap("n", "<Leader>dc", ":call vimspector#Continue()<CR>", opts)

        -- breakpoints
        keymap("n", "<Leader>db", ":call vimspector#ToggleBreakpoint()<CR>", opts)
        keymap("n", "<Leader>dB", ":call vimspector#ClearBreakpoints()<CR>", opts)

        -- arrow keys
        keymap("n", "<Up>", "<Plug>VimspectorRestart", {})
        keymap("n", "<Left>", "<Plug>VimspectorStepOut", {})
        keymap("n", "<Right>", "<Plug>VimspectorStepInto", {})
        keymap("n", "<Down>", "<Plug>VimspectorStepOver", {})

        del_unmap("n", "<leader>d")
        vim.cmd("call vimspector#Launch()")
        print("DebugMode is ON")
    end
    DebugMode = not DebugMode
end

keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)

-- reference https://puremourning.github.io/vimspector/configuration.html#predefined-variables
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
