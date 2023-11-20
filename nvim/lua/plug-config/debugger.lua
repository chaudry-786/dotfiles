require("dapui").setup()
local dap, dapui = require("dap"), require("dapui")
local keymap = vim.api.nvim_set_keymap
local buff_keymap = vim.api.nvim_buf_set_keymap
local del_keymap = vim.api.nvim_buf_del_keymap
local opts = { noremap = true, silent = true }

local DebugBuffers = {}
local debugAutocmdGroupName = "DebugAutocmd"

-- map debug keys
function MapDebugKeys()
    buff_keymap(0, "n", "<Up>", "<Cmd>lua require'dap'.restart()<CR>", {})
    buff_keymap(0, "n", "<Left>", ":DapStepOut<CR>", {})
    buff_keymap(0, "n", "<Right>", ":DapStepInto<CR>", {})
    buff_keymap(0, "n", "<Down>", ":DapStepOver<CR>", {})
    buff_keymap(0, "n", "<Leader><Down>", ":DapContinue<CR>", {})

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

-- create and trigger the debug autocommand
function SetupAndTriggerDebugAutocmd()
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
end

local DebugMode = false
local firstIteration = true
-- automatically launch the UI and map unmap keys
dap.listeners.after.event_initialized["dapui_config"] = function()
    SetupAndTriggerDebugAutocmd()
    dapui.open()
    DebugMode = true
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
    UnmapDebugKeys()
    DebugMode = false
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
    UnmapDebugKeys()
    DebugMode = false
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

-- will ask what config to start the debugger with
function DebuggerRelaunch()
    firstIteration = true
    DebugMode = false
    ToggleDebugMode()
end

keymap("n", "<Leader>Dr", ":lua DebuggerRelaunch()<CR>", opts)
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<leader>td", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<Leader>tb", ":DapToggleBreakpoint<CR>", opts)
keymap("n", "<Leader>tB", ":lua require'dap'.clear_breakpoints()<CR>", opts)


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
keymap("n", "<Leader>dt", ":lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
keymap("n", "<Leader>tt", ":lua require('neotest').summary.toggle()<CR>", opts)
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
