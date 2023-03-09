-- --Debugger
-- use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
-- use { "williamboman/mason.nvim", config = require("mason").setup() }
require("dapui").setup()

-- automatically launch the UI
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end



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
        vim.cmd("DapTerminate")
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

        vim.cmd("DapContinue")
    end
    debugMode = not debugMode
end

function MapDebugKeys()
    -- continue until next break point
    -- buff_keymap(0, "n", "<Leader>Dc", "<Cmd>lua require'dap'.continue()<CR>", opts)
    buff_keymap(0, "n", "<Leader>Dc", ":DapContinue<CR>", opts)

    -- -- arrow keys
    buff_keymap(0, "n", "<Up>", "<Cmd>lua require'dap'.run_last()<CR>", {})
    buff_keymap(0, "n", "<Left>", ":DapStepOut<CR>", {})
    buff_keymap(0, "n", "<Right>", ":DapStepInto<CR>", {})
    buff_keymap(0, "n", "<Down>", ":DapStepOver<CR>", {})

    -- Keep a track of buffers for which debug keymaps have been set
    DebugBuffers[vim.fn.bufnr()] = true
end

-- Launch and end debug session
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<leader>td", ":lua ToggleDebugMode()<CR>", opts)

-- breakpoints
keymap("n", "<Leader>tb", ":DapToggleBreakpoint<CR>", opts)
keymap("n", "<Leader>tB", ":lua require'dap'.clear_breakpoints()<CR>", opts)

dap.configurations.python = {
    {
        type = "python";
        request = "launch";
        name = "Launch file";
        program = "${file}";
        pythonPath = "${workspaceFolder}" .. "/venv/bin/python"
    },
}

dap.adapters.python = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
    args = { "-m", "debugpy.adapter" },
}
