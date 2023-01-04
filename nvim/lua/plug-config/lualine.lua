local function working_dir()
    local path = vim.fn.expand("%:~:.")
    if string.find(path, "/") == nil then
        return " "
    end
    local modified_path = string.gsub(path, "/[^/]*$", "")
    -- modified_path = string.gsub(modified_path, "/", "  ")
    return "   " .. modified_path
end

require('lualine').setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", { "diff", symbols = { added = " ", modified = "柳", removed = " " } } },
        lualine_c = {
            { "filetype", padding = { right = 0, left = 2 }, icon_only = true,
                component_separators = { left = "", right = "" } },
            { "filename", padding = { left = 1 }, color = { gui = "bold,italic" } }
        },
        lualine_x = { { "aerial", sep = "  ", padding = { right = 2, left = 2 }, dense = false, } },
        lualine_y = {
            {
                "diagnostics",
                sources = { "coc" },
                sections = { "hint", "warn", "error" },
                symbols = { error = " " },
                always_visible = true -- Show diagnostics even if there are none.
            }
        },
        lualine_z = { "progress", "location" }
    },
    winbar = {
        lualine_b = {
            { working_dir, component_separators = { right = "" }, padding = {  left = 1, right = 1 } },
            { "filetype", padding = { right = 0, left = 0 }, icon_only = true,
                component_separators = { left = "" }
            },
            { "filename", padding = { left = 1, right = 1 }, color = { gui = "italic" },
                component_separators = { left = "" }
            },
            { "aerial", sep = "  ", padding = { right = 2, left = 1 }, dense = false }
        },
    },
    inactive_winbar = {
        lualine_b = {
            { "filetype", padding = { right = 0, left = 2 }, icon_only = true,
                component_separators = { left = "", right = "" } },
            { "filename", padding = { left = 1, right = 2 }, color = { gui = "italic" } },
        },
    },
    options = {
        theme = "rose-pine",
        disabled_filetypes = {
            winbar = { "aerial", "NvimTree", "dbui", "help", "alpha" },
        },
    }
})
