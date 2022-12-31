local set = vim.opt

-- general
set.encoding = "utf-8"                                  --default encoding
set.syntax = "on"                                       --critical for better syntax highlighting
set.scrolloff = 7                                       --allow n lines at the bottom and top
set.ignorecase = true                                   --ignore case in search
set.laststatus = 3                                      --global statusline
set.cmdheight = 2                                       --screen lines for command-line
set.updatetime = 300                                    --quciker update  time for better experience
set.shortmess = vim.o.shortmess ..  "c"
vim.g["python3_host_prog"] = "~/vim_venv/bin/python"    --python virtualenv path
if vim.fn.exists("+termguicolors") then
    vim.opt.termguicolors = true                        -- true colours for nvim in tmux
end

-- signcolumn
set.number = true                                       --show cursorline number
set.relativenumber = true                               --relative line numbers
set.signcolumn = "number"                               -- display signs in the 'number' column

-- cursorline
-- cursorline should only be visible in active window
-- vim.api.nvim_create_autocmd("VimEnter", {pattern = "*", command = [[setlocal cursorline]]} )
-- vim.api.nvim_create_autocmd("WinEnter", {pattern = "*", command = [[setlocal cursorline]]} )
-- vim.api.nvim_create_autocmd("BufWinEnter", {pattern = "*", command = [[setlocal cursorline]]} )
-- vim.api.nvim_create_autocmd("WinLeave", {pattern = "*", command = [[setlocal nocursorline]]} )
-- set.cursorlineopt = "line"                              --do not highlight sign column in cursorline

-- disable backups for coc
set.backup = false
set.writebackup = false

-- swap files
set.swapfile = true                                     --swap files
set.dir = os.getenv("HOME") .. "/tmp"                   --swap file directory

-- fold
set.foldmethod = "expr"                                 --treesitter for folds
set.foldexpr = "nvim_treesitter#foldexpr()"             --treesitter for folds
set.foldenable = false                                  --do not auto create folds when file opens
set.foldnestmax = 3                                     --max nested fold level
set.foldlevel = 2                                       --fold level: zr or zm
function _G.MyFoldText()
    local foldStartText = vim.fn.getline(vim.v.foldstart) .. "  "
    local foldLineCount = vim.v.foldend - vim.v.foldstart
    local totalLines    = vim.api.nvim_buf_line_count(0)
    local foldPercInBuf = math.floor((foldLineCount / totalLines) * 100)
    local conLen = string.len(foldStartText .. foldLineCount .. " lines: ")
    local winWidth = vim.api.nvim_win_get_width(0)

    return foldStartText ..
        string.rep("-", ((winWidth - conLen) - 25)) ..
        "  " .. foldLineCount .. " lines: " .. string.rep(" ", 2 - string.len(tostring(foldPercInBuf))) .. foldPercInBuf .. "%"
end
set.foldtext      = 'v:lua.MyFoldText()'
vim.opt.fillchars = { fold = " ", foldopen = "", foldclose = "", foldsep = " " }
set.foldcolumn = "1"

--4 spaces with tab
set.tabstop = 4                                         --number of spaces that a <Tab> in the file counts for
set.shiftwidth = 4                                      --this determines indent guide and formating (invalid [--python--])
set.expandtab = true
set.clipboard = "unnamedplus"                           --copy to system clipboard

-- better split window locations
set.splitright = true                                   --default vertical split to right
set.splitbelow = true                                   --default horizental split to below

set.mouse = ""                                          --disable mouse

set.pumwidth = 30                                       --minimum width for
set.pumheight = 15                                      --maximum number of items listed in pum
