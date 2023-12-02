local set = vim.opt

-- general
set.encoding = "utf-8"                                  --default encoding
set.syntax = "on"                                       --critical for better syntax highlighting
set.spelloptions = "camel"                              --camel case for spellcheck
set.spelllang = "en_gb"                                 --spell check language
set.spellcapcheck = ""                                  --do not spell check capital at the start of sentence
set.spell = true                                        --enable spell check by default
set.scrolloff = 7                                       --allow n lines at the bottom and top from cursor
set.sidescrolloff=10                                    --allow n chars on left and right from cursor
set.ignorecase = true                                   --ignore case in search
set.smartcase = true                                    --if search contains capital then make it case sensitive
set.wrapscan = false                                    --do not cycle search. stop at the bottom and top
set.laststatus = 3                                      --global statusline
set.updatetime = 300                                    --quicker update  time for better experience
set.shortmess = vim.o.shortmess ..  "c"
vim.g["python3_host_prog"] = "~/vim_venv/bin/python"    --python virtualenv path
set.termguicolors = true                                --true colours for nvim in tmux
set.breakindent = true                                  --every wrapped line will continue visually indented

-- cursorline
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" },
    { group = "CustomAutoCmds", pattern = "*", command = [[setlocal cursorline]] })
vim.api.nvim_create_autocmd("WinLeave", { group = "CustomAutoCmds", pattern = "*", command = [[setlocal nocursorline]] })
set.cursorlineopt = "number"                            -- only set line number

-- disable backups for coc
set.backup = false
set.writebackup = false

-- swap files
set.swapfile = true                                     --swap files
set.dir = os.getenv("HOME") .. "/tmp"                   --swap file directory

-- fold
set.foldmethod = "expr"                                 --treesitter for folds
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- set.foldtext = "v:lua.vim.treesitter.foldtext()"
function Foldtext()
    local text = vim.treesitter.foldtext()
    local n_lines = vim.v.foldend - vim.v.foldstart
    local text_lines = " lines"
    if n_lines == 1 then
        text_lines = " line"
    end
    table.insert(text, { " + " .. n_lines .. text_lines, { "Folded" } })
    return text
end
vim.opt.foldtext = "v:lua.Foldtext()"

vim.api.nvim_create_autocmd("FileType",
    { group = "CustomAutoCmds", pattern = "sql", command = [[ setlocal foldmethod=indent ]] })
-- set.foldenable = false                                  --do not auto create folds when file opens
set.foldnestmax = 10                                    --max nested fold level
set.foldlevel = 0                                       --fold level: zr or zm
set.fillchars = { fold = " ", foldopen = " ", foldclose = "", foldsep = " " }

--4 spaces with tab
set.tabstop = 4                                         --number of spaces that a <Tab> in the file counts for
set.shiftwidth = 4                                      --this determines indent guide and formatting (invalid [--python--])
set.expandtab = true
set.clipboard = "unnamedplus"                           --copy to system clipboard

-- better split window locations
set.splitright = true                                   --default vertical split to right
set.splitbelow = true                                   --default horizontal split to below

set.mouse = ""                                          --disable mouse

set.pumwidth = 30                                       --minimum width for
set.pumheight = 15                                      --maximum number of items listed in pum

-- Any files/directories listed in global gitginore will be ignored by vimgrep
local file = io.open(os.getenv("HOME") .. "/.gitignore", "r")
-- If the file exists, read its contents and add each line to the wildignore option in Vim
if file then
    local contents = file:read("*all")
    file:close()
    for line in contents:gmatch("[^\r\n]+") do
        local pattern = "*" .. line .. "*"
        set.wildignore:append(pattern)
    end
end
