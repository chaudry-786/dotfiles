local keymap = vim.api.nvim_set_keymap
local buff_keymap = vim.api.nvim_buf_set_keymap
local del_keymap = vim.api.nvim_buf_del_keymap
local opts = { noremap = true, silent = true }
-- Use arrow keys when debugging, makes it much simpler.
-- Because debug mode is rare, only map keys when it's turned on
local debugMode = false
function ToggleDebugMode(relaunch)
    --[[ Launch or Reset debugger. Set debug mapping for the current buffer and create
    Autocmd to create mappings for buffers of the same file type
    --]]
    if debugMode then
        vim.cmd("call vimspector#Reset()")
        -- unmap all keys from the debugging buffers
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
            {
                group = "DebugAutocmd",
                pattern = { debug_filetype },
                command = [[lua MapDebugKeys()]]
            })
        -- Trigger fileType autocmd for existing "debug_filetype" buffers so above command can run
        vim.cmd(string.format("let buf=bufnr('%%') | bufdo if &ft == '%s' | doautocmd FileType | endif | exec 'b' buf",
            debug_filetype))
        if not relaunch then
            vim.cmd("call vimspector#Restart()")
        end
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

function DebuggerRelaunch()
    if not debugMode then
        ToggleDebugMode(true)
    end
    vim.cmd("call vimspector#Launch()")
end

-- restart debug session with same values
keymap("n", "<Leader>Dr", ":lua DebuggerRelaunch()<CR>", opts)

-- Launch and end debug session
keymap("n", "<F5>", ":lua ToggleDebugMode()<CR>", opts)
keymap("n", "<leader>td", ":lua ToggleDebugMode()<CR>", opts)

-- breakpoints
keymap("n", "<Leader>tb", ":call vimspector#ToggleBreakpoint()<CR>", opts)
keymap("n", "<Leader>tB", ":call vimspector#ClearBreakpoints()<CR>", opts)


-- reference https://puremourning.github.io/vimspector/configuration.html#predefined-variables
-- examples ~/.vim/plugged/vimspector/support/test
local function createPythonDebugConfig(args, program, python, cwd)
    return {
        adapter = "debugpy",
        filetypes = { "python" },
        configuration = {
            args = args,
            cwd = cwd,
            program = program,
            python = python,
            request = "launch",
            stopOnEntry = false,
            type = "python",
        },
        breakpoints = {
            exception = {
                raised = "N",
                uncaught = "",
                userUnhandled = ""
            }
        }
    }
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

local base_dir = get_base_directory()
vim.g.vimspector_configurations = {
    CurrentFile = createPythonDebugConfig({ "*${args}" }, "${file}", "${workspaceRoot}/venv/bin/python", "${workspaceRoot}"),
    Flask = createPythonDebugConfig({ "run" }, "${workspaceRoot}/venv/bin/flask", "${workspaceRoot}/venv/bin/python", "${workspaceRoot}"),
    PyTest = createPythonDebugConfig({ "-s", "${file}::Test::${args}" }, base_dir .. "/venv/bin/pytest", base_dir .. "/venv/bin/python", base_dir),
    ScrapySpider = createPythonDebugConfig({ "crawl", "*${spiderName}" }, "${cwd}/venv/bin/scrapy", "${cwd}/venv/bin/python", "${cwd}")
}
