require('aerial').setup({
    layout = {
        default_direction = "right"
    },
    nerd_font = true,
    show_guides = true,
    icons = {
        Class    = "ﴯ ",
        Function = " ",
        Method   = " ",
    }
})

-- toggle | also disables fade plugin
vim.api.nvim_set_keymap("n", "<leader>to", ":AerialToggle <CR>", {})
vim.api.nvim_set_hl(0, "AerialLine", { bold = true, bg = "#3d3c3b" })

-- Colour for Icons, same as cocPopMenu
local symbolKind = {
    "Class",
    "Color",
    "Constant",
    "Constructor",
    "Enum",
    "EnumMember",
    "Event",
    "Field",
    "File",
    "Folder",
    "Function",
    "Interface",
    "Keyword",
    "Method",
    "Module",
    "Operator",
    "Package",
    "Property",
    "Reference",
    "Snippet",
    "String",
    "Struct",
    "Text",
    "Unit",
    "Value",
    "Variable",
    "Collapsed",
}
for key, value in pairs(symbolKind) do
    local linkStr = "hi link" .. " Aerial" .. value .. "Icon" .. " CocSymbol" .. value
    vim.cmd(linkStr)
end
