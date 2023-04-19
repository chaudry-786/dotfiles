require("which-key").setup {
    plugins = {
        registers = false
    },
    window = {
        border = "single"
    },
    hidden = { "Telescope", "Fzf", "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    triggers_blacklist = {
        n = { ":" },
    },
}
