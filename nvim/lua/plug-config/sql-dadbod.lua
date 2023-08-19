-- define connections here
vim.g.dbs = { dev = "mysql://user:pwd@localhost" }

vim.g.db_ui_use_nerd_fonts = 1

--helpers
vim.g.db_ui_table_helpers = { mysql = { Count = "select count(*) from {dbname}.{table}" } }


vim.api.nvim_set_keymap("n", "<leader>tS", ":DBUIToggle<CR>", {})
