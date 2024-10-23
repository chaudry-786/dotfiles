local M = {}
function M.goto_start_of_line()
    local start_pos = vim.fn.col(".")
    if start_pos ~= 1 then
        vim.cmd("normal! ^")
        if start_pos <= vim.fn.col(".") then
            vim.cmd("normal! 0")
        end
    end
end

function M.enable_very_magic()
    local cmdline, cmdtype = vim.fn.getcmdline(), vim.fn.getcmdtype()
    if cmdtype ~= ":" then
        return "/"
    end
    -- list of valid command-line inputs that trigger very magic mode
    local valid_values = { "s", [['<,'>s]], "%s", "g", [['<,'>g]], "g!", [['<,'>g!]] }
    if vim.tbl_contains(valid_values, cmdline) then
        return "/\\v"
    elseif cmdline == "v" then
        return [[imgrep /\v/ **/*]] .. string.rep("<Left>", 6)
    elseif cmdline == "vext" then
        -- for "vext/" command, grep over current file extension
        local current_extension = vim.fn.expand("%:e")
        vim.fn.setcmdline("vimgrep /\\v/ **/*." .. current_extension, 12)
        return
    elseif string.match(cmdline, "^vext:") then
        -- for "vext:ext1,ext2,ext3/" command, grep over specified extensions
        local extensions = string.sub(cmdline, 6, -1) -- extract extensions from the command
        vim.fn.setcmdline("vimgrep /\\v/ **/*.{" .. extensions .. ",}", 12)
        return
    end
    return "/"
end

function M.toggle_quickfix()
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            vim.cmd "cclose"
            return
        end
    end
    vim.cmd "copen"
end

function M.toggle_spelling()
    vim.opt.spell = not vim.opt.spell:get()
end

-- by default set this to 2
vim.o.conceallevel = 2
function ToggleConceallevel()
    vim.o.conceallevel = vim.o.conceallevel == 2 and 0 or 2
end

function M.execute_macro()
    vim.fn.execute("noautocmd norm! " .. vim.v.count1 .. "@" .. vim.fn.getcharstr() .. "<CR>")
end

function M.smart_n()
    return vim.v.searchforward == 1 and "nzz" or "Nzz"
end

function M.smart_N()
    return vim.v.searchforward == 1 and "Nzz" or "nzz"
end

-- Friction points in nvim default paste behaviour which lead to this customization:
-- 1) Doesn't indent pasted text.
-- 2) In visual modes, it copies replaced text.
-- 3) In visual mode, adds a new line break at the start pasted text.
-- 4) Personal preference: in visual mode it should get rid of line
--      break at the end of pasted text. so it would replace
--      exactly the highlighted text.
function M.better_paste_visual()
    -- <C-r><C-p>+ :pastes in insert mode and maintains indent
    local register_text = vim.fn.getreg()
    local has_newline = string.match(register_text, "\n$") ~= nil

    if has_newline and vim.fn.mode() == "v" then
        register_text = string.gsub(register_text, "\n$", "")
        vim.fn.setreg("z", register_text)
        return [["_d"zP]]
    elseif not has_newline and vim.fn.mode() == "V" then
        return [["_dO<C-r><C-p>+<esc>]]
    end

    return [["_di<C-r><C-p>+<esc>]]
end

function M.betterPasteNormal(register)
    local cmd
    local pre_cursor = (register == "") and "" or '"'
    if not register or register == "" then
        cmd = [[match(getreg(), "\n$") == -1 ? "p" : "o<C-r><C-p>+<esc>\"_ddk"]]
    else
        cmd = string.format(
            [[match(getreg('%s'), "\n$") == -1 ? "\"%sp" : "o<C-r><C-p>%s<esc>\"_ddk"]],
            register, register, register)
    end
    vim.keymap.set("n", pre_cursor .. register .. "p", cmd, { noremap = true, silent = true, expr = true })
end

function M.paste_on_below_line()
    if vim.fn.match(vim.fn.getreg(), "\n$") == -1 then
        return "o<C-r><C-p>+<esc>"
    else
        return "o<C-r><C-p>+<esc>\"_dd"
    end
end

function M.paste_on_above_line()
    if vim.fn.match(vim.fn.getreg(), "\n$") == -1 then
        return "O<C-r><C-p>+<esc>"
    else
        return "O<C-r><C-p>+<esc>\"_dd"
    end
end

function M.vscode_right_tab()
    Vscode.call("workbench.action.nextEditor")
end

function M.vscode_left_tab()
    Vscode.call("workbench.action.previousEditor")
end

function M.vscode_quit()
    Vscode.call("workbench.action.closeActiveEditor")
end

function M.vscode_quit_all()
    Vscode.call("workbench.action.quit")
end

function M.vscode_vsplit()
    Vscode.call("workbench.action.splitEditor")
end

function M.vscode_hsplit()
    Vscode.call("workbench.action.splitEditorUp")
end

function M.do_nothing()
    return
end

-- XXXX KEYPRESS ANALYSIS XXXX --
local mapping_log = os.getenv("HOME") .. "/vim_analysis/all_mappings.csv"
os.remove(mapping_log)
function M.write_mapping_to_file(mode_yes, key, description, rhs_type)
    local file = io.open(mapping_log, "a")
    if not file then
        print("Could not open file for writing: " .. mapping_log)
        return
    end

    -- Format modes for output
    local mode_str = ""
    if type(mode_yes) == "table" then
        mode_str = table.concat(mode_yes, ", ")
    else
        mode_str = mode_yes
    end

    file:write(string.format("%s~%s~%s~%s\n", mode_str, key, description, rhs_type))

    file:close()
end

local prefix = vim.g.vscode and "vscode" or "nvim"
local today_date = os.date("%Y-%m-%d")
local log_dir = os.getenv("HOME") .. "/vim_analysis"
local key_logs_file = log_dir .. "/" .. prefix .. "_key_logs_" .. today_date .. ".txt"
-- Ensure the vim_analysis directory exists
os.execute("mkdir -p " .. log_dir)

local log_buffer = {}
local is_writing = false
local function flush_buffer()
    if is_writing then return end
    is_writing = true

    local file = io.open(key_logs_file, "a")
    if file then
        for _, log_entry in ipairs(log_buffer) do
            file:write(log_entry)
        end
        file:close()
        log_buffer = {}
    else
        print("Error: Cannot open log file!")
    end

    is_writing = false
end

function M.log_keypress(lhs, rhs_desc)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local log_entry = string.format("[%s]~%s~%s\n", timestamp, lhs, rhs_desc)
    table.insert(log_buffer, log_entry)

    if #log_buffer >= 10 then
        flush_buffer()
    end
end

return M
