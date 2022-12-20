require("which-key").setup {
    plugins = {
        registers = false
    },
    window = {
        border = "single"
    },
    hidden = { "Telescope","<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }
}
