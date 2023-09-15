-- disable lualine if launched by firenvim in web browser
if vim.g.started_by_firenvim then
    vim.cmd("set laststatus=0")
    return
end

local function working_dir()
    local path = vim.fn.expand("%:~:.")
    if string.find(path, "/") == nil then
        return " "
    end
    local modified_path = string.gsub(path, "/[^/]*$", "")
    return " " .. modified_path
end

local file_and_symbol_section = {
    { working_dir, component_separators = { right = "" }, padding = { left = 1, right = 1 } },
    { "filetype", padding = { right = 0, left = 0 }, icon_only = true,
        component_separators = { left = "" }
    },
    { "filename", padding = { left = 1, right = 1 }, color = { gui = "italic,bold" },
        component_separators = { left = "" }
    },
    { "aerial",    sep = "  ",                         padding = { right = 2, left = 1 }, dense = false }
}

local function lines_and_search_count()
    -- easier to know how many lines to run the macro on in any direction
    local totalLines = vim.api.nvim_buf_line_count(0)
    local currentLine, currentChar = unpack(vim.api.nvim_win_get_cursor(0))
    -- search count
    local search_stat
    if vim.v.hlsearch == 1 then
        local sinfo = vim.fn.searchcount { maxcount = 0 }
        search_stat = sinfo.incomplete > 0 and "[?/?]"
            or sinfo.total > 0 and ("[%s/%s]"):format(sinfo.current, sinfo.total)
            or nil
    end
    return (search_stat and " " .. search_stat or "") .. " " .. currentLine .. ":" .. totalLines - currentLine + 1
end
-- do not show search count message when searching, e.g. "[2/5]" because above function shows in lualine
vim.o.shortmess = vim.o.shortmess .. "S"

require("lualine").setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", { "diff", symbols = { added = " ", modified = " ", removed = " " } } },
        lualine_c = file_and_symbol_section,
        lualine_x = { { "buffers", mode = 2,
            symbols = {
                alternate_file = "",
            },
            max_length = vim.o.columns * 2 / 4,
            component_separators = { left = "", right = "" },
        } },
        lualine_y = {
            {
                "diagnostics",
                sources = { "coc" },
                sections = { "hint", "warn", "error" },
                symbols = { error = " " },
                always_visible = true -- Show diagnostics even if there are none.
            }
        },
        lualine_z = { "progress", lines_and_search_count }
    },
    options = {
        theme = "rose-pine",
        disabled_filetypes = {
            winbar = { "aerial", "NvimTree", "dbui", "help", "alpha" },
        },
    }
})
