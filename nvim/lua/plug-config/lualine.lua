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
    -- modified_path = string.gsub(modified_path, "/", "  ")
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
    { "aerial", sep = "  ", padding = { right = 2, left = 1 }, dense = false }
}

-- easier to know how many lines to run the macro on in any direction
local function lines_above_and_below()
    local totalLines = vim.api.nvim_buf_line_count(0)
    local currentLine, currentChar = unpack(vim.api.nvim_win_get_cursor(0))
    return currentLine .. ":" .. totalLines - currentLine + 1
end

require('lualine').setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", { "diff", symbols = { added = " ", modified = "柳", removed = " " } } },
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
        lualine_z = { "progress", lines_above_and_below  }
    },
    options = {
        theme = "rose-pine",
        disabled_filetypes = {
            winbar = { "aerial", "NvimTree", "dbui", "help", "alpha" },
        },
    }
})
