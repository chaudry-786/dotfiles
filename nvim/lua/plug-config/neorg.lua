require("neorg").setup {
    load = {
        ["core.defaults"] = {},
        ["core.keybinds"] = {
            config = { neorg_leader = "<leader>o" },
        },
        ["core.concealer"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    notes = "$HOME/Dropbox/Norg/notes",
                },
            },
        },
        ["core.summary"] = {},
        ["core.ui.calendar"] = {}
    },
}
vim.api.nvim_create_autocmd("FileType",
    {
        group = "CustomAutoCmds",
        pattern = "norg",
        callback = function()
            vim.api.nvim_buf_set_keymap(0, "n", "<leader>tc", ":Neorg toggle-concealer<CR>", { noremap = true })
        end
    })

--org open
vim.keymap.set("n", "<leader>oo", ":Neorg workspace notes<CR>")
