require("dapui").setup()
local dap, dapui = require("dap"), require("dapui")
local keymap = vim.keymap.set
local buff_keymap = vim.api.nvim_buf_set_keymap
local del_keymap = vim.api.nvim_buf_del_keymap
local opts = { noremap = true, silent = true }

local DebugBuffers = {}
local debugAutocmdGroupName = "DebugAutocmd"
local DebugMode = false
local firstIteration = true

-- map debug keys
function MapDebugKeys()
    buff_keymap(0, "n", "<Up>", "<Cmd>lua require'dap'.restart()<CR>", opts)
    buff_keymap(0, "n", "<Left>", ":DapStepOut<CR>", opts)
    buff_keymap(0, "n", "<Right>", ":DapStepInto<CR>", opts)
    buff_keymap(0, "n", "<Down>", ":DapStepOver<CR>", opts)
    buff_keymap(0, "n", "<Leader><Down>", ":DapContinue<CR>", opts)

    -- keep track of buffers with debug keymaps
    DebugBuffers[vim.fn.bufnr()] = true
end

-- unmap debug keys
function UnmapDebugKeys()
    local keysToUnmap = { "<Up>", "<Left>", "<Right>", "<Down>", "<Leader><Down>" }
    for buff, _ in pairs(DebugBuffers) do
        if vim.fn.buflisted(buff) == 1 then
            for _, key in ipairs(keysToUnmap) do
                del_keymap(buff, "n", key)
            end
        end
    end
    DebugBuffers = {}
    vim.api.nvim_create_augroup(debugAutocmdGroupName, { clear = true })
end

local function startDebugger()
    -- create and trigger the autocommand to map keys
    local debug_filetype = vim.bo.filetype
    vim.api.nvim_create_augroup(debugAutocmdGroupName, { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = debugAutocmdGroupName,
        pattern = { debug_filetype },
        command = [[lua MapDebugKeys()]]
    })
    -- trigger FileType autocmd for existing buffers
    vim.cmd(string.format("let buf=bufnr('%%') | bufdo if &ft == '%s' | doautocmd FileType | endif | exec 'b' buf",
        debug_filetype))

    -- Launch UI
    dapui.open()
    DebugMode = true
    vim.fn.CocAction('diagnosticToggle')
end

local function endDebugger()
    dapui.close()
    UnmapDebugKeys()
    DebugMode = false
    vim.fn.CocAction('diagnosticToggle')
end

-- automatically launch the UI and map unmap keys
dap.listeners.after.event_initialized["dapui_config"] = function()
    startDebugger()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    endDebugger()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    endDebugger()
end

-- Note: if no session: DapContinue is a wrapper over dap_run,
-- but it prompts the user to select a config. If session is
-- active it continues to next break point

function ToggleDebugMode()
    if DebugMode then
        vim.cmd("DapTerminate")
    else
        if firstIteration then
            vim.cmd("DapTerminate")
            -- without sleep continue command is skipped
            vim.defer_fn(function()
                vim.cmd("lua require'dap'.continue()")
            end, 500)
            firstIteration = false
        else
            -- run with last config
            vim.cmd("lua require'dap'.run_last()")
        end
    end
end

local function xO(desc)
    return vim.tbl_extend("force", opts, { desc = desc })
end
-- will ask what config to start the debugger with
keymap("n", "<Leader>dr", function()
    firstIteration = true;
    DebugMode = false;
    ToggleDebugMode()
end, xO("Restart debugger"))
keymap("n", "<Leader>de", function()
    vim.cmd("DapTerminate");
    endDebugger()
end, xO("Terminate Debugger"))
keymap("n", "<Leader>ds", function()
    vim.cmd("DapTerminate");
    DebugMode = false;
    ToggleDebugMode()
end, xO("Start Debugger"))
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", xO("Toggler debugger"))
keymap("n", "<leader>td", ":lua ToggleDebugMode()<CR>", xO("Toggle debugger"))
keymap("n", "<Leader>tb", ":DapToggleBreakpoint<CR>", xO("Toggle breakpoint"))
keymap("n", "<Leader>tB", ":lua require'dap'.clear_breakpoints()<CR>", xO("Clear breakpoints"))
keymap("n", "<Leader>dk", "<Cmd>lua require('dapui').eval()<CR>", xO("Debug evaluate (pop up)"))



------------------------------------------------
-- Adapters config
------------------------------------------------
dap.adapters.python = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
    args = { "-m", "debugpy.adapter" },
}


local cachedArgs
local function getArgs()
    -- cache args, so next run would run straight away
    if not cachedArgs then
        local inputArgs = vim.fn.input('Enter arguments: ')
        cachedArgs = (inputArgs and inputArgs ~= '') and vim.fn.split(inputArgs, ' ') or {}
    end
    return cachedArgs
end

local function get_base_directory()
    --- Get the base directory of a Git repo or the current working directory.
    local git_dir = io.popen("git rev-parse --show-toplevel 2>/dev/null", "r")
    if git_dir then
        local base_dir = git_dir:read('*l')
        git_dir:close()
        if base_dir and base_dir ~= '' then
            return base_dir
        end
    end
    local pwd = io.popen("pwd", "r")
    if pwd then
        local current_dir = pwd:read('*l')
        pwd:close()
        return current_dir
    end
end

------------------------------------------------
-- Python configs
------------------------------------------------

local function createPythonDapConfig(name, program, args)
    local cwd = get_base_directory()
    local python_path = cwd .. "/venv/bin/python"
    return {
        type = "python",
        request = "launch",
        name = name,
        pythonPath = python_path,
        program = program,
        args = args,
        cwd = cwd
    }
end

local base_dir = get_base_directory()
local venv_dir = base_dir .. "/venv/bin/"
dap.configurations.python = {
    createPythonDapConfig("Current File", "${file}", getArgs),
    createPythonDapConfig("Django", base_dir .. "/manage.py", { "runserver", "--noreload" }),
    createPythonDapConfig("Flask", venv_dir .. "flask", { "run" }),
}

------------------------------------------------
-- Neotest - Python
------------------------------------------------
keymap("n", "<Leader>dt", ":lua require('neotest').run.run({strategy = 'dap'})<CR>", xO("Debug test"))
keymap("n", "<Leader>tt", ":lua require('neotest').summary.toggle()<CR>", xO("Toggle test summary"))
-- run all the tests in the file
-- require("neotest").run.run(vim.fn.expand("%"))
require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = true },
            python = venv_dir .. "python",
            runner = "pytest",
        })
    }
})


-- SIGNS
vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00", bg = "#1f1d2e" })
vim.api.nvim_set_hl(0, "red", { fg = "#ff0000", bg = "#1f1d2e" })
vim.fn.sign_define("DapBreakpoint", { text = "󰏤", texthl = "red" })
vim.fn.sign_define("DapBreakpointCondition", { text = "󰏤", texthl = "red" })
vim.fn.sign_define("DapBreakpointRejected", { text = "•", texthl = "yellow" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "yellow" })
vim.fn.sign_define("DapLogPoint", { text = "•", texthl = "yellow" })
