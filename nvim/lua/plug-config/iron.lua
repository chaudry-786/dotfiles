local iron = require("iron.core")
iron.setup {
    config = {
        scratch_repl = true,
        repl_open_cmd = require("iron.view").right(0.40),
    },
    keymaps = {
        visual_send = "<leader>sc",
        send_file = "<leader>sf",
        send_line = "<leader>sl",
        exit = "<leader>sq",
        clear = "<leader>sC",
    },
    ignore_blank_lines = true,
}

-- Toggle REPL
function ToggleRepl()
    if vim.fn.exists("g:iron_repl_win") == 1 then
        vim.cmd(":IronHide")
    else
        vim.cmd(":IronRepl")
    end
end
vim.keymap.set("n", "<leader>tr", ":lua ToggleRepl()<CR>", { silent = true })

-- clear REPL, highlight inner paragraph, send to REPL
vim.keymap.set("n", "<leader>rc", ":call feedkeys(' sCvip sc')<CR>", { silent = true })
-- clear REPL, highlighted text send to REPL
vim.keymap.set("v", "<leader>rc", "<Esc>:call feedkeys(' sCgv sc')<CR>", { silent = true })
vim.keymap.set("n", "<leader>rr", ":IronRestart<CR>:IronRepl<CR>", { silent = true })
